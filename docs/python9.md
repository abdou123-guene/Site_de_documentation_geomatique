# Inspection des données, Prétraitement et Visualisation

L’objectif de ce notebook est d’inspecter les statistiques temporelles
de chaque parcelle, de les traiter et de visualiser des informations
utiles sur les données.

```python
import geopandas as gpd
import numpy as np
```

```python
# Lecture du geodataframe ndvi median
TIMESERIES_PATH = './sentinel2_data/time_series'
gdf_ndvi_median = gpd.read_file(TIMESERIES_PATH + '/T31TCJ_ndvi_median.shp')
```

## Inspection du GeoDataframe

Premièrement nous allons lister les colonnes.

```python
# ecrivez le code pour lister les colonnes
# gdf_columns_name = 
gdf_columns_name = list(gdf_ndvi_median.columns)
print(gdf_columns_name)
```

Ensuite, nous allons sélectionner uniquement les colonnes contenant le
NDVI. Ce sont les colonnes dont le nom est une date sous forme
`YYYYMMDD`.

Nous allons donc garder les colonnes dont le nom est de taille 8 et
aussi est un digit.

```python
# filter pour ne garder que les colonnes dont le nom est de type YYYYMMDD
# list_ndvi_columns = 
list_ndvi_columns = [col for col in gdf_columns_name if len(col) == 8 and col.isdigit()]
print(list_ndvi_columns)
```

## Analyse des valeurs manquantes (NaN)

Les valeurs manquantes (NaN) correspondent aux pixels masqués par les
nuages lors du prétraitement. Un taux élevé de NaN sur une date signifie
que cette date est trop nuageuse pour être exploitable.

Commençons par compter le nombre total de NaN sur l’ensemble du tableau
(parcelles x dates) :

```python
total = gdf_ndvi_median[list_ndvi_columns].size
nb_nans = np.isnan(gdf_ndvi_median[list_ndvi_columns].values).sum()
print(f"NaN : {nb_nans} / {total} ({100*nb_nans/total:.1f}%)")
```

Ce taux global est élevé. Ca ne semble pas anormal : nous sommes en zone
tempérée où la couverture nuageuse est fréquente, notamment en hiver.

Regardons maintenant la répartition des NaN par date, pour identifier
les acquisitions les plus nuageuses :

```python
import pandas as pd

df_nans = pd.DataFrame()
df_nans['date'] = list_ndvi_columns
df_nans['nb_nans'] = np.sum(np.isnan(gdf_ndvi_median[list_ndvi_columns].values), axis=0)
# axis=0 : on somme sur les lignes (parcelles), ce qui donne un résultat par colonne (date)
print(df_nans)
# version modifier et complétée en bas
```

```python
# modifiez le code pour rajouter une colonne `pct_nans` contenant le pourcentage par date
import pandas as pd
import numpy as np

df_nans = pd.DataFrame()

# dates
df_nans['date'] = list_ndvi_columns

# récupération des valeurs NDVI
values = gdf_ndvi_median[list_ndvi_columns].values

# ✅ CORRECTION : compter les -9999 (nodata)
df_nans['nb_nans'] = np.sum(values == -9999, axis=0)

# ✅ calcul du %
df_nans['pct_nans'] = df_nans['nb_nans'] / gdf_ndvi_median.shape[0] * 100

# affichage
print(df_nans)
```

On observe que les pourcentages de NaN sont soit très faibles (\< 10 %),
soit très élevés (\> 85 %), avec peu de valeurs intermédiaires.

Comment expliquez-vous cette distribution bimodale ?

Visualisons ces résultats. Avec de nombreuses dates, les barres
horizontales sont plus lisibles que les barres verticales :

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(10, 10))
ax.barh(df_nans['date'], df_nans['nb_nans'] / gdf_ndvi_median.shape[0])
ax.set_xlabel("Part de parcelles avec NaN")
ax.set_title("Proportion de valeurs manquantes par date")
```

Réponse: La distribution est bimodale car une image Sentinel‑2 est soit globalement peu nuageuse, soit fortement couverte par des nuages. Lorsque les conditions météorologiques sont favorables, la majorité des parcelles sont bien observées, ce qui entraîne un faible taux de valeurs manquantes. À l’inverse, en présence de forte couverture nuageuse, la plupart des pixels sont masqués, ce qui génère un taux élevé de valeurs nodata sur l’ensemble des parcelles.

On peut également obtenir une visualisation interactive avec Plotly.
Plotly reconnaît automatiquement le format `YYYY-MM-DD` comme une date
et adapte l’axe en conséquence, d’où le reformatage ci-dessous :

```python
import plotly.express as px

dates = [x[0:4]+'-'+x[4:6]+'-'+x[6:] for x in df_nans['date']]
df_nans['date_plotly_format'] = dates
px.bar(df_nans, x="date_plotly_format", y="nb_nans", height=400,
       title="Distribution des NaN par date")
```

## Suppressions des dates avec trop de valeurs manquantes

Lorsqu’une date a trop de valeurs manquantes, elle ne sera pas
utilisable par les algorithmes et peut causer des problèmes. Nous allons
supprimer les dates avec plus de 60% de NaN

```python
# nous sélectionnons d'abord les dates avec trop de nuages :

selected_dates = list(df_nans.loc[df_nans['pct_nans'] >= 60]['date'])
print(len(selected_dates))
```

```python
import os
CLEANED_TIMESERIES_PATH = './sentinel2_data/cleaned_time_series'
os.makedirs(CLEANED_TIMESERIES_PATH, exist_ok=True)
```

```python
cleaned_gdf = gdf_ndvi_median.drop(selected_dates, axis=1)
cleaned_cols = cleaned_gdf.columns
cleaned_gdf.shape

cleaned_gdf.to_file(f"{CLEANED_TIMESERIES_PATH}/T31TCJ_median_ndvi.shp")
```

## Affichage de la série temporelle

Avant de passer à la classification, il est utile de visualiser la série
temporelle du NDVI pour quelques parcelles afin de vérifier la cohérence
des données et de se familiariser avec leur forme.

Chaque parcelle possède désormais `len(list_clean_dates)` valeurs de
NDVI médian, une par date conservée. On s’attend à observer une courbe
saisonnière : le NDVI augmente au printemps avec la croissance de la
végétation, atteint un pic en été, puis diminue à l’automne.

```python
from datetime import datetime

# conversion des dates en format datetime pour l'axe temporel
list_clean_dates = [col for col in cleaned_cols if len(col) == 8 and col.isdigit()]
list_clean_dates_formatted = [datetime.strptime(x, '%Y-%m-%d') 
                               for x in [x[0:4]+'-'+x[4:6]+'-'+x[6:] for x in list_clean_dates]]

# choix de la parcelle à afficher (modifiez cet index pour en explorer d'autres)
parcel_idx = 900
y = list(cleaned_gdf.iloc[parcel_idx][list_clean_dates].values)

px.line(x=list_clean_dates_formatted, y=y,
        title=f"Série temporelle NDVI pour parcelle {parcel_idx}",
        labels={"x": "Date", "y": "NDVI médian"})
```

Modifiez la variable `parcel_idx` pour observer d’autres parcelles.
Observez-vous des formes de courbes différentes selon les parcelles ?
Ces différences de comportement saisonnier sont précisément ce que les
algorithmes de classification vont exploiter.
