# Opérations spatiales et jointures
---

Dans les modules A1 et A2, nous avons appris à créer des GeoDataFrames,
à les visualiser et à les reprojeter. Nous pouvons maintenant passer aux
**opérations spatiales** : tester des relations entre géométries, les
combiner, les découper, les fusionner, et joindre des couches entre
elles.

Ces opérations sont le cœur de l’analyse géospatiale : savoir quels
points tombent dans quels polygones, quelles zones se chevauchent,
quelles entités sont adjacentes.

```python
import geopandas as gpd
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from shapely.geometry import Point, LineString, Polygon, box
import os
import requests
```

```python
# Chargement des données du département 65 (produites dans les modules précédents)
communes_path = 'data/communes-65.geojson'

if not os.path.exists(communes_path):
    url = ("https://geo.api.gouv.fr/communes"
           "?codeDepartement=65&format=geojson&geometry=contour")
    r = requests.get(url)
    with open(communes_path, 'w', encoding='utf-8') as f:
        f.write(r.text)

gdf_communes = gpd.read_file(communes_path)
gdf_communes_l93 = gdf_communes.to_crs('EPSG:2154')
gdf_communes_l93['surface_km2'] = gdf_communes_l93.geometry.area / 1e6

print(f"{len(gdf_communes_l93)} communes chargées (CRS : {gdf_communes_l93.crs})")
```

```python
# Chargement de la BAN
import gzip, shutil

csv_path = 'data/adresses-65-simplifie.csv'

if not os.path.exists(csv_path):
    os.makedirs('data', exist_ok=True)
    url_ban = "https://adresse.data.gouv.fr/data/ban/adresses/latest/csv-bal/adresses-65.csv.gz"
    gz_path = 'data/adresses-65.csv.gz'
    r = requests.get(url_ban, stream=True)
    with open(gz_path, 'wb') as f:
        for chunk in r.iter_content(8192): f.write(chunk)
    with gzip.open(gz_path, 'rb') as fi:
        with open('data/adresses-65.csv', 'wb') as fo:
            shutil.copyfileobj(fi, fo)
    df_ban = pd.read_csv('data/adresses-65.csv', sep=';', dtype=str, low_memory=False)
    for col in ['long', 'lat', 'x', 'y']:
        df_ban[col] = pd.to_numeric(df_ban[col], errors='coerce')
    colonnes = ['uid_adresse', 'numero', 'voie_nom',
                'commune_insee', 'commune_nom', 'x', 'y', 'long', 'lat']
    df_ban[colonnes].to_csv(csv_path, index=False, sep=';')

df_ban = pd.read_csv(csv_path, sep=';',
                     dtype={'code_insee': str, 'code_postal': str})
gdf_ban = gpd.GeoDataFrame(
    df_ban,
    geometry=gpd.points_from_xy(df_ban['long'], df_ban['lat']),
    crs='EPSG:4326'
)
gdf_ban_l93 = gdf_ban.to_crs('EPSG:2154')
print(f"{len(gdf_ban_l93):,} adresses chargées (CRS : {gdf_ban_l93.crs})")
```

## Prédicats binaires : tester des relations spatiales

Les prédicats binaires testent la relation entre deux géométries et
renvoient `True` ou `False`. Ils reposent sur le modèle DE-9IM
(Dimensionally Extended Nine-Intersection Model) et sont disponibles via
Shapely sur chaque géométrie individuelle, ou via GeoPandas sur des
colonnes entières.

| Prédicat          | Signification                                  |
|-------------------|------------------------------------------------|
| `a.contains(b)`   | `a` contient entièrement `b`                   |
| `a.within(b)`     | `a` est entièrement dans `b`                   |
| `a.intersects(b)` | `a` et `b` partagent au moins un point         |
| `a.touches(b)`    | `a` et `b` partagent uniquement leur frontière |
| `a.crosses(b)`    | `a` traverse `b` (pour lignes / polygones)     |
| `a.overlaps(b)`   | `a` et `b` se chevauchent partiellement        |
| `a.disjoint(b)`   | `a` et `b` ne partagent aucun point            |
| `a.covers(b)`     | `a` couvre `b` (frontière incluse)             |

### Tester des prédicats sur des géométries Shapely individuelles

