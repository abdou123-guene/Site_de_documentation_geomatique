# Apprentissage non-supervisé VS apprentissage supervisé

Avant de parler de l’apprentissage non-supervisé, essayons de mieux
comprendre la différence entre supervisé et non-supervisé.

En supervisé, l’algorithme a un guide (ou prof) qui lui permet de savoir
les bonnes réponses pendant l’entraînement. L’algorithme reçoit donc un
ensemble de données avec les solutions (ou labels) attendues pour ces
données.

En non-supervisé, l’algorithme doit apprendre tout seul, personne ne lui
a donné un exemple de solutions (labels). Il doit donc trouver des
ressembles et classer en fonction de ces ressemblances.

<figure>
<img src="attachment:img/supervised_vs_unsupervised.png"
alt="supervised_vs_unsupervised.png" />
<figcaption
aria-hidden="true">supervised_vs_unsupervised.png</figcaption>
</figure>

Voici une analogie : on veut apprendre à un enfant à reconnaître des
animaux.

En supervisé, on lui lui montre des photos en disant “ça c’est un chat,
ça c’est un chien”. Il apprend à associer une image à une réponse
connue. La méthode \`KNN´ fait exactement ça : il mémorise des exemples
étiquetés, et classe les nouveaux par ressemblance avec ceux qu’il
connaît.

En non-supervisé, on donne à l’enfant un tas de photos sans rien lui
dire. Il va naturellement remarquer que certaines se ressemblent et les
regrouper. Mais jamais il ne va savoir que les uns s’appellent `chats`
et les autres `chiens`. C’est ce que fait K-Means.

# Apprentissage non supervisé (Clustering)

Dans ce notebook, nous allons explorer le clustering qui permet de
regrouper automatiquement les parcelles en classes sans utiliser les
étiquettes (ou les réponses).

Le Clustering est une méthode d’apprentissage non-supervisé.

L’avantage du clustering sur la classification supervisée est qu’il ne
nécessite pas de données étiquetées. En contrepartie, les clusters
correspondent à des groupes naturels dans les données. Il arrive que ces
groupes ne coïncident pas les catégories que l’on cherche à distinguer
(exemple : un cluster peut regrouper des clients par comportement
d’achat sans pour autant séparer les bons et mauvais payeurs).

Un point clé de la méthode est de choisir le bon nombre de “clusters”
(ou catégories). Cela suppose une bonne étude des données afin d’avoir
une bonne intuition sur combien de groupes “naturels” existent dans les
données.

```python
import sys
sys.path.append('/home/idgeo/.local/lib/python3.12/site-packages')

from sklearn.preprocessing import StandardScaler
```

```python
import geopandas as gpd
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import (accuracy_score, f1_score,
                             precision_score, recall_score,
                             confusion_matrix, ConfusionMatrixDisplay)
```

```python
# Chargement des données
CLEANED_TIMESERIES_PATH = './sentinel2_data/cleaned_time_series'

data = gpd.read_file(f'{CLEANED_TIMESERIES_PATH}/T31TCJ_median_ndvi_knn_impute.shp')
```

```python
# Récupérations des colonnes de dates
list_clean_dates = [col for col in data.columns if len(col) == 8 and col.isdigit()]
list_clean_dates.sort()
```

```python
# données préparées qui vont être utilisée pour la création du modèle
features = data[list_clean_dates]
```

```python
# réponse attendues (utilisées seulement pour évaluer, pas pour entraîner)
labels = data['CODE_GROUP'].values.astype(int)
```

```python
# Si des NaN subsistent (ex. : exercice 00600 non complété), on les comble
# par interpolation linéaire le long de l'axe temporel (axis=1 = par parcelle),
# puis bfill/ffill pour les bords de série (début ou fin entièrement manquants).
n_nan = features.isna().sum().sum()
if n_nan > 0:
    print(f"Attention : {n_nan} NaN résiduels — imputation par interpolation temporelle.")
    features = features.interpolate(axis=1).bfill(axis=1).ffill(axis=1)
