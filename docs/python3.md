# GeoPandas : Introduction aux données géospatiales vectorielles

[GeoPandas](https://geopandas.org) est une extension de Pandas qui
ajoute la gestion des données géospatiales vectorielles.

Un GeoDataFrame est un DataFrame Pandas auquel on a ajouté une colonne
spéciale `geometry` contenant des objets géométriques Shapely (points,
lignes, polygones), ainsi qu’un système de référence de coordonnées
(CRS).

GeoPandas repose sur trois bibliothèques complémentaires :

- **Shapely** : création et manipulation des géométries (Point,
  LineString, Polygon…)
- **Fiona** / **pyogrio** : lecture et écriture des formats vectoriels
  (GeoJSON, GeoPackage, Shapefile…)
- **pyproj** : gestion des systèmes de coordonnées et des reprojections

GeoPandas est une bibliothèque open-source ( info et documentation :
[geopandas.org](https://geopandas.org)).

```python
import geopandas as gpd
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from shapely.geometry import Point, LineString, Polygon
```

## Les géométries Shapely

Avant de travailler avec des GeoDataFrames, il est utile de comprendre
les objets géométriques de base fournis par Shapely.

Shapely est basée sur la bibliothèque GEOS (Geometry Engine - Open
Source), une bibliothèque C++ open-source dédiée à la manipulation de
géométries vectorielles. GEOS fournit les fonctionnalités de base pour
créer, manipuler et analyser des géométries 2D (points, lignes,
polygones, etc.). Cette bibliothèque est aussi utilisée par PostGIS,
QGIS, …

### Point

Un `Point` représente une localisation ponctuelle (station météo,
adresse, sommet…).

```python
# Créer un point à partir de coordonnées (longitude, latitude) en WGS84
# Tarbes : chef-lieu des Hautes-Pyrénées
tarbes = Point(0.0781, 43.2328)
tarbes
```

```python
# Accéder aux coordonnées définies précédemment
print("x (longitude) :", tarbes.x)
print("y (latitude)  :", tarbes.y)
```

```python
# Quelques points caractéristiques des Hautes-Pyrénées
stations = {
    'Tarbes'     : Point(0.0781,  43.2328),
    'Lourdes'    : Point(0.0462,  43.0944),
    'Bagnères'   : Point(0.1494,  43.0656),
    'Pic du Midi': Point(0.1428,  42.9367),
    'Arreau'     : Point(0.3664,  42.9069),
    'Saint-Lary' : Point(0.3244,  42.8178),
}
for nom, pt in stations.items():
    print(f"{nom:<12} -> lon={pt.x:.4f}  lat={pt.y:.4f}")
```

### LineString

Un `LineString` représente une séquence de points connectés (route,
rivière, trajet…).

```python
# Trajet de Tarbes à Saint-Lary en passant par Bagnères et Arreau
trajet = LineString([
    (0.0781, 43.2328),   # Tarbes
    (0.1494, 43.0656),   # Bagnères-de-Bigorre
    (0.3664, 42.9069),   # Arreau
    (0.3244, 42.8178),   # Saint-Lary-Soulan
])
trajet
```

```python
# Longueur en degrés (pas en mètres car cela nécessite une projection)
print("Longueur (degrés) :", round(trajet.length, 4))
print("Nombre de points  :", len(trajet.coords))
```

### Polygon

Un `Polygon` représente une surface fermée (commune, zone tampon,
emprise…).

```python
# Polygone approximatif de l'emprise des Hautes-Pyrénées
emprise_65 = Polygon([
    (-0.20, 43.55),
    ( 0.55, 43.55),
    ( 0.55, 42.68),
    (-0.20, 42.68),
    (-0.20, 43.55),   # fermeture du polygone
])
emprise_65
```

```python
# Propriétés géométriques
print("Aire (degrés²) :", round(emprise_65.area, 4))
print("Périmètre      :", round(emprise_65.length, 4))
print("Centroïde      :", emprise_65.centroid)
```

### Relations entre géométries

Shapely permet de tester des relations spatiales entre géométries.

```python
pt_lourdes = Point(0.0462, 43.0944)
pt_bruxelles = Point(4.3517, 50.8503)   # Bruxelles
print("Lourdes dans emprise 65 :", emprise_65.contains(pt_lourdes))
print("Bruxelles dans emprise 65 :", emprise_65.contains(pt_bruxelles))
```

```python
# Intersection de deux polygones
zone_nord = Polygon([(-0.20, 43.10), (0.55, 43.10),
                     (0.55, 43.55), (-0.20, 43.55), (-0.20, 43.10)])
intersection = emprise_65.intersection(zone_nord)
print("Type de l'intersection :", intersection.geom_type)
print("Aire intersection :", round(intersection.area, 4))
```

### Exercices

**Exercice buffer**

Calculez la zone autour de Tarbes ayant un buffer de 0.09 degrée (+/-
10km) (documentation sur
https://shapely.readthedocs.io/en/stable/reference/shapely.Polygon.html
)

```python
# votre réponse
buffer_tarbes=tarbes.buffer(0.09)
buffer_tarbes
```

**Exercice convex_hull**

A l’aide de la propriété `convex_hull` (documentation sur
https://shapely.readthedocs.io/en/stable/manual.html), calculez le
polygone qui englobe toutes les stations.

```python
# votre réponse
points = list(stations.values())
multi = LineString(points)
convex = multi.convex_hull
convex
```

## Le GeoDataFrame

Un GeoDataFrame est un DataFrame Pandas avec :

- une colonne `geometry` contenant des objets Shapely,
- un attribut `crs` indiquant le système de coordonnées.

Toutes les méthodes Pandas (`loc`, `iloc`, `groupby`, filtrage…)
fonctionnent identiquement sur un GeoDataFrame.

### Créer un GeoDataFrame depuis une liste de géométries

```python
# Créer un GeoDataFrame de stations météo
data = {
    'nom'      : list(stations.keys()),
    'altitude' : [320, 420, 550, 2877, 720, 830],
    'temp_moy' : [15.5, 14.8, 13.9,  3.2, 11.2, 10.4],
}
geometry = list(stations.values())
gdf_stations = gpd.GeoDataFrame(data, geometry=geometry, crs='EPSG:4326')
gdf_stations
```

```python
# Type de l'objet
type(gdf_stations)
```

```python
# Le CRS
gdf_stations.crs
```

```python
# Accéder à la colonne geometry
gdf_stations.geometry
```

```python
# Accéder à la géométrie d'une ligne
gdf_stations.loc[0, 'geometry']
```

```python
# Les méthodes Pandas fonctionnent normalement
gdf_stations[gdf_stations['altitude'] > 700]
```

### Créer un GeoDataFrame depuis un DataFrame Pandas avec coordonnées

La fonction `gpd.points_from_xy()` crée une colonne `geometry` de type
`Point` à partir de deux colonnes `x` (longitude) et `y` (latitude) d’un
DataFrame existant. Grâce à cette méthode nous allons pourvoir créer un
GeoDataFrame pour les données de la BAN.

Dans un premier temps, nous allons recréer le DataFrame `df_ban`.

```python
# Charger le CSV BAN simplifié produit dans un DataFrame (Pandas)
import os
csv_path = 'data/adresses-65-simplifie.csv'
df_ban = pd.read_csv(csv_path, sep=';', dtype={'commune_insee': str})
print(f"{len(df_ban):,} adresses chargées")
df_ban.head(5) # seulement les  5 premières lignes
```

```python
# Convertir le DataFrame en GeoDataFrame et spécifier le  CRS (EPSG:4326)
gdf_ban = gpd.GeoDataFrame(
    df_ban,
    geometry=gpd.points_from_xy(df_ban['long'], df_ban['lat']),
    crs='EPSG:4326'
)
print(type(gdf_ban))
print("CRS :", gdf_ban.crs)
gdf_ban.head(5) # seulement les  5 premières lignes
```

```python
# La colonne geometry contient des Points Shapely
gdf_ban['geometry'].head(5) # seulement les  5 premières lignes(5)
```

## Lire des données géospatiales vectorielles

GeoPandas peut lire directement la plupart des formats vectoriels
(GeoPackage, GeoJSON, Shapefile, FlatGeobuf…) avec la fonction
`read_file`.

### Télécharger les contours communaux

Nous allons utiliser les contours administratifs des communes françaises
mis à disposition par le projet
[AdminExpress](https://geoservices.ign.fr/adminexpress) de l’IGN,
disponibles sur data.gouv.fr.

```python
import requests
os.makedirs('data', exist_ok=True)
# GeoJSON simplifié des contours communaux France entière (source : etalab/decoupage-administratif)
url_communes = (
    "https://geo.api.gouv.fr/communes"
    "?codeDepartement=65&format=geojson&geometry=contour"
)
communes_path = 'data/communes-65.geojson'

if not os.path.exists(communes_path):
    print("Téléchargement des contours communaux...")
    r = requests.get(url_communes)
    with open(communes_path, 'w', encoding='utf-8') as f:
        f.write(r.text)
    print("Fichier disponible :", communes_path)
else:
    print("Fichier déjà présent :", communes_path)
```

```python
# Lecture du GeoJSON avec GeoPandas
gdf_communes = gpd.read_file(communes_path)
print(f"{len(gdf_communes)} communes chargées")
gdf_communes.head(10)
```

**Exercice : exploration du GeoDataFrame**

A l’aide des méthodes `info` et `describe` vues dans le module Pandas,
explorez `gdf_communes`.

```python
# votre réponse
gdf_communes.info()
gdf_communes.describe()
```

Ensuite, affichez la ligne de la commune dont le nom est `Tarbes`.

```python
# votre réponse
commune_tarbes = gdf_communes[gdf_communes['nom'] == 'Tarbes']
commune_tarbes
```

Finalement, répondez aux questions suivantes :

- Quelles sont les colonnes disponibles ?
- Quel est le CRS du GeoDataFrame ?
- Quel est le type de géométrie (Point, LineString, Polygon…) ?

```python
# votre réponse
gdf_communes.columns
gdf_communes.crs
gdf_communes.geometry.geom_type.value_counts()
```

*Astuce* Si vous voulez inspecter une ligne ayant beaucoup de colonnes
vous pouvez utiliser la transposée (`.T`) qui pivote le table. Dans ce
cas les colonnes deviennent des lignes.

```python
gdf_communes[gdf_communes['nom'] == 'Tarbes'].T
```

## Visualisation cartographique de base

La méthode `.plot()` de GeoPandas produit une carte directement avec
Matplotlib.

### Visualisation simple

Le code suivant permet de créer une visualistation simple de notre
GeoDataFrame

```python
# Carte des communes du département
fig, ax = plt.subplots(figsize=(8, 8))
gdf_communes.plot(ax=ax, color='gray', edgecolor='#155555', linewidth=0.4)
ax.set_title("Communes des Hautes-Pyrénées", fontsize=25)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

#### Explications

La ligne `fig, ax = plt.subplots(figsize=(8, 8))` crée deux objets : -
`fig` : la **figure**, c’est-à-dire la “feuille” globale sur laquelle
tout est dessiné. - `ax` : l’**axe**, c’est-à-dire la zone de dessin à
l’intérieur de la figure où les données sont tracées.

L’option `figsize=(8, 8)` fixe sa taille en pouces (largeur, hauteur) de
la figure.

L’object `ax` est passée à `.plot(ax=ax)` pour que GeoPandas dessine sur
cet axe précis. Cela permet de de superposer plusieurs couches sur la
même figure.

La méthode `.plot()` est configurée de la manière suivante : -
`color='white'` : couleur de remplissage des polygones -
`edgecolor='#555555'` : couleur des contours - `linewidth=0.4` :
épaisseur des contours en points

`ax.set_axis_off()` masque les axes (graduations, cadre). Sans cela, des
axes x/y avec des valeurs de longitude et latitude apparaissent autour
de la carte.

`plt.tight_layout()` ajuste automatiquement les marges de la figure pour
éviter que les titres ou labels soient coupés.

### Superposer plusieurs couches

On crée une figure Matplotlib, on récupère l’axe `ax`, et on passe ce
même axe à chaque appel `.plot(ax=ax)`.

```python
fig, ax = plt.subplots(figsize=(8, 8))
# Couche 1 : fond communal
gdf_communes.plot(ax=ax, color='#f5f0e8', edgecolor='#aaaaaa', linewidth=0.4)
# Couche 2 : adresses BAN (points, très petits car très nombreux)
gdf_ban.plot(ax=ax, color='steelblue', markersize=0.2, alpha=0.3)
# Couche 3 : stations météo (points plus visibles)
gdf_stations.plot(ax=ax, color='crimson', markersize=40,
                  edgecolor='white', linewidth=0.5, zorder=5)
# Annotations des stations
for idx, row in gdf_stations.iterrows():
    ax.annotate(
        row['nom'],
        xy=(row.geometry.x, row.geometry.y),
        xytext=(5, 5), textcoords='offset points',
        fontsize=8, color='#333333',
    )
ax.set_title("Adresses BAN et stations météo (Hautes-Pyrénées - 65)", fontsize=15)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

### Arguments de `.plot()` à connaître

| Argument | Rôle | Exemple |
|------------------------|------------------------|------------------------|
| `color` | Couleur uniforme de tous les objets | `color='white'` |
| `edgecolor` | Couleur du contour | `edgecolor='black'` |
| `linewidth` | Épaisseur du contour | `linewidth=0.5` |
| `markersize` | Taille des points | `markersize=10` |
| `alpha` | Transparence (0=invisible, 1=opaque) | `alpha=0.5` |
| `column` | Colonne pour la colorisation thématique | `column='altitude'` |
| `cmap` | Palette de couleurs (colormap Matplotlib) | `cmap='viridis'` |
| `legend` | Afficher la légende | `legend=True` |
| `scheme` | Méthode de discrétisation (nécessite `mapclassify`) | `scheme='quantiles'` |
| `categorical` | Traiter la colonne comme des catégories distinctes plutôt que des valeurs continues | `categorical=True` |

Documentation complète :
[geopandas.org/en/stable/docs/reference/api/geopandas.GeoDataFrame.plot.html](https://geopandas.org/en/stable/docs/reference/api/geopandas.GeoDataFrame.plot.html)

### Carte thématique par colonne

Une carte thématique colorise les polygones selon une variable
numérique. Le paramètre `column` désigne la colonne à utiliser.

Sans discrétisation, la couleur varie en continu selon la valeur. Ce
n’est pas idéal si les données sont très asymétriques (quelques grandes
villes face à beaucoup de petits villages).

Une solution est de créer des classes avec `pd.cut`, qui découpe une
variable continue en intervalles. Le paramètre `bins` fixe le nombre de
classes et `labels` leur nom affiché dans la légende.

**Exercice : coloration continue**

Tracez une carte de la population par commune en colorisation
**continue** (`column='population'`, `cmap='YlOrRd'`).

```python
# votre réponse
# définition des classes pour mieux catégoriser (visuel)
bins = [0, 100, 200, 500, 1000, float('inf')] # classes

labels = [
    '0-100',
    '100-200',
    '200-500',
    '500-1000',
    '>1000'
]
gdf_communes['pop_classe'] = pd.cut(
    gdf_communes['population'],
    bins=bins,
    labels=labels
)
```

```python
# votre réponse
# affichage de la carte selon les classes définis précédemment
gdf_communes.plot(
    column='pop_classe',
    categorical=True,
    cmap='YlOrRd',
    legend=True
)
plt.title("Population par classes")
plt.axis('off')
plt.show()
```

```python
# votre réponse bis
fig, ax = plt.subplots(figsize=(8, 8))
gdf_communes.plot(
    column='pop_classe',
    categorical=True,
    cmap='YlOrRd',
    legend=True,
    ax=ax
)
# Annotations des stations
for idx, row in gdf_stations.iterrows():
    ax.annotate(
        row['nom'],
        xy=(row.geometry.x, row.geometry.y),
        xytext=(5, 5), textcoords='offset points',
        fontsize=8, color='#333333'
    )
ax.set_title("Population par classes (Hautes-Pyrénées)", fontsize=15)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

**Exercice : pop_classe**

Créez une colonne `pop_classe` avec `pd.cut` en découpant la population
en 5 classes. Ensuite  
puis tracez la carte avec `categorical=True`. Comparez la lisibilité
avec la Question 1.

```python
# votre réponse
import pandas as pd
import matplotlib.pyplot as plt

bins = [0, 100, 200, 500, 1000, float('inf')]

labels = [
    'Très faible ',
    'Faible',
    'Moyenne ',
    'Élevée ',
    'Très élevée '
]
gdf_communes['pop_classe'] = pd.cut(
    gdf_communes['population'],
    bins=bins,
    labels=labels
)
# Carte
fig, ax = plt.subplots(figsize=(8, 8))
gdf_communes.plot(
    column='pop_classe',
    categorical=True,
    cmap='YlOrRd',
    legend=True,
    ax=ax
)
ax.set_title("Population par classes (seuils définis)")
ax.set_axis_off()
plt.show()
```

### Ajouter un fond de carte OSM avec contextily

[Contextily](https://contextily.readthedocs.io) ajoute un fond de carte
tuilé (OpenStreetMap, CartoDB…) en arrière-plan. Les données doivent
être en Web Mercator (`EPSG:3857`) pour s’aligner avec les tuiles.

```python
import contextily as cx

fig, ax = plt.subplots(figsize=(9, 9))

# Reprojecter en Web Mercator pour contextily
gdf_communes_3857 = gdf_communes.to_crs('EPSG:3857')
gdf_ban_3857 = gdf_ban.to_crs('EPSG:3857')

gdf_communes_3857.plot(
    ax=ax,
    color='none',
    edgecolor='#333333',
    linewidth=0.5,
)

gdf_ban_3857.plot(
    ax=ax,
    color='crimson',
    markersize=0.3,
    alpha=0.4,
)

# Ajouter le fond de plan OpenStreetMap
cx.add_basemap(ax, source=cx.providers.CartoDB.Positron, zoom=9)

ax.set_title("Adresses BAN / Hautes-Pyrénées / fond OSM", fontsize=12)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

## Écrire un GeoDataFrame

GeoPandas peut écrire vers plusieurs formats via `to_file()`. Le format
GeoPackage (`.gpkg`) est recommandé : il est lisible par QGIS, ne limite
pas la longueur des noms de colonnes, et tient en un seul fichier.

```python
# Écrire les stations météo en GeoPackage
gdf_stations.to_file('data/stations_meteo_65.gpkg', driver='GPKG')
print("Fichier écrit : data/stations_meteo_65.gpkg")
```

```python
# Écrire en GeoJSON
gdf_stations.to_file('data/stations_meteo_65.geojson', driver='GeoJSON')
print("Fichier écrit : data/stations_meteo_65.geojson")
```

```python
# Relire pour vérifier
gdf_relu = gpd.read_file('data/stations_meteo_65.gpkg')
print(gdf_relu.crs)
gdf_relu
```

## Propriétés géométriques

GeoPandas expose les propriétés Shapely sur l’ensemble d’une colonne
`geometry`.

Le centroïde d’un polygone est le point qui minimise la somme des
distances au carré à tous ses points. Ce calcul suppose des coordonnées
**planes** (en mètres). Si les géométries sont en CRS géographique
(degrés de longitude/latitude, comme WGS84), la courbure de la Terre
fausse le résultat et GeoPandas émet un avertissement.

La bonne pratique est donc de reprojeter en CRS projeté (ici Lambert 93,
EPSG:2154) avant le calcul, puis de revenir en WGS84 si nécessaire. Les
CRS sont détaillés dans le module suivant.

```python
# Centroïde de chaque commune
gdf_communes_2154 = gdf_communes.to_crs('EPSG:2154')
gdf_communes['centroide'] = gdf_communes_2154.geometry.centroid

gdf_communes[['nom', 'centroide']].head(5)
```

```python
# Type géométrique de chaque objet
gdf_communes.geometry.geom_type.value_counts()
```

```python
# Emprise totale (bounding box) du département
print("Emprise (lon_min, lat_min, lon_max, lat_max) :")
print(gdf_communes.total_bounds)
```

```python
# Test de validité des géométries
invalides = gdf_communes[~gdf_communes.geometry.is_valid]
print(f"Géométries invalides : {len(invalides)}")
```

## Exercice : cartographier les adresses BAN par commune

Nous allons construire une carte montrant le nombre d’adresses BAN pour
chaque commune des Hautes-Pyrénées.

**Question 1** À partir de `df_ban`, calculez le nombre d’adresses par
commune avec `groupby`. Nommez le résultat `df_count`, avec les colonnes
`commune_insee` et `nb_adresses`.

```python
# À vous !
df_count = df_ban.groupby('commune_insee').size().reset_index(name='nb_adresses')
df_count.head()
```

**Question 2** Effectuez une jointure attributaire entre `gdf_communes`
et `df_count` en utilisant la méthode `merge()`, qui fonctionne comme un
LEFT JOIN SQL : elle associe chaque ligne de `gdf_communes` à son nombre
d’adresses en faisant correspondre la colonne `code` (dans
`gdf_communes`) avec la colonne `commune_insee` (dans `df_count`).

Utilisez `how='left'` pour conserver toutes les communes, même celles
sans adresses dans la BAN.

Appelez le résultat `gdf_communes_count`.

```python
# À vous !
gdf_communes_count = gdf_communes.merge(
    df_count,
    left_on='code',
    right_on='commune_insee',
    how='left'
)
gdf_communes_count.head()
```

**Question 3** Vérifiez que la jointure a bien fonctionné. Combien de
communes ont une valeur `NaN` dans la colonne `nb_adresses` ? Que
signifient ces NaN ?

```python
# À vous !
gdf_communes_count['nb_adresses'].isnull().sum()
```

**Question 4** Créez une colonne `nb_adresses_classe` dans
`gdf_communes_count` en découpant `nb_adresses` en 5 classes avec
`pd.cut` (labels : `'Très faible'`, `'Faible'`, `'Moyenne'`, `'Élevée'`,
`'Très élevée'`). Tracez ensuite une carte thématique avec
`categorical=True` et `cmap='YlOrRd'`. Ajoutez un titre et désactivez
les axes.

```python
# À vous !
# Créer les classes d'abord
import pandas as pd
import matplotlib.pyplot as plt
bins = [0, 100, 200, 500, 1000, float('inf')]
labels = [
    'Très faible (0-100)',
    'Faible (100-200)',
    'Moyenne (200-500)',
    'Élevée (500-1000)',
    'Très élevée (>1000)'
]
gdf_communes_count['nb_adresses_classe'] = pd.cut(
    gdf_communes_count['nb_adresses'],
    bins=bins,
    labels=labels
)
# Carte
fig, ax = plt.subplots(figsize=(8, 8))

gdf_communes_count.plot(
    column='nb_adresses_classe',
    categorical=True,
    cmap='YlOrRd',
    legend=True,
    ax=ax
)
ax.set_title("Nombre d’adresses BAN par commune (classes)")
ax.set_axis_off()
plt.show()
```

**Question 5** Créez un GeoDataFrame `gdf_ban_tarbes` contenant
uniquement les adresses BAN de Tarbes (filtrer sur
`commune_nom == 'Tarbes'`). Affichez-les sur une carte avec le contour
de la commune en arrière-plan.

```python
# À vous !
# 1- Filtre Tarbes
gdf_ban_tarbes = gdf_ban[gdf_ban['commune_nom'] == 'Tarbes']
```

```python
# À vous !
# 2- Filtrer la commune de Tarbes (polygone)
gdf_tarbes_commune = gdf_communes[gdf_communes['nom'] == 'Tarbes']
```

```python
# À vous !
# 3- Carte (superposition)
import matplotlib.pyplot as plt
fig, ax = plt.subplots(figsize=(8, 8))
# contour commune (fond)
gdf_tarbes_commune.plot(
    ax=ax,
    color='none',
    edgecolor='black',
    linewidth=1
)
# points BAN
gdf_ban_tarbes.plot(
    ax=ax,
    color='green',
    markersize=1,
    alpha=0.5
)
ax.set_title("Adresses BAN à Tarbes")
ax.set_axis_off()
plt.show()
```

**Question 6** Écrivez `gdf_communes_count` dans un GeoPackage nommé
`communes-65-adresses.gpkg`.

```python
gdf_communes_count = gdf_communes_count.set_geometry('geometry')
gdf_communes_count = gdf_communes_count[['nom', 'code', 'population', 'nb_adresses', 'nb_adresses_classe', 'geometry']]

gdf_communes_count.to_file(
    'data/communes-65-adresses.gpkg',
    driver='GPKG'
)
```

## Récapitulatif des fonctions clés

| Fonction / Méthode | Rôle |
|------------------------------------|------------------------------------|
| `Point(x, y)` | Créer un point Shapely |
| `LineString([(x1,y1), ...])` | Créer une ligne Shapely |
| `Polygon([(x1,y1), ...])` | Créer un polygone Shapely |
| `gpd.GeoDataFrame(df, geometry=, crs=)` | Créer un GeoDataFrame |
| `gpd.points_from_xy(lon, lat)` | Série de Points depuis deux colonnes |
| `gpd.read_file(path)` | Lire un fichier vectoriel (GeoJSON, GPKG, SHP…) |
| `gdf.to_file(path, driver=)` | Écrire un fichier vectoriel |
| `gdf.crs` | Système de coordonnées du GeoDataFrame |
| `gdf.geometry` | Colonne des géométries |
| `gdf.geometry.geom_type` | Type de chaque géométrie |
| `gdf.geometry.centroid` | Centroïde de chaque géométrie |
| `gdf.total_bounds` | Emprise totale (xmin, ymin, xmax, ymax) |
| `gdf.geometry.is_valid` | Validité de chaque géométrie |
| `gdf.plot(column=, cmap=, scheme=, legend=)` | Carte thématique |
| `gdf.to_crs('EPSG:xxxx')` | Reprojeter (vue complète dans le module A2) |
| `cx.add_basemap(ax, source=)` | Ajouter un fond de carte OSM |
| `gdf.merge(df, left_on=, right_on=)` | Jointure attributaire |