```python
# Polygone représentant la zone centre de Tarbes
zone_centre = box(
    462_000, 6_237_000,   # coin bas-gauche (x_min, y_min)
    467_000, 6_242_000,   # coin haut-droit (x_max, y_max)
)   # box() crée un rectangle Shapely, en Lambert 93

# Quelques points de test
pt_dans   = Point(464_500, 6_239_000)   # dans la zone
pt_dehors = Point(450_000, 6_250_000)   # hors zone

print("pt_dans   dans zone_centre :", zone_centre.contains(pt_dans))
print("pt_dehors dans zone_centre :", zone_centre.contains(pt_dehors))
print("pt_dans   intersecte zone  :", zone_centre.intersects(pt_dans))
```

```python
# within est l'inverse de contains
print("pt_dans within zone_centre :", pt_dans.within(zone_centre))

# touches : deux rectangles qui se touchent sur un bord
rect_a = box(0, 0, 10, 10)
rect_b = box(10, 0, 20, 10)   # partage uniquement le bord x=10
rect_c = box(5, 0, 15, 10)    # se chevauche

print("\nrect_a touches rect_b :", rect_a.touches(rect_b))   # True
print("rect_a overlaps rect_c :", rect_a.overlaps(rect_c))   # True
print("rect_a intersects rect_b :", rect_a.intersects(rect_b))  # True (toucher = intersection)
```

### Appliquer des prédicats sur des colonnes GeoPandas

```python
# Quelles communes contiennent le point de Tarbes (chef-lieu) ?
tarbes_pt = Point(462_673, 6_241_493)   # coordonnées Lambert 93

masque = gdf_communes_l93.geometry.contains(tarbes_pt)
gdf_communes_l93[masque][['nom', 'code']]
```

```python
# Quelles communes sont à moins de 20 km de Tarbes (centroïde à centroïde) ?
centre_tarbes = gdf_communes_l93[gdf_communes_l93['nom'] == 'Tarbes'].geometry.centroid.iloc[0]
buffer_20km   = centre_tarbes.buffer(20_000)

masque_proches = gdf_communes_l93.geometry.centroid.within(buffer_20km)
communes_proches = gdf_communes_l93[masque_proches]

print(f"{len(communes_proches)} communes à moins de 20 km de Tarbes :")
communes_proches[['nom', 'surface_km2']].sort_values('surface_km2', ascending=False)
```

```python
# Visualiser le résultat
fig, ax = plt.subplots(figsize=(8, 8))
gdf_communes_l93.plot(ax=ax, color='#eeeeee', edgecolor='#aaaaaa', linewidth=0.4)
communes_proches.plot(ax=ax, color='#a8d8ea', edgecolor='#336699', linewidth=0.6)

# Tracer le buffer
gpd.GeoDataFrame(geometry=[buffer_20km], crs='EPSG:2154').plot(
    ax=ax, color='none', edgecolor='#336699', linewidth=1.5, linestyle='--'
)
ax.set_title("Communes à moins de 20 km de Tarbes", fontsize=12)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

## Opérations géométriques entre couches

### `overlay()` : intersection, union, différence

`overlay()` applique une opération booléenne entre deux GeoDataFrames de
polygones et renvoie un nouveau GeoDataFrame contenant les géométries
résultantes avec les attributs des deux couches.

Les opérations disponibles sont `intersection`, `union`, `difference`,
`symmetric_difference` et `identity`.

```python
# Créer une zone d'étude rectangulaire autour de Lourdes
zone_etude = gpd.GeoDataFrame(
    {'nom': ['Zone Lourdes']},
    geometry=[box(454_000, 6_226_000, 474_000, 6_242_000)],
    crs='EPSG:2154'
)
```

```python
# Intersection : garder uniquement les parties des communes dans la zone
communes_clip = gpd.overlay(gdf_communes_l93, zone_etude, how='intersection')

print(f"Communes intersectant la zone : {len(communes_clip)}")
communes_clip[['nom_1', 'surface_km2']].head(8)
```

```python
# Visualiser l'intersection
fig, axes = plt.subplots(1, 2, figsize=(13, 6))

