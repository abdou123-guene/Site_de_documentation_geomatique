# STATISTIQUES ZONALES

Ce notebook vise à extraire des statistiques spatiales qui résumeront le
comportement des parcelles analysées. L’avantage est que cela permet de
disposer de moins de données. Mais cela peut être problématique si nous
n’avons pas assez d’échantillons d’entraînement !

Nous utiliserons le package `rasterstats` pour calculer des statistiques
spatiales à partir d’un shapefile.

## Zone d’étude

Les parcelles étudiées se trouvent dans le shapefile
`./data/parcelles_shp/T31TCJ_stable_2023_2024.shp`. Vous pouvez
constater que nous avons deux types de cultures qui couvrent toute la
tuile.

```python
import os
```

```python
VI_DATA = './sentinel2_data/VI'
STATS_DATA_PATH = './sentinel2_data/stats'
TIMESERIES_PATH = './sentinel2_data/time_series'
ZONE_ETUDE_SHP = './sentinel2_data/data/parcelles_shp/T31TCJ_stable_2023_2024.shp'
```

```python
os.makedirs(STATS_DATA_PATH, exist_ok = True)
os.makedirs(TIMESERIES_PATH, exist_ok = True)
```

Nous utilisons la fonction `zonal_stats` qui va calculer pour chaque
parcelle les stats (`min`, `max`, `median` et `std`) et sauvegarder les
résultats dans un shp.

```python
import numpy as np
from rasterstats import zonal_stats
import geopandas as gpd
import glob
from os.path import join

gdf = gpd.read_file(ZONE_ETUDE_SHP)
proj = gdf.crs
img_list = glob.glob(VI_DATA + '/*.tif')
for img_path in img_list:
    img_name = os.path.basename(img_path)[:-4]
    img_output_path = join(STATS_DATA_PATH, img_name + '.shp')

    print(f"traitement de {img_name}")

    zone_f = zonal_stats(
        ZONE_ETUDE_SHP,
        img_path,
        stats=['min', 'max', 'median', 'mean', 'std'],
        nodata=np.nan,
        copy_properties=True,
        geojson_out=True)

    geostats = gpd.GeoDataFrame.from_features(zone_f)
    geostats = geostats.set_crs('epsg:32631')
    geostats.to_file(img_output_path)

    print(f"fin traitement et svg dans {img_output_path}")
```

Ouvrez un shapefile dans QGIS, comparez-le avec le raster NDVI utilisé
en entrée.

Comptez le nombre de fichiers .shp, correspond-il au nombre attendu ?

# Construction des séries temporelles

À partir des fichiers de statistiques zonales calculés ci-dessus, nous
allons construire des séries temporelles par parcelle. Pour chaque
combinaison d’indice (NDVI) et de statistique (moyenne, médiane,
écart-type), nous produisons un fichier .shp où chaque ligne est une
parcelle et chaque colonne est une date d’acquisition. Ces tableaux
parcelles x dates constituent les caractéristiques d’entrée des
algorithmes d’apprentissage automatique.

```python
from os.path import join
from os import listdir
import glob

vi_list = ['ndvi']
# all_stats = ['mean','median','std','min','max']
stat_list = ['mean','median','std']

for vi in vi_list:
    for stat in stat_list:
        new_gdf = gpd.GeoDataFrame() # création d'un GeoDataFrame vide

        list_imgs = glob.glob(f"{STATS_DATA_PATH}/*{vi}.shp")
        list_imgs.sort() # classement par date

        for img in list_imgs:
            img_name = os.path.basename(img)[:-4]
            date = img_name.split('_')[0][0:8]

            print(f"--  calcul des stats temporelles pour {vi} {stat} {img_name}")

            gdf = gpd.read_file(img) # lecture
            new_gdf[date] = gdf[stat]

        new_gdf[['ID_PARCEL', 'SURF_PARC', 'CODE_CULTU', 'CODE_GROUP', 'area', 'geometry']] = gdf[['ID_PARCEL', 'SURF_PARC', 'CODE_CULTU', 'CODE_GROUP', 'area', 'geometry']]
        shp_output_path = join(TIMESERIES_PATH,'T31TCJ_'+vi+'_'+stat+'.shp')
        new_gdf.to_file(shp_output_path)
        print(f"Création du shp {shp_output_path}")
```

En procédant de manière similaire, il est possible de traiter d’autres
indices / statistiques.

Nous allons nous concentrer sur le NDVI médian.
