# Reconstruction des données manquantes (imputation)

L’objectif de ce notebook est d’explorer différentes méthodes
d’imputation pour reconstruire les valeurs manquantes dans les séries
temporelles NDVI.

## Qu’est-ce que l’imputation ?

L’imputation désigne l’ensemble des techniques qui consistent à estimer
et remplacer les valeurs manquantes dans un jeu de données.

L’objectif n’est pas de retrouver la “vraie” valeur (ce qui est par
définition inconnue) mais de produire une valeur plausible qui préserve
les structures statistiques des données et permet aux algorithmes
d’apprentissage automatique de fonctionner correctement.

Dans notre cas, les valeurs manquantes proviennent des pixels masqués
par les nuages lors du prétraitement. Chaque NaN dans la série
temporelle d’une parcelle signifie que le NDVI n’a pas pu être mesuré à
cette date. Or la plupart des algorithmes de classification (Random
Forest, SVM, etc.) ne savent pas gérer les NaN nativement. Il faut donc
les combler avant l’entraînement.

Il existe de nombreuses stratégies d’imputation, allant de la plus
simple à la plus sophistiquée :

- interpolation : on estime la valeur manquante à partir des valeurs
  voisines dans le temps (avant et après la lacune).
- K plus proches voisins (K-NN) : on cherche les parcelles les plus
  similaires et on utilise leurs valeurs à la date manquante.
- MICE (Multiple Imputation by Chained Equations) : on modélise chaque
  variable manquante comme une fonction des autres variables, en itérant
  jusqu’à convergence.

Nous allons comparer ces méthodes visuellement et les évaluer.

```python
import geopandas as gpd
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from datetime import datetime
import plotly.express as px
```

Chargeons les séries temporelles NDVI nettoyées produites dans le
notebook précédent et récupérons la liste des colonnes correspondant à
des dates.

```python
CLEANED_TIMESERIES_PATH = './sentinel2_data/cleaned_time_series'

cleaned_gdf = gpd.read_file(f'{CLEANED_TIMESERIES_PATH}/T31TCJ_median_ndvi.shp')
cleaned_cols = cleaned_gdf.columns

list_clean_dates = [col for col in cleaned_cols if len(col) == 8 and col.isdigit()]

print(cleaned_gdf.shape)
```

## Visualisation d’une série temporelle

Avant d’appliquer les méthodes d’imputation, visualisons la série
temporelle du NDVI médian pour une parcelle. Les valeurs manquantes
(NaN) apparaissent comme des ruptures dans la courbe. C’est cette partie
que les méthodes d’imputation vont combler.

```python
# conversion des dates en format datetime pour l'axe temporel
list_clean_dates_formatted = [x[0:4]+'-'+x[4:6]+'-'+x[6:] for x in list_clean_dates]
list_clean_dates_formatted = [datetime.strptime(x, '%Y-%m-%d') for x in list_clean_dates_formatted]

# choix de la parcelle à visualiser (modifiez cet index pour en explorer d'autres)
miss_ind = 1000
y_missing = list(cleaned_gdf.iloc[miss_ind][list_clean_dates].values)

# création de la série temporelle pandas (index = dates)
dti = pd.to_datetime(pd.Series(list_clean_dates))
ts_y_missing = pd.Series(y_missing, index=dti)

fig, ax = plt.subplots()
ax.plot(ts_y_missing, marker='x')
ax.set_xlabel("Date")
ax.set_ylabel("NDVI médian")
ax.set_title(f"Série temporelle NDVI pour parcelle {miss_ind}")
_ = plt.xticks(rotation=50)
plt.tight_layout()
plt.show()
```

## Interpolation linéaire

La méthode la plus simple pour combler les lacunes est l’interpolation
linéaire : on suppose que le NDVI évolue de façon linéaire entre la
dernière valeur connue avant la lacune et la première valeur connue
après.

La fonction `interpolate(axis=1)` de Pandas applique cette logique ligne
par ligne, c’est-à-dire le long du temps pour chaque parcelle.

```python
interpolated_gdf = cleaned_gdf.copy()
# remplacer -9999 par NaN
interpolated_gdf[list_clean_dates] = interpolated_gdf[list_clean_dates].replace(-9999, np.nan)
# interpolation
interpolated_gdf[list_clean_dates] = interpolated_gdf[list_clean_dates].interpolate(axis=1)
# vérifier
print(np.isnan(interpolated_gdf[list_clean_dates].values).sum())
```