# Avant
gdf_communes_l93.plot(ax=axes[0], color='#dce8f5', edgecolor='#888', linewidth=0.4)
zone_etude.plot(ax=axes[0], color='none', edgecolor='red', linewidth=2)
axes[0].set_title("Communes + zone d'étude", fontsize=10)
axes[0].set_axis_off()

# Après intersection
communes_clip.plot(ax=axes[1], column='nom_1', cmap='tab20',
                   edgecolor='white', linewidth=0.5)
zone_etude.plot(ax=axes[1], color='none', edgecolor='red', linewidth=2)
axes[1].set_title("Résultat de l'intersection", fontsize=10)
axes[1].set_axis_off()

plt.suptitle("overlay(how='intersection')", fontsize=12)
plt.tight_layout()
plt.show()
```

```python
# Différence : enlever la zone d'étude des communes
communes_hors_zone = gpd.overlay(gdf_communes_l93, zone_etude, how='difference')
print(f"Géométries hors zone : {len(communes_hors_zone)}")
```

### `clip()` : découper selon une emprise

`clip()` est un raccourci pour l’intersection : il découpe un
GeoDataFrame selon les contours d’un autre, en conservant les attributs
de la couche découpée. Plus simple à utiliser que `overlay` quand on
veut juste restreindre une couche à une zone d’intérêt.

```python
# Découper la BAN pour ne garder que les adresses dans la zone d'étude
ban_clip = gdf_ban_l93.clip(zone_etude)
print(f"Adresses dans la zone : {len(ban_clip):,}")
```

```python
fig, ax = plt.subplots(figsize=(8, 7))
communes_clip.plot(ax=ax, color='#f5f0e8', edgecolor='#888', linewidth=0.5)
ban_clip.plot(ax=ax, color='steelblue', markersize=1, alpha=0.4)
ax.set_title("Adresses BAN dans la zone d'étude (clip)", fontsize=12)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

## `dissolve()` : fusionner des entités par attribut

`dissolve()` fusionne les géométries qui partagent la même valeur dans
une colonne, en agrégeant les attributs numériques. C’est l’équivalent
spatial du `groupby`.

```python
# Cas simple : dissoudre toutes les communes en un seul polygone département
dept_65 = gdf_communes_l93.dissolve()
print("Type :", dept_65.geometry.geom_type.values[0])
print("Surface totale :", dept_65.geometry.area.values[0] / 1e6, "km²")
```

```python
fig, axes = plt.subplots(1, 2, figsize=(12, 6))

gdf_communes_l93.plot(ax=axes[0], color='#dce8f5', edgecolor='#888', linewidth=0.4)
axes[0].set_title("Communes individuelles", fontsize=10)
axes[0].set_axis_off()

dept_65.plot(ax=axes[1], color='#a8d8ea', edgecolor='#336699', linewidth=1)
axes[1].set_title("Contour département (dissolve)", fontsize=10)
axes[1].set_axis_off()

plt.tight_layout()
plt.show()
```

```python
# dissolve() avec agrégation d'attributs
# Créer des arrondissements fictifs pour l'exemple
# (les communes réelles n'ont pas de colonne arrondissement dans notre source)
# On regroupe par tranche de surface : petites, moyennes, grandes communes
gdf_communes_l93['taille'] = pd.cut(
    gdf_communes_l93['surface_km2'],
    bins=[0, 10, 50, 1000],
    labels=['petite', 'moyenne', 'grande']
)

# Dissolve par taille : fusion des géométries + agrégation de surface_km2
groupes = gdf_communes_l93.dissolve(by='taille', aggfunc={'surface_km2': 'sum'})
groupes['surface_km2'] = groupes['geometry'].area / 1e6
groupes[['surface_km2']]
```

