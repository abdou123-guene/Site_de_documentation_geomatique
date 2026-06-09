# Estimation des indices de végétation

Les modèles classiques d’apprentissage automatique nécessitent une étape
d’ingénierie des caractéristiques pour fonctionner correctement. Parmi
les caractéristiques bien connues pour caractériser la végétation en
télédétection figurent l’Indice de Végétation par Différence Normalisée
(NDVI), l’Indice de Végétation Vert-Rouge (GRVI) et l’Indice d’Eau par
Différence Normalisée (NDWI<sub>GREEN</sub>).

## Formules

$$NDVI = \frac{NIR-RED}{NIR+RED}$$

$$GRVI = \frac{Green-RED}{Green+RED}$$

$$NDWI_{GREEN} = \frac{Green-NIR}{Green+NIR}$$

Nous allons calculer les rasters NDVI. Si vous avez le temps, vous
pouvez calculer les autres indices.

## Calcul du NDVI

```python
PROCESSED_DIR = './sentinel2_data/processed'
VI_DATA = './sentinel2_data/VI'
```

```python
import os
os.makedirs(VI_DATA, exist_ok=True)
```

A l’aide de la librairie `glob`, créez une variable `stacked_img_list`
contenant la liste des images S2 qui contiennent les bandes regroupées
(`stacked`). Pour rappel le dossier où elle est trouve est dans la
variable `PROCESSED_DIR`.

```python
import glob
# stacked_img_list =
stacked_img_list = glob.glob(PROCESSED_DIR + "/*_stacked.tif")
```

Ensuite à l’aide de `rasterio`, essayez d’écrire le code pour la
création du NDVI sur la première image de `stacked_img_list`

- ouvrir l’image raster et lire les bandes
- calculer l’image raster `ndvi = (band8 - band4) / (band8 + band4)`
- enregistrer l’image raster à l’emplacement
  `VI_DATA + '/' + str(date) + '_ndvi.tif'` (où `date` est la date de
  l’image traitée). Attention lors de l’écritude des métadonnées
  indiquez que l’image créée n’a qu’une bande et de mettre le nodata à
  -9999 (car le 0 est une valeur possible de NDVI)

```python
path_stacked_img = stacked_img_list[0]
date = path_stacked_img[-20:-20+8]
output_img_path = VI_DATA + '/' + str(date) + '_ndvi.tif'
# a vous
```

```python
import rasterio
import numpy as np
import os

for path_stacked_img in stacked_img_list:

    date = path_stacked_img[-20:-20+8]
    output_img_path = os.path.join(VI_DATA, str(date) + '_ndvi.tif')

    with rasterio.open(path_stacked_img) as src:
        band4 = src.read(3).astype(np.float32)
        band8 = src.read(4).astype(np.float32)
        profile = src.profile

    with np.errstate(divide='ignore', invalid='ignore'):
        ndvi = (band8 - band4) / (band8 + band4)

    ndvi[(band8 + band4) == 0] = -9999
    ndvi[band4 == 0] = -9999

    profile.update({
        "count": 1,
        "dtype": "float32",
        "nodata": -9999
    })

    with rasterio.open(output_img_path, 'w', **profile) as dest:
        dest.write(ndvi.astype(np.float32), 1)

    print("✅ NDVI créé :", output_img_path)
```

Pour le calcul `ndvi = (band8 - band4) / (band8 + band4)` un
avertissement
(`RuntimeWarning: invalid value encountered in  divide ndvi = (band8 - band4) / (band8 + band4)`)
est affiché. En effet, `band8` et `band4` peuvent avoir la même valeur
et il y a donc une division par zéro.

Pour gérer ce problème, remplacez

```python
ndvi = (band8 - band4) / (band8 + band4)
```

par

```python
with np.errstate(divide='ignore', invalid='ignore'):
    ndvi = (band8 - band4) / (band8 + band4)
```

Le résultat sera np.nan là où la division est impossible.

Nous allons, maintenant, vérifier le fichier produit.

- Ouvrez QGIS et comparez S2_stacked et ndvi
- Le fichier ndvi est incorrect ! Quel est le problème ?

En effet il y a une erreur de type : les images S2 sont enregistrées en
int16, mais le NDVI est un nombre flottant.

Voici comment convertir les données :

```python
stacked_img = rasterio.open(path_stacked_img)
band4 = stacked_img.read(3).astype(np.float32)
stacked_img.close() # ou utiliser la notation with
```

De plus, vu qu’on utilise `-9999` comme valeur `no data`, il faut mettre
`-9999` sur les pixels qui étaient à `0` (ancienne valeur du `no data`)

```python
# good luck !
#Le problème vient du type de données :

#Le fichier NDVI est incorrect car les bandes Sentinel‑2 sont stockées en int16, alors que le NDVI est une valeur flottante. Sans conversion en float32, 
#le calcul est erroné. De plus, les pixels avec valeur 0 (nodata) doivent être remplacés par -9999 afin de ne pas fausser le résultat.
# On recalculer les NDVI maintenant en bas
```

```python
# Recalculer des NDVI donc
import rasterio
import numpy as np
import os

# s'assurer que le dossier existe
os.makedirs(VI_DATA, exist_ok=True)

for path_stacked_img in stacked_img_list:

    # extraire la date
    date = path_stacked_img[-20:-20+8]
    output_img_path = os.path.join(VI_DATA, str(date) + '_ndvi.tif')

    # --- lecture ---
    with rasterio.open(path_stacked_img) as src:
        band4 = src.read(3).astype(np.float32)   # RED
        band8 = src.read(4).astype(np.float32)   # NIR
        profile = src.profile

    # --- calcul NDVI ---
    with np.errstate(divide='ignore', invalid='ignore'):
        ndvi = (band8 - band4) / (band8 + band4)

    # --- gérer nodata ---
    ndvi[(band8 + band4) == 0] = -9999
    ndvi[band4 == 0] = -9999

    # --- mise à jour profil ---
    profile.update({
        "count": 1,
        "dtype": "float32",
        "nodata": -9999
    })

    # --- écriture ---
    with rasterio.open(output_img_path, 'w', **profile) as dest:
        dest.write(ndvi.astype(np.float32), 1)

    print("✅ NDVI créé :", output_img_path)
```

Vérifiez que l’image créée est bonne. Si c’est le cas. Générez les
images NDVI pour toutes les images de `stacked_img_list`.

```python
# on met tout dans une boucle for
```