```python
y_interpolated = interpolated_gdf.iloc[miss_ind][list_clean_dates].values
ts_y_interpolated = pd.Series(y_interpolated, index=dti, dtype=float)

fig, ax = plt.subplots()
ax.plot(ts_y_missing, marker='x', label='original')
ax.plot(ts_y_interpolated, marker='.', label='interpolation linéaire')
ax.set_xlabel("Date")
ax.set_ylabel("NDVI médian")
ax.set_title(f"Interpolation linéaire pour parcelle {miss_ind}")
_ = plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

## Interpolation temporelle : prise en compte de l’irrégularité des acquisitions

L’interpolation linéaire appliquée précédemment suppose implicitement
que les dates sont régulièrement espacées : elle attribue le même poids
à chaque intervalle entre deux acquisitions, qu’il dure 3 jours ou 3
semaines.

Or les acquisitions Sentinel-2 sont irrégulières : certaines dates sont
très proches (2-3 jours d’écart) et d’autres très éloignées (plusieurs
semaines), notamment après suppression des dates trop nuageuses.

Pour tenir compte de ces intervalles réels, Pandas propose
`method='time'` sur une Serie indexée par des dates : la valeur imputée
est proportionnelle à la durée écoulée depuis la dernière valeur connue.

Créez la variable `ts_y_timely_interpolated` à l’aide de l’option
`method='time'`.

```python
# ts_y_timely_interpolated = 
# remplacer -9999 par NaN
ts_y_missing = ts_y_missing.replace(-9999, np.nan)
# interpolation basée sur le temps réel
ts_y_timely_interpolated = ts_y_missing.interpolate(method='time')
# affichage
plt.figure()
plt.plot(ts_y_missing, marker='x', label='original')
plt.plot(ts_y_timely_interpolated, marker='o', label='interpolé (time)')
plt.xlabel("Date")
plt.ylabel("NDVI médian")
plt.title(f"Interpolation temporelle pour parcelle {miss_ind}")
plt.legend()
plt.xticks(rotation=50)
plt.tight_layout()
plt.show()
```

Ensuite, en vous inspirant du graphique précédent, dessiner sur le même
graphe `ts_y_missing` et `ts_y_interpolated` afin de pouvoir les
comparer

```python
# a vous
plt.figure()
# courbe originale (avec trous)
plt.plot(ts_y_missing, marker='x', label='Original (avec trous)')
# courbe interpolée (simple linéaire classique)
ts_y_interpolated = ts_y_missing.interpolate()
plt.plot(ts_y_interpolated, marker='o', label='Interpolé')
# mise en forme
plt.xlabel("Date")
plt.ylabel("NDVI médian")
plt.title(f"Comparaison interpolation pour parcelle {miss_ind}")
plt.legend()
plt.xticks(rotation=50)
plt.tight_layout()
plt.show()
```

Observez-vous une différence entre les deux interpolations ? Pourquoi la
méthode `time` peut-elle donner un résultat différent ?

## Imputation par K plus proches voisins (K-NN)

Les méthodes d’interpolation vues précédemment n’exploitent que la série
temporelle de la parcelle elle-même. L’imputation **K-NN** (K plus
proches voisins) adopte une approche différente : elle s’appuie sur les
**autres parcelles** du jeu de données pour estimer la valeur manquante.

Le principe est le suivant : pour une parcelle avec un NaN à une date
donnée, on cherche les `k` parcelles dont le profil temporel est le plus
similaire, puis on calcule une moyenne pondérée de leurs valeurs à cette
date. Plus une parcelle voisine est similaire, plus elle contribue à
l’estimation.

<figure>
<img src="attachment:img/knn_imputation_explained.png"
alt="knn_imputation_explained.png" />
<figcaption aria-hidden="true">knn_imputation_explained.png</figcaption>
</figure>

Par défaut, `KNNImputer` utilise `k=5` voisins. Vous pouvez modifier ce
paramètre via `KNNImputer(n_neighbors=10)` et observer l’impact sur le
résultat.

```python
import sys
sys.path.append('/home/idgeo/.local/lib/python3.12/site-packages')
from sklearn.impute import KNNImputer
```

```python
from sklearn.impute import KNNImputer
import numpy as np
knn_impute = KNNImputer()
gdf_knn_impute = cleaned_gdf.copy()
#  IMPORTANT : convertir nodata en NaN
gdf_knn_impute[list_clean_dates] = gdf_knn_impute[list_clean_dates].replace(-9999, np.nan)
print('NaN avant imputation :', np.isnan(gdf_knn_impute[list_clean_dates].values).sum())
#  imputation KNN
gdf_knn_impute[list_clean_dates] = knn_impute.fit_transform(gdf_knn_impute[list_clean_dates])
print('NaN après imputation :', np.isnan(gdf_knn_impute[list_clean_dates].values).sum())
# série pour affichage
y_knn = gdf_knn_impute.iloc[miss_ind][list_clean_dates].values
ts_y_knn = pd.Series(y_knn, index=dti, dtype=float)
```

```python
fig, ax = plt.subplots()
ax.plot(ts_y_missing, marker='x', label='original')
ax.plot(ts_y_interpolated, marker='.', label='interpolation linéaire')
ax.plot(ts_y_timely_interpolated, marker='.', label='interpolation (time)')
ax.plot(ts_y_knn, marker='.', label='knn')
ax.set_xlabel("Date")
ax.set_ylabel("NDVI médian")
ax.set_title(f"Imputation K-NN pour parcelle {miss_ind}")
_ = plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