```python
fig, ax = plt.subplots(figsize=(8, 8))
groupes.plot(ax=ax, column='surface_km2', cmap='YlOrBr',
             edgecolor='white', linewidth=1, legend=True,
             legend_kwds={'label': 'Surface cumulée (km²)'})
ax.set_title("Communes dissoutes par taille", fontsize=12)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

## `sjoin()` : jointure spatiale

`sjoin()` joint deux GeoDataFrames en fonction de leur relation spatiale
(et non sur une colonne commune comme `merge`). C’est l’opération la
plus fréquente en analyse géospatiale.

La syntaxe est :

```python
# gpd.sjoin(gdf_gauche, gdf_droite, how=, predicate=)
# how : 'inner' (intersection), 'left', 'right'
# predicate : 'intersects', 'contains', 'within', 'touches', 'crosses', 'overlaps'
```

### Points dans polygones : attribuer une commune à chaque adresse

```python
# Attribuer le nom de commune IGN (depuis gdf_communes_l93) à chaque adresse BAN
# C'est une vérification : la BAN a déjà une colonne nom_commune, mais elle vient
# du producteur de l'adresse. La sjoin utilise la géométrie réelle.
gdf_ban_avec_commune = gpd.sjoin(
    gdf_ban_l93[['uid_adresse', 'voie_nom', 'commune_nom', 'geometry']],
    gdf_communes_l93[['nom', 'code', 'geometry']],
    how='left',
    predicate='within'
)

# Renommer pour éviter la confusion
gdf_ban_avec_commune = gdf_ban_avec_commune.rename(
    columns={'nom': 'commune_ign', 'code': 'code_ign'}
)
gdf_ban_avec_commune[['voie_nom', 'commune_nom', 'commune_ign']].head(8)
```

```python
# Compter les adresses par commune IGN
nb_par_commune = (
    gdf_ban_avec_commune
    .groupby('commune_ign')
    .size()
    .reset_index(name='nb_adresses')
    .sort_values('nb_adresses', ascending=False)
)
nb_par_commune.head(10)
```

```python
# Joindre au GeoDataFrame communes pour cartographier
gdf_communes_nb = gdf_communes_l93.merge(
    nb_par_commune,
    left_on='nom', right_on='commune_ign',
    how='left'
)
gdf_communes_nb['nb_adresses'] = gdf_communes_nb['nb_adresses'].fillna(0).astype(int)

fig, ax = plt.subplots(figsize=(8, 8))
gdf_communes_nb.plot(
    ax=ax,
    column='nb_adresses',
    cmap='YlOrRd',
    scheme='quantiles',
    k=5,
    edgecolor='white',
    linewidth=0.3,
    legend=True,
    legend_kwds={
        'title': "Nb adresses",
        'loc': 'lower left',
        'fontsize': 8,
    }
)
ax.set_title("Nombre d'adresses BAN par commune (Hautes-Pyrénées)", fontsize=12)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

### `sjoin_nearest()` : trouver le voisin le plus proche

`sjoin_nearest()` joint chaque élément d’un GeoDataFrame à l’élément le
plus proche d’un autre GeoDataFrame. Utile pour trouver la commune la
plus proche d’un point, ou l’adresse la plus proche d’une station.

```python
# Créer quelques points de référence (sommets pyrénéens)
sommets = gpd.GeoDataFrame(
    {
        'nom'      : ['Pic du Midi', 'Vignemale', 'Pic de Néouvielle', 'Pic Long'],
        'altitude' : [2877, 3298, 3091, 3192],
    },
    geometry=[
        Point(466_006, 6_222_356),
        Point(454_800, 6_210_000),
        Point(467_500, 6_215_000),
        Point(463_000, 6_212_000),
    ],
    crs='EPSG:2154'
)
```

```python
# Trouver la commune la plus proche de chaque sommet
sommets_communes = gpd.sjoin_nearest(
    sommets,
    gdf_communes_l93[['nom', 'geometry']],
    how='left',
    distance_col='dist_commune_m'
)

sommets_communes[['nom_left', 'altitude', 'nom_right', 'dist_commune_m']].rename(
    columns={'nom_left': 'sommet', 'nom_right': 'commune_proche'}
)
```

## Jointure attributaire avec `merge()`

Avant d’aborder le `merge()`, nous allons récupérer les données de
population des communes des Hautes-Pyrénées, que nous utiliserons
ensuite pour enrichir notre jeu de données principal.

**1 : Télécharger les données**

À l’aide de la bibliothèque `requests`, effectuez une requête GET sur
l’URL suivante :
https://geo.api.gouv.fr/communes?codeDepartement=65&fields=code,nom,population&format=json

