# Traitement des images Sentinel-2 à l’aide de `rasterio`

## Présentation

Ce notebook effectue le prétraitement des images Sentinel-2 téléchargées
dans le notebook précédent.

L’objectif est de produire des images multi-bandes au format GeoTIFF et
prêtes à l’analyse (bandes regroupées en un seul fichier, pixels nuageux
masqués).

Nous allons donc :

- empiler les bandes spectrales `B02` (Bleu), `B03` (Vert), `B04`
  (Rouge), `B08` (PIR / NIR) en un seul fichier GeoTIFF à 4 bandes
- masquer les pixels nuageux à l’aide du masque SCL (Scene
  Classification Layer) fourni avec chaque produit L2A
- sauvegarder les images traitées dans un dossier `PROCESSED_DIR`

Pour ce travail nous allons utiliser
[`rasterio`](https://rasterio.readthedocs.io/), une bibliothèque Python
conçue pour lire et écrire des fichiers raster géospatiaux (GeoTIFF,
JP2…). Elle offre une interface pythonique autour de GDAL, sans en
exposer la complexité.

## Création du dossier pour sauvegarder les images traitées

```python
DOWNLOAD_DIR = './sentinel2_data/download'
EXTRACT_DIR = './sentinel2_data/extract'
PROCESSED_DIR = './sentinel2_data/processed'
```

```python
import os
os.makedirs(PROCESSED_DIR, exist_ok=True)
```

## Ouverture et lecture d’une image avec rasterio

Avant de commencer la conversion, nous allons utiliser `rasterio` pour
ouvrir et lire une bande S2.

> *Note* Pour éviter des problèmes de performances, `rasterio.open()`
> n’ouvre pas l’image en mémoire. Les données sont chargées que lorsque
> `src.read()` est exécuté.

```python
import rasterio
import glob
from matplotlib import pyplot as plt

# Lister toutes les bandes B02 disponibles
list_B02 = sorted(glob.glob(
    EXTRACT_DIR + '/*/GRANULE/*/IMG_DATA/R10m/*_B02_10m.jp2'
))

# Choisir l'image à charger
id_img = 0

path_img = list_B02[id_img]
print(f"\nImage chargée : {path_img}")

# Lecture et affichage
with rasterio.open(path_img) as src:
    np_img = src.read(1)

print(f"Shape : {np_img.shape}")

display_range = [0, 100]
plt.imshow(np_img[display_range[0]:display_range[1], display_range[0]:display_range[1]])
plt.title(f"B02 image [{id_img}]")
plt.colorbar()
plt.show()
```

```python
np_img.max()
```

Ouvrez l’image dans qgis pour comparer : à quoi sert le paramètre
display_range ici ?

## Création d’une image GeoTIFF pas à pas

Avant de faire le prétraitement sur toutes les images nous allons
d’abord travailler sur une seule image.

Nous allons utiliser `rasterio.open` pour ouvrir les images existantes
(‘B02’,‘B03’,‘B04’,‘B08’), ainsi que l’image GeoTIFF qui contiendra le
résultat du traitement.

```python
# liste des bandes
band_list = ['B02','B03','B04','B08']


# liste des dossier différents dossier S2
s2_folder_list = glob.glob(EXTRACT_DIR + "/*/")

# choix du dossier de travail
working_s2_folder = s2_folder_list[0]
```

```python
# recherche du nom des images pour chaque band
img_bands = {}
for band in band_list:
    img_band_pattern = working_s2_folder + 'GRANULE/*/IMG_DATA/R10m/*_' + band + '_10m.jp2'

    img_bands[band] = glob.glob(img_band_pattern)[0]
img_bands
```

```python
# date de l'image
img_date = img_bands['B02'].split('/')[3][11:11+8]
```

```python
# lecture des bandes
band02 = rasterio.open(img_bands['B02'])
band03 = rasterio.open(img_bands['B03'])
band04 = rasterio.open(img_bands['B04'])
band08 = rasterio.open(img_bands['B08'])
```

```python
band02_profile = band02.profile # profile de la bande 2 qui est utilisé pour la création de l'image stacked
stacked_profile = {
    "driver": "GTiff", # GeoTIFF
    "dtype": band02_profile['dtype'],
    "width": band02_profile['width'],
    "height": band02_profile['height'],
    "count": 4, # 4 BANDES
    "crs": band02_profile['crs'],
    "transform": band02_profile['transform'],
    "nodata": 0,
    "compress": "lzw"
}
stacked_profile
```

```python
with rasterio.open(PROCESSED_DIR + '/' + str(img_date) + '_stacked.tif', 'w', **stacked_profile) as dest:
    dest.write(band02.read(1),1)
    dest.write(band03.read(1),2)
    dest.write(band04.read(1),3)
    dest.write(band08.read(1),4)
    print('DONE')
```

Attention ce n’est pas fini, il manque la gestion des nuages. Voici ce
qu’il faut faire pour gérer cette étape :

```python
img_10m_width = stacked_profile['width']
img_10m_height = stacked_profile['height']

# nom de l'image contenant les nuages
scl_path = glob.glob(working_s2_folder + 'GRANULE/*/IMG_DATA/R20m/*_SCL_20m.jp2')[0]

# ouverture de l'image en interpolant de 20m à 10m
from rasterio.enums import Resampling

with rasterio.open(scl_path) as scl_src:
    scl = scl_src.read(1, out_shape=(img_10m_height, img_10m_width), resampling=Resampling.nearest)
```

```python
# 1. Lire B02 + récupérer profile
with rasterio.open(img_bands['B02']) as src:
    band02 = src.read(1)
    stacked_profile = src.profile
# 2. Lire autres bandes
with rasterio.open(img_bands['B03']) as src:
    band03 = src.read(1)
with rasterio.open(img_bands['B04']) as src:
    band04 = src.read(1)
with rasterio.open(img_bands['B08']) as src:
    band08 = src.read(1)
# 3. Adapter le profil pour 4 bandes
stacked_profile.update({
    "count": 4,
    "dtype": band02.dtype,
    "compress": "lzw",
    "nodata": 0
})
# 4. Lire SCL + masque
from rasterio.enums import Resampling
scl_path = glob.glob(
    working_s2_folder + 'GRANULE/*/IMG_DATA/R20m/*_SCL_20m.jp2'
)[0]
with rasterio.open(scl_path) as scl_src:
    scl = scl_src.read(
        1,
        out_shape=(band02.shape[0], band02.shape[1]),
        resampling=Resampling.nearest
    )
# 5. Masque nuage
import numpy as np
cloud_mask = np.isin(scl, [3, 8, 9, 10])
# 6. Appliquer masque
band02[cloud_mask] = 0
band03[cloud_mask] = 0
band04[cloud_mask] = 0
band08[cloud_mask] = 0
# 7. Écrire GeoTIFF (ancian stacked va etre ecrasé et donc remplacé)
out_path = os.path.join(PROCESSED_DIR, img_date + "_stacked.tif")
with rasterio.open(out_path, "w", **stacked_profile) as dest:
    dest.write(band02, 1)
    dest.write(band03, 2)
    dest.write(band04, 3)
    dest.write(band08, 4)
print("✅ Image créée :", out_path)
```

Nous allons maintenant créer une variable, `cloud_mask` qui contiendra
un masque `numpy` en utilisant la méthode `np.isin` sur la variable
`scl` tel que masque sera à `True` quand la donnée est de `scl` est à
`3`, `8`, `9` ou `10` (nuage).

Ensuite nous pouvons mettre à jour les variables `band02`, `band03`,
`band04` et `band08`: mettre à 0 les pixels qui sont à `True` dans
`cloud_mask`.

## Traitement de toutes les images

```python
from rasterio.enums import Resampling
import numpy as np
```

```python
recompute_existing_img = False
```

```python
for s2_img in s2_folder_list:
    img_date = s2_img.split('/')[-2].split('_')[2][:8]
    print("processing", img_date)

    out_path = os.path.join(PROCESSED_DIR, img_date + '_stacked.tif')

    if not recompute_existing_img and os.path.exists(out_path):
        print(f"--- {out_path} : PASS (déjà existant, ignoré)")
        continue

    # --- bandes 10m ---
    img_band = {}
    for band in band_list:
        img_band_pattern = s2_img + 'GRANULE/*/IMG_DATA/R10m/*_' + band + '_10m.jp2'

        img_band[band] = glob.glob(img_band_pattern)[0]

    with rasterio.open(img_band['B02']) as src:
        img_height, img_width = src.height, src.width
        profile = {
            "driver": "GTiff", # ON PASSE EN GeoTIFF
            "dtype": src.dtypes[0],
            "width": src.width,
            "height": src.height,
            "count": 4, # 4 BANDES
            "crs": src.crs,
            "transform": src.transform,
            "nodata": 0,
            "compress": "lzw"
        }

    # --- masque nuages SCL 20m -> rééchantillonné 10m ---
    scl_path = glob.glob(s2_img + 'GRANULE/*/IMG_DATA/R20m/*_SCL_20m.jp2')[0]
    with rasterio.open(scl_path) as scl_src:
        scl = scl_src.read(1, out_shape=(img_height, img_width), resampling=Resampling.nearest)

    # SCL : 3=ombre nuage, 8=nuage moyen, 9=nuage dense, 10=cirrus
    cloud_mask = np.isin(scl, [3, 7, 8, 9, 10])

    # --- lecture bandes + application masque ---
    with rasterio.open(img_band['B02']) as src:
        band02 = src.read(1)
    with rasterio.open(img_band['B03']) as src:
        band03 = src.read(1)
    with rasterio.open(img_band['B04']) as src:
        band04 = src.read(1)
    with rasterio.open(img_band['B08']) as src:
        band08 = src.read(1)


    band02[cloud_mask] = 0 # numpy
    band03[cloud_mask] = 0
    band04[cloud_mask] = 0
    band08[cloud_mask] = 0

    with rasterio.open(out_path, 'w', **profile) as dest:
        dest.write(band02, 1)
        dest.write(band03, 2)
        dest.write(band04, 3)
        dest.write(band08, 4)

    print(f"--- {out_path} : DONE")
```

#### Remarque : rééchantillonnage de bandes à 20m

Dans ce notebook, nous n’utilisons que les bandes à 10m (B02, B03, B04,
B08). Les bandes à 20m (B05, B06, B07, B11, B12…) ont été ignorées car
elles nécessitent un rééchantillonnage avant de pouvoir être empilées
avec les bandes 10m.

Nous avons déjà fait du rééchantillonnage dans ce notebook (le masque
SCL passe de 20m à 10m via `out_shape`) mais sans mettre à jour le
`transform` géographique, ce qui était suffisant car le SCL n’est
utilisé qu’en mémoire comme masque booléen et n’est jamais sauvegardé.

Pour rééchantillonner une bande et la sauvegarder dans un GeoTIFF, il
faut en plus mettre à jour le `transform` (la matrice qui fait le lien
entre pixels et coordonnées géographiques), sinon les pixels seront mal
géolocalisés. Voici comment faire :

```python
# script adapté juste en bas
upscale_factor = 2  # passer de 20m à 10m

with rasterio.open("example.tif") as dataset:
    # lecture avec rééchantillonnage
    data = dataset.read(
        out_shape=(
            dataset.count,
            int(dataset.height * upscale_factor),
            int(dataset.width * upscale_factor)
        ),
        resampling=Resampling.bilinear  # bilinear car données continues
    )
    # mise à jour du transform pour refléter la nouvelle résolution
    transform = dataset.transform * dataset.transform.scale(
        (dataset.width / data.shape[-1]),
        (dataset.height / data.shape[-2])
    )
```

Si vous avez le temps, essayez de rééchantillonner une bande B05 (20m) à
10m et de l’ajouter à votre image empilée. Documentation :
https://rasterio.readthedocs.io/en/stable/topics/resampling.html

```python
from rasterio.enums import Resampling

# trouver B05
b05_path = glob.glob(
    working_s2_folder + 'GRANULE/*/IMG_DATA/R20m/*_B05_20m.jp2'
)[0]

# lecture + rééchantillonnage
with rasterio.open(b05_path) as src:
    band05 = src.read(
        1,
        out_shape=(
            int(src.height * 2),   # 20m → 10m
            int(src.width * 2)
        ),
        resampling=Resampling.bilinear
    )

    # ✅ mise à jour du transform
    transform = src.transform * src.transform.scale(
        (src.width / band05.shape[1]),
        (src.height / band05.shape[0])
    )
```
