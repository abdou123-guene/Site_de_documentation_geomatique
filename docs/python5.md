# Téléchargement de données Sentinel-2 avec CDSETool

## Présentation

Ce notebook télécharge des images Sentinel-2 L2A à l’aide de
[CDSETool](https://github.com/CDSETool/CDSETool), une bibliothèque
Python pour accéder au **Copernicus Data Space Ecosystem (CDSE)**.

CDSE est la plateforme officielle de l’ESA offrant un accès gratuit aux
données satellitaires Copernicus, dont Sentinel-2.

### Ce que nous téléchargeons

Nous allons télécharger les images relatives à :

- tuile : T31TCJ (région de Toulouse, France)
- période : de 2025-04-01 à 2026-04-01
- niveau de produit : L2A (réflectance de surface, corrigée
  atmosphériquement)
- couverture nuageuse : \<= 20%

```python
TILE_ID     = "31TCJ"
START_DATE  = "2025-04-01"
END_DATE    = "2026-04-01"
MAX_CLOUD   = 20
```

### Format des données : les dossiers SAFE

Chaque image téléchargée est livrée au format SAFE (Standard Archive
Format for Europe), le format de distribution officiel de l’ESA pour
tous les produits Sentinel.

Ce n’est pas un simple fichier image ; c’est une arborescence normalisée
contenant les bandes spectrales à plusieurs résolutions, les métadonnées
et les masques qualité.

    S2A_MSIL2A_20250415T104021_N0511_R008_T31TCJ_20250415T154512.SAFE/
    |-- manifest.safe          -> inventaire de tous les fichiers (XML)
    |-- MTD_MSIL2A.xml         -> métadonnées globales du produit
    |-- GRANULE/
    │   |-- L2A_T31TCJ_.../
    │       |-- MTD_TL.xml     -> métadonnées de la tuile
    │       |-- IMG_DATA/
    │       │   |-- R10m/      -> bandes à 10 m (B02, B03, B04, B08…)
    │       │   |-- R20m/      -> bandes à 20 m (B05, B06, B07, B11, B12…)
    │       │   |-- R60m/      -> bandes à 60 m (B01, B09…)
    │       |-- QI_DATA/       -> masques qualité (nuages, ombres…)
    |-- DATASTRIP/             -> métadonnées du passage satellite

Le nom du dossier SAFE suit une convention stricte et normalisée :

    S2A _ MSIL2A _ 20250415T104021 _ N0511 _ R008 _ T31TCJ _ 20250415T154512 .SAFE

| Exemple           | Champ              | Signification                        |
|-------------------|--------------------|--------------------------------------|
| `S2A`             | Satellite          | Sentinel-2A (ou 2B, 2C)              |
| `MSIL2A`          | Niveau             | Produit L2A (réflectance de surface) |
| `20250415T104021` | Date d’acquisition | 15 avril 2025 à 10h40 UTC            |
| `N0511`           | Version du code    | Version du processeur ESA            |
| `R008`            | Orbite relative    | Numéro d’orbite relative             |
| `T31TCJ`          | Tuile MGRS         | Tuile couvrant la région de Toulouse |
| `20250415T154512` | Date de traitement | 15 avril 2025 à 15h45 UTC            |

## I) Localiser la tuile

Nous allons travailler sur la tuile qui couvre la région de Toulouse.

Pour la localiser visuellement, vous pouvez utiliser le navigateur CDSE
-\> https://browser.dataspace.copernicus.eu

## II) Création des dossiers de travail

```python
# Répertoires de sortie
DOWNLOAD_DIR = './sentinel2_data/download'
EXTRACT_DIR  = './sentinel2_data/extract'
```

Ecrivez le code python pour créer, si n’existent pas les dossiers
`DOWNLOAD_DIR` et `EXTRACT_DIR`

```python
# A vous
import os
os.makedirs(DOWNLOAD_DIR, exist_ok=True)
os.makedirs(EXTRACT_DIR, exist_ok=True)
print("Dossiers prêts ✅")
```

## III) Rechercher les images Sentinel-2 disponibles

### Création de compte CDSE

Pour pouvoir intéragir avec la plateforme CDSE, nous devons nous
identifier. Nous devons dans un premier temps créer un compte sur
https://dataspace.copernicus.eu/

### Création du fichier .netrc

Afin que la bibliothèque `CDSETool` puisse vous authentifier directement
(sans devoir demander votre login / mot de passe), créez un fichier
`~/.netrc` avec le contenu suivant :

```python
#machine dataspace.copernicus.eu login <votre_email> password <votre_mot_de_passe>
```

```python
#from cdsetool.credentials import Credentials
```

### Authentification

Le code suivant permet de charger vos identifiants afin de pouvoir
interroger le catalogue CDSE.

```python
from cdsetool.credentials import Credentials
username = "guenelahad890@gmail.com"
password = "Soumis@1996#"
credentials = Credentials(username, password)
```

```python
# Alternative au fichier .netrc :
# credentials = Credentials("votre_email@exemple.com", "votre_mot_de_passe")
```

### Requête sur le catalogue CDSE

Nous pouvons maintenant interroger le catalogue CDSE via la fonction
`query_features`.

Lisez la documentation (
https://github.com/CDSETool/CDSETool#querying-features ) configurer la
fonction `query_features` (et donc la requête) avec

- l’identifiant de la tuile MGRS
- la plage de dates (ISO 8601)
- `S2MSI2A` comme type de produit (pour obtenir les produits L2A)
- la couverture nuageuse (voir `interval notation` pour demander entre 0
  et `MAX_CLOUD`).

Mettez le résultat de la requête dans la variable `features`

**Note** : la fonction `query_features` retourne un itérateur paresseux
: les produits sont récupérés page par page et non à la création de
l’itérateur.

```python
# votre code
# features =
# mon propre code
TILE_ID     = "31TCJ"
START_DATE  = "2025-04-01"
END_DATE    = "2026-04-01"
MAX_CLOUD   = 20

from cdsetool.query import query_features

collection = "SENTINEL-2"

search_terms = {
    "top": 100,
    "productType": "S2MSI2A",
    "tileId": TILE_ID,
    "contentDateStartGe": START_DATE,
    "contentDateStartLe": END_DATE,
    "cloudCover": f"[0,{MAX_CLOUD}]"
}

features = list(query_features(collection, search_terms))

print(len(features))
```

```python
# Matérialiser l'itérateur pour inspecter les résultats. Sans matérialisation :
# la fonction len ne marchera pas
# une fois avoir fait une itération sur features il n'est plus possible de reparcourir l'itérateur
features_list = list(features)

print(f"Trouvé {len(features_list)} produit(s) correspondant à la requête.\n")
for f in features_list:
    name  = f.get('Name', f.get('Id', 'inconnu'))
    date  = f.get('ContentDate', {}).get('Start', '?')
    # La couverture nuageuse est dans la liste Attributes
    print(f"  {name}  |  date: {date}")
```

## IV) Télécharger les images

Nous allons utiliser la fonction `download_features` pour télécharger
les images. Elle permet les téléchargements concurrents (4 fils
d’exécution par défaut).

Chaque produit téléchargé est un fichier `.zip` contenant l’archive SAFE
complète.

> **Avertissement** : le téléchargement d’une année complète de données
> peut prendre plusieurs heures et nécessiter plusieurs dizaines de Go
> d’espace disque.

```python
# La variable to_download permet de filtrer les produits qui ne sont pas encore présents dans le dossier de téléchargement 
#afin d’éviter de télécharger plusieurs fois les mêmes fichiers.
```

```python
# le code optimisé est juste en bas
# from cdsetool.download import download_features
import os

to_download = [
    f for f in features_list
        if not os.path.exists(os.path.join(DOWNLOAD_DIR, f['Name'] + '.zip'))
]

print(f"{len(features_list) - len(to_download)} produit(s) déjà présent(s), {len(to_download)} à télécharger.\n")

downloads = download_features(
    to_download,
    DOWNLOAD_DIR,
    {
        "concurrency" : 4,
        "credentials" : credentials,
    },
)

for product_id in downloads:
    print(f"Téléchargé : {product_id}")

print("\nTous les téléchargements sont terminés.")
```

```python
# Mon propre code corrigé (optimisé)
from cdsetool.download import download_features
import os

# sélectionner uniquement les fichiers non présents
to_download = [
    f for f in features_list
    if not os.path.exists(os.path.join(DOWNLOAD_DIR, f['Name'] + '.zip'))
]

print(f"{len(features_list) - len(to_download)} produit(s) déjà présent(s), {len(to_download)} à télécharger.\n")

# téléchargement
downloads = download_features(
    to_download,
    DOWNLOAD_DIR,
    {
        "concurrency": 4,
        "credentials": credentials
    }
)

# affichage
for product_id in downloads:
    print(f"Téléchargé : {product_id}")

print("\nTous les téléchargements sont terminés ✅")
```

Pouvez-vous expliquer à quoi sert la variables `to_download` ?

## V) Vérifier les fichiers téléchargés

Nous allons utiliser la bibliothèque `glob` pour vérifier les fichiers
téléchargés.

### La bibliothèque `glob`

[`glob`](https://docs.python.org/3/library/glob.html) est un module
Python qui permet de lister des fichiers en utilisant des motifs avec
des caractères génériques (un peu comme la recherche de fichiers dans un
terminal).

Les caractères génériques principaux :

| Motif | Signification | Exemple |
|-----------------|---------------------------------|----------------------|
| `*` | N’importe quelle suite de caractères | `*.zip` -\> tous les `.zip` |
| `?` | Un seul caractère quelconque | `S2?.zip` -\> `S2A.zip`, `S2B.zip`… |
| `[ABC]` | Un caractère parmi la liste | `S2[ABC]` -\> `S2A`, `S2B` ou `S2C` |

Par exemple la recherche
`glob.glob(DOWNLOAD_DIR + "/S2[ABC]_*.SAFE.zip")` signifie :

- `S2[ABC]` : le fichier commence par `S2A`, `S2B` ou `S2C` (les trois
  satellites Sentinel-2 actifs)
- `_` : suivi d’un underscore
- `*` : puis n’importe quel nom (date, tuile, identifiant…)
- `.SAFE.zip` : et se termine obligatoirement par `.SAFE.zip`

Cela évite de ramasser par accident d’autres fichiers `.zip` qui
pourraient traîner dans le dossier (fichiers temporaires, autres
produits…).

```python
import glob

list_s2_images = glob.glob(DOWNLOAD_DIR + "/S2[ABC]_*.SAFE.zip")

print(f"Nombre d'archives S2 zip téléchargées : {len(list_s2_images)}")
for p in sorted(list_s2_images):
    print(" ", p)
```

## VI) Extraire les archives

Nous allons maintenant extraire les archives SAFE dans le dossier
`EXTRACT_DIR`. Pour cela nous allons utiliser la bibliothèque `zipfile`.

> **Attention à l’espace disque** Chaque archive SAFE peut peser entre
> 500 Mo et 1 Go une fois décompressée. Assurez-vous de disposer de
> suffisamment d’espace libre avant d’exécuter cette cellule.

```python
import zipfile

for s2_zip in list_s2_images:
    print(f"Extraction de {s2_zip} ...")
    with zipfile.ZipFile(s2_zip) as zf:
        zf.extractall(EXTRACT_DIR)

print("\nExtraction terminée.")
```

## VII) Vérifier les dossiers SAFE extraits

Finalement nous vérifions les dossiers extraits à l’aide de `glob`.

```python
list_safe = glob.glob(EXTRACT_DIR + "/S2[ABC]_*.SAFE")

print(f"Nombre de dossiers SAFE extraits : {len(list_safe)}")
for p in sorted(list_safe):
    print(" ", p)
```