Sauvegardez la réponse dans `data/population-65.json`. Comme c’est du
`json`, vous pouvez utiliser la méthode `.json()` sur l’object retourné
par la requête.

**2 : Construire le DataFrame**

Chargez le fichier `data/population-65.json` et créez le DataFrame,
`df_pop`. Simplifier ce DataFrame pour ne conserver que les colonnes
`code`, `nom` et `population`.

`merge()` joint deux DataFrames sur une colonne commune, comme un `JOIN`
SQL. Pas de géométrie impliquée : c’est une jointure de tables.

```python
# Joindre la population au GeoDataFrame communes
# (le GeoJSON source contient déjà une colonne population -> on la supprime
#  pour illustrer la jointure attributaire)
gdf_pop = gdf_communes_l93.drop(columns=['population'], errors='ignore').merge(
    df_pop[['code', 'population']],
    on='code',
    how='left'
)

print(f"Communes avec population renseignée : {gdf_pop['population'].notna().sum()}")
gdf_pop[['nom', 'surface_km2', 'population']].sort_values(
    'population', ascending=False
).head(10)
```

```python
# Votre réponse
# Étape 1: Télécharger les données
import requests
import json
import os
# créer dossier si nécessaire
os.makedirs('data', exist_ok=True)
url = "https://geo.api.gouv.fr/communes?codeDepartement=65&fields=code,nom,population&format=json"
r = requests.get(url)
# sauvegarde fichier JSON
with open('data/population-65.json', 'w', encoding='utf-8') as f:
    json.dump(r.json(), f, ensure_ascii=False)
```

```python
# Votre réponse
# Étape 2: Créer le DataFrame
# charger JSON
with open('data/population-65.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
df_pop = pd.DataFrame(data)
# garder seulement les colonnes utiles
df_pop = df_pop[['code', 'nom', 'population']]
df_pop.head()
```

```python
# Votre réponse
# Étape 3: Faire la jointure
gdf_pop = gdf_communes_l93.drop(columns=['population'], errors='ignore').merge(
    df_pop[['code', 'population']],
    on='code',
    how='left'
)
print(f"Communes avec population renseignée : {gdf_pop['population'].notna().sum()}")
gdf_pop[['nom', 'surface_km2', 'population']].sort_values(
    'population', ascending=True
).head(10)
```

```python
# Calculer la densité de population réelle
gdf_pop['densite_hab_km2'] = gdf_pop['population'] / gdf_pop['surface_km2']

fig, ax = plt.subplots(figsize=(8, 8))
gdf_pop.plot(
    ax=ax,
    column='densite_hab_km2',
    cmap='RdPu',
    scheme='quantiles',
    k=6,
    edgecolor='white',
    linewidth=0.3,
    legend=True,
    missing_kwds={'color': '#cccccc'},  # couleur des communes sans données
    legend_kwds={
        'title': "Densité (hab/km²)",
        'loc': 'lower left',
        'fontsize': 8,
    }
)
ax.set_title("Densité de population (Hautes-Pyrénées)", fontsize=12)
ax.set_axis_off()
plt.tight_layout()
plt.show()
```

## Opérations géométriques sur des géométries individuelles

En plus des opérations entre couches, Shapely expose des opérations
entre deux géométries individuelles : `union`, `intersection`,
`difference`, `symmetric_difference`.

```python
# Récupérer les géométries de deux communes voisines
tarbes_geom  = gdf_communes_l93[gdf_communes_l93['nom'] == 'Tarbes'].geometry.iloc[0]
lourdes_geom = gdf_communes_l93[gdf_communes_l93['nom'] == 'Lourdes'].geometry.iloc[0]
```

```python
# Union : fusionner les deux communes en une seule géométrie
union = tarbes_geom.union(lourdes_geom)
print("Type union :", union.geom_type)
```

```python
# Intersection : zone partagée (devrait être vide pour deux communes non contiguës)
inter = tarbes_geom.intersection(lourdes_geom)
print("Type intersection :", inter.geom_type)
print("Aire intersection :", inter.area, "m²")
```

```python
# Différence : Tarbes moins Lourdes (ici = Tarbes entière car pas de chevauchement)
diff = tarbes_geom.difference(lourdes_geom)
print("Aire différence :", round(diff.area / 1e6, 2), "km²")
print("Aire Tarbes     :", round(tarbes_geom.area / 1e6, 2), "km²")
```