Les méthodes d’interpolation linéaire et temporelle produisent des résultats très similaires car elles reposent sur la continuité temporelle du NDVI. En revanche, l’imputation KNN donne des résultats différents car elle s’appuie sur la similarité entre parcelles et non sur l’évolution temporelle, ce qui peut altérer la forme saisonnière du signal.

## K-NN avec normalisation

Le K-NN repose sur le calcul de distances entre parcelles. Si les
valeurs de certaines dates sont systématiquement plus élevées que
d’autres, elles auront une influence disproportionnée sur le calcul des
voisins (même si cette différence est simplement due à la saisonnalité
(NDVI plus élevé en été)).

<figure>
<img src="attachment:img/knn_normalisation_explained.png"
alt="knn_normalisation_explained.png" />
<figcaption
aria-hidden="true">knn_normalisation_explained.png</figcaption>
</figure>

Il est donc recommandé de normaliser les données avant l’imputation,
pour ramener toutes les dates sur la même échelle. Nous utilisons le
`MinMaxScaler` de scikit-learn qui ramène toutes les valeurs dans
`[0, 1]`.

Le processus se déroule en trois étapes :

1.  **Normaliser** les données avec `fit_transform`
2.  **Imputer** les NaN avec `KNNImputer`
3.  **Revenir à l’échelle d’origine** avec `inverse_transform`

Complétez le code suivant :

```python
from sklearn.preprocessing import MinMaxScaler
from sklearn.impute import KNNImputer
import numpy as np
Norm = MinMaxScaler()
knn_impute = KNNImputer()
gdf_knn_impute_norm = cleaned_gdf.copy()
#  important : remplacer -9999 par NaN
gdf_knn_impute_norm[list_clean_dates] = gdf_knn_impute_norm[list_clean_dates].replace(-9999, np.nan)
#  étape 1 : normaliser
gdf_knn_impute_norm[list_clean_dates] = Norm.fit_transform(gdf_knn_impute_norm[list_clean_dates])
#  étape 2 : imputer
gdf_knn_impute_norm[list_clean_dates] = knn_impute.fit_transform(gdf_knn_impute_norm[list_clean_dates])
#  étape 3 : revenir à l'échelle d'origine
gdf_knn_impute_norm[list_clean_dates] = Norm.inverse_transform(gdf_knn_impute_norm[list_clean_dates])
#  vérification
print(np.isnan(gdf_knn_impute_norm[list_clean_dates].values).sum())
# série pour affichage
y_knn_norm = gdf_knn_impute_norm.iloc[miss_ind][list_clean_dates].values
ts_y_knn_norm = pd.Series(y_knn_norm, index=dti, dtype=float)
```