```

```python
# conversion str -> dates 
dti = pd.to_datetime(pd.Series(list_clean_dates))
```

```python
print("Features :", features.shape)
print("Labels   :", labels.shape)
```

```python
cycle_colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728',
                '#9467bd', '#8c564b', '#e377c2', '#7f7f7f',
                '#bcbd22', '#17becf', 'black', 'gray']
```

```python
# Cette fonction nous permet de calculer :
#   - la médiane : courbe "typique" du cluster, robuste aux parcelles atypiques
#   - l'IQR (Q1-Q3) : zone ombrée représentant les 50% du milieu,
# Elle sera utilisé pour voir comment se comporte chaque cluster
def compute_median_IQR_ts(df, dti):
    median = np.median(df, axis=0)
    ts_median = pd.Series(median, index=dti)
    IQR = np.nanpercentile(df, [25, 75], axis=0) # 50% du milieu
    ts_Q1 = pd.Series(IQR[0], index=dti)
    ts_Q3 = pd.Series(IQR[1], index=dti)
    return ts_median, ts_Q1, ts_Q3
```

## K-Means sur toutes les features

K-Means partitionne les parcelles en `k` groupes en minimisant la
distance euclidienne entre chaque parcelle et le centroïde de son
cluster. L’algorithme alterne entre :

1.  Assignation de chaque parcelle au centroïde le plus proche.
2.  Recalcul des centroïdes comme moyenne des parcelles assignées.

```python
from sklearn.cluster import KMeans

# calcul de la classification
pred_labels = KMeans(n_clusters=2, random_state=0).fit_predict(features.values)
```

```python
fig, ax = plt.subplots()
for l in range(2):
    idx_cluster = np.where(pred_labels == l)[0]
    print("Cluster", l, ":", len(idx_cluster), "parcelles")
    ts_median, ts_Q1, ts_Q3 = compute_median_IQR_ts(features.values[idx_cluster, :], dti)
    ax.plot(ts_median, marker='x', color=cycle_colors[l])
    ax.fill_between(ts_median.index, ts_Q1, ts_Q3,
                    color=cycle_colors[l], label=f"cluster {l}", alpha=0.2)
_ = plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

Les profils médians des clusters ressemblent-ils aux profils NDVI du blé
et du maïs observés dans le notebook de visualisation ?

## Évaluation du clustering

Même si K-Means n’utilise pas les labels pendant l’entraînement, nous
les possédons ici et pouvons comparer les clusters aux vraies classes.

**Problème d’alignement** : le cluster `0` de K-Means ne correspond pas
nécessairement à la classe `0`. On aligne manuellement avant de calculer
les métriques.

```python
y_true = labels - 1  # labels 0 ou 1

# alignement : décalage pour éviter les collisions, puis ré-assignation
y_predict = pred_labels + 5
y_predict[y_predict == 5] = 1
y_predict[y_predict == 6] = 0

print("Accuracy  :", accuracy_score(y_true, y_predict))
print("F1-score  :", f1_score(y_true, y_predict, average='weighted'))
```

```python
fig, axes = plt.subplots(1, 2, figsize=(10, 4))

cm_abs = confusion_matrix(y_true, y_predict)
ConfusionMatrixDisplay(cm_abs, display_labels=["Blé", "Maïs"]).plot(
    cmap=plt.cm.Blues, ax=axes[0])
axes[0].set_title("Valeurs absolues")

cm_norm = confusion_matrix(y_true, y_predict, normalize='true')
ConfusionMatrixDisplay(cm_norm, display_labels=["Blé", "Maïs"]).plot(
    cmap=plt.cm.Blues, ax=axes[1])
axes[1].set_title("Normalisée (par classe réelle)")

plt.tight_layout()
plt.show()
```

**À partir de la matrice de confusion, calculez :**

- L’accuracy : (TP + TN) / total
- La précision : TP / (TP + FP) — parmi les prédits Maïs, combien sont
  vraiment Maïs
- Le rappel : TP / (TP + FN) — parmi les vrais Maïs, combien sont
  retrouvés

**Questions :**

- Avec un algorithme entièrement non supervisé, l’accuracy obtenue
  est-elle surprenante ? Qu’est-ce que cela révèle sur la séparabilité
  des deux cultures ?
- Quelles sont les limites de l’évaluation par accuracy sur ce jeu de
  données ?