```python
# Enveloppe convexe (convex hull)
hull = tarbes_geom.convex_hull
print("Aire convex hull :", round(hull.area / 1e6, 2), "km²")
print("Aire réelle      :", round(tarbes_geom.area / 1e6, 2), "km²")
```

```python
# Simplification de géométrie (réduire le nombre de sommets)
simplifiee = tarbes_geom.simplify(tolerance=200)   # tolérance en mètres
print(f"Sommets original   : {len(tarbes_geom.exterior.coords)}")
print(f"Sommets simplifié  : {len(simplifiee.exterior.coords)}")
```

## Exercice : analyse spatiale sur les Hautes-Pyrénées

**Question 1** Créer une zone tampon de 10 km autour du contour de
Tarbes (pas de son centroïde, mais de sa géométrie complète). Quelles
communes des Hautes-Pyrénées ont leur centroïde dans cette zone ?
Afficher leur nom et leur distance au contour de Tarbes (en km).

```python
# À vous !
# 1. géométrie de Tarbes (polygone)
tarbes_geom = gdf_communes_l93[gdf_communes_l93['nom'] == 'Tarbes'].geometry.iloc[0]
# 2. buffer de 10 km
buffer_10km = tarbes_geom.buffer(10000)   # en mètres (CRS Lambert 93)
# 3. centroïdes des communes
gdf_communes_l93['centroide'] = gdf_communes_l93.geometry.centroid
# 4. sélection des communes dans le buffer
masque = gdf_communes_l93['centroide'].within(buffer_10km)
communes_proches = gdf_communes_l93[masque].copy()
# 5. distance au contour de Tarbes (en km)
communes_proches['distance_km'] = communes_proches['centroide'].distance(tarbes_geom) / 1000
# 6. résultat
communes_proches[['nom', 'distance_km']].sort_values('distance_km')
```

**Question 2** Utiliser `sjoin()` pour compter le nombre d’adresses BAN
par commune. Joindre le résultat à `gdf_communes_l93` et créer une
colonne `densite_adresses` (adresses par km²). Quelles sont les 5
communes les plus denses en adresses ?

```python
# À vous !
# sjoin + comptage + densité + top 5
gdf_result = (
    gpd.sjoin(
        gdf_ban_l93,
        gdf_communes_l93[['nom', 'surface_km2', 'geometry']],
        how='left',
        predicate='within'
    )
    .groupby('nom') 
    .size()
    .reset_index(name='nb_adresses')
    .merge(gdf_communes_l93[['nom', 'surface_km2']], on='nom')
)
# calcul densité
gdf_result['densite_adresses'] = gdf_result['nb_adresses'] / gdf_result['surface_km2']
# top 5 communes plus denses 
gdf_result.sort_values('densite_adresses', ascending=False).head(5)
```

**Question 3** Découper (`clip`) la BAN pour ne garder que les adresses
dans un rayon de 5 km autour du centroïde de Lourdes. Combien d’adresses
sont dans cette zone ? Tracer une carte avec le buffer et les adresses.

```python
# À vous ! 
# centroïde de Lourdes
centre_lourdes = gdf_communes_l93[gdf_communes_l93['nom'] == 'Lourdes'].geometry.centroid.iloc[0]
# buffer 5 km
buffer_5km = centre_lourdes.buffer(5000)
# découper les adresses BAN
ban_clip = gdf_ban_l93.clip(buffer_5km)
# nombre d’adresses
nb_adresses = len(ban_clip)
print(nb_adresses)
# carte
fig, ax = plt.subplots(figsize=(10, 10))

gdf_communes_l93.plot(ax=ax, color='lightgrey', edgecolor='white')
gpd.GeoDataFrame(geometry=[buffer_5km], crs='EPSG:2154').plot(
    ax=ax, edgecolor='blue', facecolor='none', linewidth=2
)
ban_clip.plot(ax=ax, color='red', markersize=1, alpha=0.5)
ax.set_title("Adresses à moins de 5 km de Lourdes")
ax.set_axis_off()
plt.show()
```