```python
fig, ax = plt.subplots()
ax.plot(ts_y_missing, marker='x', label='original')
ax.plot(ts_y_interpolated, marker='.', label='interpolation linéaire')
ax.plot(ts_y_timely_interpolated, marker='.', label='interpolation (time)')
ax.plot(ts_y_knn, marker='.', label='knn')
ax.plot(ts_y_knn_norm, marker='.', label='knn (normalisé)')
ax.set_xlabel("Date")
ax.set_ylabel("NDVI médian")
ax.set_title(f"K-NN avec et sans normalisation pour la parcelle {miss_ind}")
_ = plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

Les deux variantes K-NN donnent-elles des résultats très différents ? En
pratique, l’impact de la normalisation dépend des données : si les
valeurs NDVI sont du même ordre de grandeur sur toutes les dates, la
différence sera faible. Elle peut être plus marquée si certaines dates
ont des distributions très différentes des autres.

**Réponse**

Les deux variantes de l’imputation K‑NN (avec et sans normalisation) produisent des résultats différents, mais ces différences peuvent être plus ou moins importantes selon les données. Lorsque les valeurs de NDVI sont homogènes et de même ordre de grandeur sur toutes les dates, l’impact de la normalisation reste limité et les deux méthodes donnent des résultats proches. En revanche, si certaines dates présentent des écarts de distribution plus importants, l’absence de normalisation peut introduire des biais dans le calcul des distances, ce qui rend l’imputation moins fiable. Dans ce cas, l’utilisation d’une normalisation améliore la qualité des résultats.

Les méthodes d’interpolation linéaire et temporelle produisent des résultats très proches et cohérents car elles respectent la structure temporelle du NDVI. En revanche, l’imputation KNN sans normalisation introduit des biais importants liés aux différences d’échelle des variables. L’utilisation d’une normalisation améliore les résultats de KNN, mais cette méthode reste moins adaptée aux séries temporelles car elle ne prend pas en compte la dynamique temporelle des données.

```python
# sauvegarde du résultat pour les notebooks suivants
print(gdf_knn_impute_norm.shape)
gdf_knn_impute_norm.to_file(f'{CLEANED_TIMESERIES_PATH}/T31TCJ_median_ndvi_knn_impute.shp')
```

## Imputation MICE (Iterative Imputer)

MICE (*Multiple Imputation by Chained Equations*) est une méthode plus
sophistiquée que le K-NN. Au lieu de chercher des parcelles similaires,
elle modélise chaque date avec des valeurs manquantes comme une
**fonction des autres dates** : par exemple, le NDVI manquant en juillet
est estimé à partir des NDVI connus en avril, juin, août, etc.

<figure>
<img src="attachment:img/mice_imputation_explained.png"
alt="mice_imputation_explained.png" />
<figcaption
aria-hidden="true">mice_imputation_explained.png</figcaption>
</figure>

Le processus est itératif : à chaque itération, toutes les colonnes sont
imputées tour à tour en utilisant les valeurs (éventuellement imputées)
des autres colonnes, jusqu’à convergence. Cela permet à MICE de capturer
des relations complexes entre les dates, là où le K-NN se contente de
moyenner des parcelles voisines.

> **Note** : `IterativeImputer` est encore en phase expérimentale dans
> scikit-learn, ce qui explique l’import inhabituel
> `from sklearn.experimental import enable_iterative_imputer`.

Comme pour le K-NN, nous normalisons les données avant l’imputation :

```python
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer

Norm = MinMaxScaler()
mice_impute = IterativeImputer()
gdf_mice = cleaned_gdf.copy()

gdf_mice[list_clean_dates] = Norm.fit_transform(gdf_mice[list_clean_dates])
gdf_mice[list_clean_dates] = mice_impute.fit_transform(gdf_mice[list_clean_dates])
gdf_mice[list_clean_dates] = Norm.inverse_transform(gdf_mice[list_clean_dates])

print('NaN restants :', np.isnan(gdf_mice[list_clean_dates].values).sum())

y_mice = gdf_mice.iloc[miss_ind][list_clean_dates].values
ts_y_mice = pd.Series(y_mice, index=dti, dtype=float)

fig, ax = plt.subplots()
ax.plot(ts_y_missing, marker='x', label='original')
ax.plot(ts_y_interpolated, marker='.', label='interpolation linéaire')
ax.plot(ts_y_timely_interpolated, marker='.', label='interpolation (time)')
ax.plot(ts_y_knn, marker='.', label='knn')
ax.plot(ts_y_knn_norm, marker='.', label='knn (normalisé)')
ax.plot(ts_y_mice, marker='.', label='mice')
ax.set_xlabel("Date")
ax.set_ylabel("NDVI médian")
ax.set_title(f"Comparaison de toutes les méthodes pour la parcelle {miss_ind}")
_ = plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

