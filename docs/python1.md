# NumPy : tableaux multidimensionnels
---

Avant de travailler avec GeoPandas et Rasterio, il est important de
découvrir la librairie numpy.

NumPy (Numerical Python) est une bibliothèque Python spécialisée dans le
calcul numérique. Elle a été créée pour répondre aux mauvaises
performances de Python natif pour les opérations sur des tableaux,
l’algèbre linéaire et la manipulation de données scientifiques.

NumPy est la fondation sur laquelle reposent Pandas, GeoPandas et
RasterIO. Comprendre NumPy, c’est comprendre comment ces bibliothèques
stockent et traitent les données en mémoire.

NumPy est une bibliothèque open-source disponible sur
[numpy.org](https://numpy.org).

## Le tableau NumPy (`ndarray`)

NumPy introduit le concept de tableaux multidimensionnels (`ndarray`).
Un `ndarray` est une structure de données homogène : tous ses éléments
sont du même type, et sa taille est fixée à la création.

Ces deux contraintes, type unique et taille fixe, permettent à NumPy de
stocker les données de façon contiguë en mémoire (rapidité lecture et
écriture en mémoire) et d’appliquer des opérations sur l’ensemble du
tableau sans boucle Python. Le gain de performance est considérable :
jusqu’à 50 fois plus rapide qu’une liste classique.

|                        | Liste Python | ndarray NumPy           |
|------------------------|--------------|-------------------------|
| Types des éléments     | Hétérogène   | Homogène                |
| Taille                 | Variable     | Fixe                    |
| Performances           | Standard     | Jusqu’à 50X plus rapide |
| Opérations vectorisées | Non          | Oui                     |

Dans d’autres langages, les `ndarray` sont appelés `array` ou `tensor`.

Commençons par importer NumPy. La convention universelle est de
l’importer sous l’alias `np`.

```python
# import de la librairie numpy
import numpy as np 
# on peut remplacer numpy par geopandans, pandas, rasterio pour verifier leurs versions aussi
```

```python
np.__version__
```

## Tableaux à une, deux et trois dimensions

### Tableau à une dimension (vecteur)

Un tableau 1D est un vecteur, c’est-à-dire une suite ordonnée de
valeurs.

```python
# Températures mesurées dans 5 stations météo des Hautes-Pyrénées
temperatures = np.array([15.2, 16.8, 14.5, 17.3, 12.1])
temperatures
```

```python
# La propriété shape indique la forme du tableau
# Pour un vecteur : (nombre d'éléments,)
temperatures.shape
```

### Tableau à deux dimensions (matrice)

Un tableau 2D est une matrice (lignes et colonnes). En géographie, on
peut l’imaginer comme une carte raster (grille de pixels).

```python
# Carte de températures 3x4 : 3 lignes (de Nord à Sud), 4 colonnes (de OuestEst)
carte_temp = np.array([
    [12.5, 13.2, 14.1, 13.8],   # Ligne 0 : Nord
    [13.8, 15.0, 16.2, 15.5],   # Ligne 1 : Centre
    [14.5, 16.8, 17.5, 17.2],   # Ligne 2 : Sud
])
carte_temp
```

```python
# shape d'un tableau 2D : (nombre de lignes, nombre de colonnes)
carte_temp.shape
```

### Tableau à trois dimensions

Un tableau 3D ajoute une troisième dimension.

```python
# Tableau 3D
array_3d = np.array([
    [[0, 1, 2],    [3, 4, 5],    [6, 7, 8],    [9, 10, 11]],
    [[12, 13, 14], [15, 16, 17], [18, 19, 20], [21, 22, 23]],
    [[24, 25, 26], [27, 28, 29], [30, 31, 32], [33, 34, 35]]])
array_3d
```

```python
# Créer un code pour récuperer sur le resultat précédent:
# 1 er tableau:4 et7
# 2 eme tableau: 16 et 19
# 3 eme tableau: 28 et 31
# votre réponse
resultat = array_3d[:, 1:3, 1]
print (resultat)
```

<figure>
<img src="attachment:img/p410/arr3d.png" alt="Vision 3D d’un tableau" />
<figcaption aria-hidden="true">Vision 3D d’un tableau</figcaption>
</figure>

En télédétection, une image satellite multispectrale est un tableau 3D :
(nombre de bandes, hauteur, largeur).

```python
# Simulation : 3 bandes spectrales, chacune sur une grille 4x4
image_spectrale = np.array([
    [[100, 110, 120, 130],
     [140, 150, 160, 170],
     [180, 190, 200, 210],
     [220, 230, 240, 250]],   # Bande 1 (Bleu)

    [[200, 210, 220, 230],
     [240, 250, 260, 270],
     [280, 290, 300, 310],
     [320, 330, 340, 350]],   # Bande 2 (Rouge)

    [[300, 320, 340, 360],
     [380, 400, 420, 440],
     [460, 480, 500, 520],
     [540, 560, 580, 600]],   # Bande 3 (PIR)
])
image_spectrale
```

```python
# shape d'un tableau 3D : (bandes, lignes, colonnes)
image_spectrale.shape
```

## Les propriétés d’un tableau NumPy

Tout `ndarray` expose un ensemble de propriétés qui décrivent sa
structure.

```python
# shape  : dimensions du tableau (lignes, colonnes) ou (bandes, lignes, colonnes)
carte_temp.shape
```

```python
# ndim   : nombre de dimensions
carte_temp.ndim
```

```python
# size   : nombre total d'éléments
carte_temp.size
```

```python
# dtype  : type des données stockées
carte_temp.dtype
```

Le `dtype` est important : NumPy choisit par défaut `float64` pour les
flottants et `int64` pour les entiers. On peut le préciser à la création
pour économiser de la mémoire.

```python
# Préciser un dtype à la création
arr_float32 = np.array([1.0, 2.0, 3.0], dtype=np.float32)
arr_float32.dtype   # float32 occupe moitié moins de mémoire que float64
```

## Créer des tableaux NumPy

Plutôt que de saisir des valeurs à la main, NumPy propose plusieurs
fonctions pour créer des tableaux de façon programmatique.

```python
# np.zeros : tableau rempli de zéros (très utilisé pour initialiser des grilles raster)
grille_vide = np.zeros((3, 4))
grille_vide
``
```python
# np.ones : tableau rempli de uns
np.ones((2, 5))
``

```python
# np.arange : suite de valeurs avec un pas (comme range() en Python)
np.arange(0, 10, 2)   # de 0 à 10 exclu, pas de 2
```

```python
# np.linspace : n valeurs régulièrement espacées entre deux bornes
# Très utile pour créer des axes de graphiques ou des grilles d'interpolation
np.linspace(0, 1, 11)   # 11 valeurs de 0.0 à 1.0 inclus
```

```python
# np.random.seed + np.random.normal : données aléatoires reproductibles
np.random.seed(42) #  fixation du générateur de nombres aléatoires (pour reproductibilité)
bruit = np.random.normal(loc=0, scale=0.5, size=(3, 4)) # où loc est la moyenne et scale l'écart type
bruit
```

**Exercice**

Créez une grille `mnt_zone`, un tableau NumPy de 5×5 contenant les
altitudes (en mètres) extraites d’un MNT 25 m dans les Hautes-Pyrénées,
du nord-ouest (haut-gauche, plaine de Tarbes) au sud-est (bas-droite,
piémont pyrénéen).

Les altitudes sont :

    342,  387,  456,  521,  598
    378,  431,  512,  634,  748
    412,  489,  601,  782,  934
    467,  568,  714,  901, 1124
    534,  672,  863, 1087, 1342

```python
# votre réponse
import numpy as np

mnt_zone = np.array([
    [342, 387, 456, 521, 598],
    [378, 431, 512, 634, 748],
    [412, 489, 601, 782, 934],
    [467, 568, 714, 901, 1124],
    [534, 672, 863, 1087, 1342]
])

mnt_zone
```

## Accès aux éléments : indexing et slicing

### Accès à un élément

```python
array = np.array([[10, 20, 30],
                  [40, 50, 60]])

# Accès à un élément : [ligne, colonne]
array[0, 1]   # -> 20
```

### Sélection de lignes et colonnes

```python
# Toute la ligne 0
array[0, :]
```python

```python
# Toute la colonne 1
array[:, 1]
```

```python
# Sous-tableau : lignes 0 à 1 (fin exclue), colonnes 1 à 2 (fin exclue)
array[0:2, 1:3]
```

**Exercice**

Extraire la 2ème ligne de la variable `mnt_zone`

```python
# Votre réponse
mnt_zone[1]
```

Extraire la sous-région (lignes 1 et 2, colonnes 2 et 3) du MNT se
trouvant dans la variable `mnt_zone`

```python
# votre réponse
sous_region = mnt_zone[0:2, 1:3]
sous_region
```

### Slicing sur un tableau 3D

```python
# Extraire la bande 0 entière (toutes les lignes, toutes les colonnes)
image_spectrale[0, :, :]
```

```python
# Extraire le pixel à la ligne 1, colonne 2 pour toutes les bandes
image_spectrale[:, 1, 2]
```

```python
# Extraire une sous-image : bandes 1 et 2, lignes 0-1, toutes colonnes
image_spectrale[1:3, 0:2, :]
```

## Opérations sur les tableaux

### Opérations élémentaires

NumPy applique les opérations élément par élément, sans boucle.

```python
a = np.array([1, 2, 3])
b = np.array([4, 5, 6])

print("Addition      :", a + b)        # [5, 7, 9]
print("Soustraction  :", a - b)        # [-3, -3, -3]
print("Multiplication :", a * b)       # [4, 10, 18]
print("Division      :", a / b)        # [0.25, 0.4, 0.5]
print("Puissance     :", a ** 2)       # [1, 4, 9]
```

```python
# Les opérations scalaires s'appliquent à tous les éléments
carte_temp_kelvin = carte_temp + 273.15
carte_temp_kelvin
```

### Fonctions mathématiques

```python
print("Racine carrée  :", np.sqrt(a))
print("Exponentielle  :", np.exp(a))
print("Logarithme     :", np.log(a))
```

```python
# Statistiques descriptives
print("Somme    :", np.sum(carte_temp))
print("Minimum  :", np.min(carte_temp))
print("Maximum  :", np.max(carte_temp))
print("Moyenne  :", np.mean(carte_temp))
print("Écart-type:", np.std(carte_temp))
```

```python
# Les statistiques peuvent se calculer par axe
# axis=0 -> par colonne (sur l'axe des lignes)
# axis=1 -> par ligne   (sur l'axe des colonnes)
print("Moyenne par colonne (Nord->Sud) :", np.mean(carte_temp, axis=0))
print("Moyenne par ligne (Ouest->Est)  :", np.mean(carte_temp, axis=1))
```

**Exercice**

En utilisant les fonctions statistiques de NumPy sur `mnt_zone` :

- Calculez l’altitude moyenne de la zone.
- Trouvez l’altitude minimale et maximale.
- Calculez l’écart-type des altitudes.

```python
# votre réponse
import numpy as np
# Altitude moyenne
moyenne = np.mean(mnt_zone)
# Altitude minimale
minimum = np.min(mnt_zone)
# Altitude maximale
maximum = np.max(mnt_zone)
# Écart-type des altitudes
ecart_type = np.std(mnt_zone)
# Affichage des résultats
print("Altitude moyenne :", moyenne)
print("Altitude minimale :", minimum)
print("Altitude maximale :", maximum)
print("Écart-type :", ecart_type)
```

### Produit matriciel

```python
mat_a = np.array([[1, 2], [3, 4]])
mat_b = np.array([[5, 6], [7, 8]])
np.dot(mat_a, mat_b)
```
## Broadcasting

Le broadcasting est la capacité de NumPy à effectuer des opérations
entre tableaux de formes différentes, à condition que leurs dimensions
soient compatibles.

```python
# Ajouter un vecteur de correction à chaque ligne d'une matrice
corrections = np.array([0.5, 1.0, -0.5, 0.2])   # vecteur 1D, 4 éléments
carte_corrigee = carte_temp + corrections         # appliqué à chaque ligne
carte_corrigee
```

Ici `corrections` (shape `(4,)`) est “étiré” pour correspondre à
`carte_temp` (shape `(3, 4)`). Le broadcasting évite de devoir dupliquer
les données ou d’écrire des boucles.

**Exercice**

Les capteurs qui ont mesuré les altitudes de `mnt_zone` présentent un
biais systématique par colonne (de ouest en est) :

    corrections = np.array([-5.0, -2.0, 0.0, +2.0, +5.0])

Appliquez ces corrections à `mnt_zone` par broadcasting et stockez le
résultat dans `mnt_corrige`. Vérifiez que la première colonne a bien
diminué de 5 m et que la dernière a bien augmenté de 5 m.

```python
# votre réponse
import numpy as np

corrections = np.array([-5.0, -2.0, 0.0, 2.0, 5.0])

mnt_corrige = mnt_zone + corrections
mnt_corrige
```

## Masques booléens et filtrage

Un masque booléen est un tableau de `True`/`False` obtenu en appliquant
une condition sur un tableau. Il permet de sélectionner ou de modifier
des éléments selon un critère, sans boucle.

```python
#Vous retrouverez ce code plus haut, ceci est une copie intégrale
# Carte de températures 3x4 : 3 lignes (de Nord à Sud), 4 colonnes (de OuestEst)
carte_temp = np.array([
    [12.5, 13.2, 14.1, 13.8],   # Ligne 0 : Nord
    [13.8, 15.0, 16.2, 15.5],   # Ligne 1 : Centre
    [14.5, 16.8, 17.5, 17.2],   # Ligne 2 : Sud
])
carte_temp
```

```python
# Créer un masque : quelles cellules ont une température inférieure à 14degC ?
masque_froid = (carte_temp < 14.0) | (carte_temp >16.0) # concaténation veut dire or, & veut dire and
masque_froid
```

```python
# Compter les cellules froides
np.sum(masque_froid)   # True est traité comme 1
```

```python
# Extraire uniquement les valeurs froides
carte_temp[masque_froid]
```

```python
# Combiner plusieurs conditions
masque_tempere = (carte_temp >= 14.0) & (carte_temp <= 16.0)
carte_temp[masque_tempere]
```
```python
# Remplacer des valeurs : les cellules > 17degC sont marquées comme anomalie (np.nan)
carte_modif = carte_temp.copy()   # toujours travailler sur une copie
carte_modif[carte_temp > 17.0] = np.nan
carte_modif
```

Cette technique est fondamentale en RasterIO : les pixels hors emprise
ou invalides d’un MNT sont représentés par des valeurs `nodata`, souvent
-9999 ou -32768, que l’on remplace par `np.nan` avant tout calcul.

**Exercice A**

Combien de pixels de `mnt_zone` ont une altitude supérieure à 800 m ?
Quel pourcentage du total cela représente-t-il ?

```python
# votre réponse
nb_pixels, pourcentage = np.sum(mnt_zone > 800), np.sum(mnt_zone > 800) / mnt_zone.size * 100
```

```python
# Affichage
print(nb_pixels, pourcentage) # 6 pixels, soit 24 %
```

**Exercice B**

Sur `mnt_zone` :

- Créez un masque des pixels situés en dessous de 400 m (fond de vallée,
  peu pertinents pour l’analyse).
- Affichez les valeurs correspondantes.
- Créez une copie `mnt_seuil` et remplacez ces valeurs par 400.0.
  Vérifiez que le minimum de `mnt_seuil` est bien 400.0.

```python
# votre réponse
masque = mnt_zone < 400
print(mnt_zone[masque])

mnt_seuil = mnt_zone.copy()
mnt_seuil[masque] = 400.0
print(np.min(mnt_seuil))
```

## Gestion des données manquantes (`NaN`)

`np.nan` (Not a Number) est la valeur conventionnelle pour représenter
une donnée manquante dans un tableau numérique.

```python
mesures = np.array([15.2, 16.8, np.nan, 17.3, np.nan, 15.9])
mesures
```

```python
# Détecter les NaN
np.isnan(mesures)
```
```python
# Compter les valeurs valides (inverse du masque NaN)
nb_valides = np.sum(~np.isnan(mesures))
print("Valeurs valides :", nb_valides)
```
Les fonctions qui commencent par `nan` (notées `np.nan*`) sont les
versions “NaN-tolérantes” de leurs équivalentes classiques : elles
ignorent les NaN au lieu de renvoyer nan dès qu’il y en a un dans le
tableau.

Par exemple, np.mean retournera nan dès qu’un seul NaN est présent dans
le tableau, alors que np.nanmean l’ignorera et calculera la moyenne sur
les valeurs valides uniquement.

```python
# Calculs en ignorant les NaN
print("Moyenne (avec NaN ignorés) :", np.nanmean(mesures))
print("Max    (avec NaN ignorés) :", np.nanmax(mesures))
print("Somme  (avec NaN ignorés) :", np.nansum(mesures))
```

**Exercice**

Calculez la moyenne des pixels de `mnt_zone`qui se trouvent entre 500 et
1000m.

```python
# votre reponse
moyenne = np.mean(mnt_zone[(mnt_zone >= 500) & (mnt_zone <= 1000)])
moyenne
```

## Reshape et manipulation de forme

La forme d’un tableau peut être modifiée sans copier les données.

```python
# Créer un vecteur de 12 éléments
v = np.arange(12)
v #print (v)
```

```python
# Convertir en matrice 3x4
mat = v.reshape(3, 4)
mat
```

```python
# Convertir en matrice 4x3
mat2 = v.reshape(4, 3)
mat2
```

```python
# flatten() : retourner à un vecteur (renvoie une copie)
mat.flatten()
```

```python
# ravel() : idem mais renvoie une vue (plus efficace en mémoire)
mat.ravel()
```
```python
# Ajouter une dimension (utile pour le broadcasting ou RasterIO)
# Une image raster à une bande a la forme (1, H, W)
mat_3d = mat[np.newaxis, :, :]    # shape (1, 3, 4)
print("Avant :", mat.shape)
print("Après :", mat_3d.shape)
```

## Visualiser un tableau 2D avec `plt.imshow`

Un tableau 2D peut être visualisé directement comme une image. C’est
exactement ce que fait RasterIO pour afficher un MNT ou une bande
satellite.

```python
import matplotlib.pyplot as plt

# Générer une grille d'altitude synthétique 50x50
np.random.seed(0)
altitude_synth = np.random.normal(loc=00, scale=200, size=(50, 50))
altitude_synth = np.clip(altitude_synth, 0, 1000)   # borner entre 0 et 1000 m
```
```python
# Affichage minimal
plt.imshow(altitude_synth, cmap='terrain')
plt.colorbar(label='Altitude (m)')
plt.title('Grille d\'altitude synthétique')
plt.show()
```

```python
# La colormap 'terrain' est appropriée pour les élévations.
# D'autres options utiles : 'gray', 'viridis', 'RdYlGn'
fig, axes = plt.subplots(1, 3, figsize=(14, 4))

for ax, cmap in zip(axes, ['terrain', 'gray', 'viridis']):
    im = ax.imshow(altitude_synth, cmap=cmap)
    plt.colorbar(im, ax=ax, label='Altitude (m)')
    ax.set_title(f'cmap = {cmap!r}')

plt.tight_layout()
plt.show()
```
Cette visualisation directe par `plt.imshow` sera notre outil de
diagnostic tout au long des parties RasterIO et Sentinel-2.

**Exercice**

Affichez `mnt_zone` avec `plt.imshow` en utilisant la colormap
`'terrain'`. Ajoutez une barre de couleurs avec le label
`'Altitude (m)'` et un titre.

```python
# votre réponse
import matplotlib.pyplot as plt

plt.imshow(mnt_zone, cmap='terrain')
plt.colorbar(label='Altitude (m)')
plt.title('MNT - Zone des Hautes-Pyrénées')

plt.show()
```

## Récapitulatif des fonctions abordées

| Fonction                          | Rôle                                  |
|-----------------------------------|---------------------------------------|
| `np.array([...])`                 | Créer un tableau à partir d’une liste |
| `np.zeros(shape)`                 | Tableau de zéros                      |
| `np.ones(shape)`                  | Tableau de uns                        |
| `np.arange(start, stop, step)`    | Suite de valeurs espacées d’un pas    |
| `np.linspace(start, stop, n)`     | n valeurs régulièrement espacées      |
| `arr.shape`                       | Dimensions du tableau                 |
| `arr.ndim`                        | Nombre de dimensions                  |
| `arr.size`                        | Nombre total d’éléments               |
| `arr.dtype`                       | Type des données                      |
| `arr.reshape(shape)`              | Changer la forme (sans copier)        |
| `arr.flatten()`                   | Remettre à plat (copie)               |
| `arr.copy()`                      | Copie indépendante                    |
| `np.sum / min / max / mean / std` | Statistiques globales                 |
| `np.nanmean / nanmax / nansum`    | Statistiques en ignorant les NaN      |
| `np.isnan(arr)`                   | Masque des NaN                        |
| `arr[masque]`                     | Sélection par masque booléen          |
| `plt.imshow(arr, cmap=...)`       | Visualiser un tableau 2D comme image  |