**Question 4** Dissoudre `gdf_communes_l93` en une seule géométrie
représentant le contour du département. Calculer le périmètre total en
km. Exporter le résultat en GeoPackage (`dept-65-contour.gpkg`).

```python
# 1. Dissolve
dept_65 = gdf_communes_l93.dissolve()
# 2. garder UNE seule geometry
dept_65 = dept_65.set_geometry('geometry')
# 3. supprimer autres colonnes geometry si besoin
dept_65 = dept_65.loc[:, dept_65.columns.str.startswith('geometry') | (dept_65.columns == 'geometry')]
# 4. périmètre
perimetre_km = dept_65.geometry.length.iloc[0] / 1000
print(f"Périmètre total : {perimetre_km:.2f} km")
# 5. export correct
dept_65.to_file('dept-65-contour.gpkg', driver='GPKG')
```

**Question 5** Joindre les données de population (`df_pop`) et les
adresses BAN (`nb_par_commune`) aux communes. Calculer pour chaque
commune : - la densité de population (hab/km²) - le ratio adresses par
habitant

Identifier les communes dont le ratio adresses/habitant est supérieur à
1 (càd là où il y plus d’adresses que d’habitants (anomalies ou zones
industrielles)).

```python
import geopandas as gpd
import numpy as np

# Charger fichier
communes = gpd.read_file("communes-65-adresses.gpkg")

# Vérifier projections (important pour surface)
communes = communes.to_crs(2154)  # Lambert-93

# Jointure population
df = communes.merge(df_pop, on="INSEE_COM", how="left")

# Surface km²
df["surface_km2"] = df.geometry.area / 1_000_000

# Densité
df["densite_hab_km2"] = df["population"] / df["surface_km2"]

# ⚠️ Adapter le nom du champ adresses !
# Exemple :
df["ratio_addr_hab"] = df["nb_adresses"] / df["population"]

# Nettoyage
df["ratio_addr_hab"].replace([np.inf, -np.inf], np.nan, inplace=True)

# Filtrer anomalies
communes_anomalies = df[df["ratio_addr_hab"] > 1]

# Résultat
communes_anomalies[[
    "INSEE_COM",
    "population",
    "nb_adresses",
    "ratio_addr_hab"
]]
```

**Question 6** Trouver, pour chaque sommet du GeoDataFrame `sommets`, la
commune dont le **contour** (pas le centroïde) est le plus proche.
Utiliser `sjoin_nearest`. Comparer avec la question du module A2
(commune contenant le sommet).

```python
# À vous !
```

## Récapitulatif des fonctions clés

| Fonction / Méthode | Rôle |
|------------------------------------|------------------------------------|
| `geom_a.contains(geom_b)` | `a` contient entièrement `b` |
| `geom_a.within(geom_b)` | `a` est entièrement dans `b` |
| `geom_a.intersects(geom_b)` | `a` et `b` partagent au moins un point |
| `geom_a.touches(geom_b)` | `a` et `b` partagent uniquement leur frontière |
| `geom_a.overlaps(geom_b)` | `a` et `b` se chevauchent partiellement |
| `gdf.geometry.contains(geom)` | Masque booléen sur une colonne entière |
| `gdf.geometry.within(geom)` | Masque booléen (points dans un polygone) |
| `gpd.overlay(gdf1, gdf2, how=)` | Opération booléenne entre deux couches |
| `gdf.clip(masque)` | Découper selon une emprise ou un polygone |
| `gdf.dissolve(by=, aggfunc=)` | Fusionner les géométries par attribut |
| `gpd.sjoin(gdf1, gdf2, how=, predicate=)` | Jointure spatiale |
| `gpd.sjoin_nearest(gdf1, gdf2, distance_col=)` | Jointure au voisin le plus proche |
| `gdf.merge(df, on=, how=)` | Jointure attributaire (pas de géométrie) |
| `geom.union(autre)` | Union de deux géométries |
| `geom.intersection(autre)` | Intersection de deux géométries |
| `geom.difference(autre)` | Différence de deux géométries |
| `geom.convex_hull` | Enveloppe convexe |
| `geom.simplify(tolerance)` | Simplification de géométrie |
| `shapely.geometry.box(xmin, ymin, xmax, ymax)` | Créer un rectangle Shapely |