MICE produit-il un résultat différent du K-NN ? En théorie, MICE peut
extrapoler des valeurs en dehors de la plage des données observées, là
où le K-NN ne peut que interpoler à partir des parcelles existantes. En
pratique, la différence dépend fortement des données.

## Comparaison avec les parcelles du même type de culture

Comment savoir quelle méthode d’imputation est la plus réaliste ? Une
approche consiste à comparer les valeurs imputées avec les valeurs
observées sur les **autres parcelles du même type de culture** : des
parcelles de maïs, par exemple, devraient toutes suivre un profil NDVI
similaire au cours de l’année (semis, croissance, récolte). Une valeur
imputée cohérente avec ce groupe est donc vraisemblable.

Nous allons calculer pour chaque date la **médiane** et l’**intervalle
interquartile (IQR)** du NDVI sur toutes les parcelles ayant le même
`CODE_GROUP` que la parcelle étudiée. L’IQR (entre le 1er et le 3e
quartile) représente la zone où se trouvent 50% des parcelles du même
type de culture — une valeur imputée qui tombe dans cette zone est donc
plausible.

Complétez le code suivant. Les fonctions utiles sont `np.nanmedian` et
`np.nanpercentile` (qui ignorent les NaN lors du calcul) :

```python
crop_type = cleaned_gdf.iloc[miss_ind]['CODE_GROUP']
print("Type de culture :", crop_type)

# récupérez les indices des parcelles du même type de culture
# idx_crop_type = 

# calculez la médiane sur ces parcelles (axis=0 : résultat par date)
# median = 

# calculez l'IQR : percentiles 25 et 75
# IQR = 

# ts_median = pd.Series(median, index=dti)
# ts_Q1 = pd.Series(IQR[0], index=dti)
# ts_Q3 = pd.Series(IQR[1], index=dti)
```

Une fois l’exercice complété, exécutez la cellule suivante pour
visualiser toutes les méthodes et les comparer au profil de référence du
type de culture. La zone grisée représente l’IQR (une imputation
réaliste devrait s’y inscrire) :

```python
fig, ax = plt.subplots()
ax.plot(ts_y_missing, marker='x', label='original')
ax.plot(ts_y_interpolated, marker='.', label='interpolation linéaire')
ax.plot(ts_y_timely_interpolated, marker='.', label='interpolation (time)')
ax.plot(ts_y_knn, marker='.', label='knn')
ax.plot(ts_y_knn_norm, marker='.', label='knn (normalisé)')
ax.plot(ts_y_mice, marker='.', label='mice')
ax.plot(ts_median, marker='.', label='médiane type de culture', color='grey')
ax.fill_between(ts_median.index, ts_Q1, ts_Q3, color='grey', alpha=0.2,
                label='IQR type de culture')
ax.set_xlabel("Date")
ax.set_ylabel("NDVI médian")
ax.set_title(f"Comparaison des méthodes d'imputation pour la parcelle {miss_ind}")
_ = plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

Quelle méthode reste le mieux dans la zone IQR du type de culture ?

## Remarques finales

1.  Sur la parcelle étudiée, K-NN et MICE produisent des valeurs proches
    de la médiane du type de culture. Cela suggère qu’ils capturent bien
    le comportement saisonnier. Ce n’est pas garanti sur toutes les
    parcelles : modifiez `miss_ind` pour vérifier.

2.  L’interpolation linéaire peut s’éloigner davantage de la réalité,
    notamment lorsque la lacune tombe au milieu d’un changement brusque
    du signal (ex. montée rapide du NDVI au printemps, ou chute après
    moisson).

- Il n’existe pas de méthode universellement meilleure : le choix dépend
  des données, de la densité temporelle et du contexte agronomique.

**Pour aller plus loin** : modifiez `miss_ind` pour observer le
comportement sur d’autres parcelles et d’autres types de culture. Les
conclusions restent-elles valables ?

**Note** : nous n’avons travaillé ici qu’avec le NDVI médian. La même
démarche peut être appliquée à d’autres indices (GRVI, NDWI…) ou à
d’autres statistiques zonales (moyenne, écart-type…).
