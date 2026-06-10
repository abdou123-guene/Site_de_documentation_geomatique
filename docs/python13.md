# Apprentissage supervisé
---

L’apprentissage supervisé utilise des données **labellisées** pour
entraîner un modèle qui prédit la classe de nouvelles parcelles.
Contrairement au clustering, le modèle apprend directement à discriminer
les classes à partir des exemples connus.

```python
import geopandas as gpd
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import (accuracy_score, f1_score,
                             confusion_matrix, ConfusionMatrixDisplay)
```

```python
CLEANED_TIMESERIES_PATH = './sentinel2_data/cleaned_time_series'

data = gpd.read_file(f'{CLEANED_TIMESERIES_PATH}/T31TCJ_median_ndvi_knn_impute.shp')

list_clean_dates = [col for col in data.columns if len(col) == 8 and col.isdigit()]
list_clean_dates.sort()
feat = data[list_clean_dates]
lab = data['CODE_GROUP'].values.astype(int)
y_true = lab - 1  # labels 0 ou 1

# Si des NaN subsistent (ex. : exercice 00600 non complété), on les comble
# par interpolation linéaire le long de l'axe temporel (axis=1 = par parcelle),
# puis bfill/ffill pour les bords de série (début ou fin entièrement manquants).
n_nan = feat.isna().sum().sum()
if n_nan > 0:
    print(f"Attention : {n_nan} NaN résiduels — imputation par interpolation temporelle.")
    feat = feat.interpolate(axis=1).bfill(axis=1).ffill(axis=1)

X = feat.values

print("Features :", feat.shape)
print("Labels   :", lab.shape)
```

## Premier classifieur : découpage train/test

On divise les données en un jeu d’entraînement (75%) et un jeu de test
(25%). Le modèle est entraîné sur le train et évalué sur le test, qui
représente des parcelles inconnues.

- **Random Forest** : ensemble d’arbres de décision, chacun entraîné sur
  un sous-ensemble aléatoire des données et des features. Robuste et
  performant sur les données tabulaires.
- **Régression Logistique** : modèle linéaire qui estime la probabilité
  d’appartenance à une classe. Simple, rapide, interprétable.

```python
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression

X_train, X_test, y_train, y_test = train_test_split(X, y_true,
                                                     test_size=0.25,
                                                     random_state=0)

RF = RandomForestClassifier(random_state=0)
LR = LogisticRegression(max_iter=1000)

RF.fit(X_train, y_train)
LR.fit(X_train, y_train)

print("Random Forest      :", accuracy_score(y_test, RF.predict(X_test)))
print("Régression Logist. :", accuracy_score(y_test, LR.predict(X_test)))
```

**Limite de cette approche** : l’accuracy dépend du tirage aléatoire du
split. Un autre `random_state` peut donner un résultat différent. La
section suivante résout ce problème.

## Validation croisée stratifiée

La **validation croisée à k folds** divise les données en 10
sous-ensembles. À chaque itération, un fold différent sert de jeu de
test et les 9 autres servent d’entraînement. On obtient ainsi 10
estimations de performance, ce qui donne une mesure beaucoup plus
robuste qu’un seul split.

La version **stratifiée** garantit que chaque fold contient les mêmes
proportions de classes que le dataset global.

```python
from sklearn.model_selection import StratifiedKFold

skf = StratifiedKFold(n_splits=10, shuffle=True, random_state=42)

RF = RandomForestClassifier(random_state=0)
LR = LogisticRegression(max_iter=1000)

list_acc_RF = []
list_acc_LR = []

for fold, (train_index, test_index) in enumerate(skf.split(X, y_true)):
    X_train, y_train = X[train_index], y_true[train_index]
    X_test,  y_test  = X[test_index],  y_true[test_index]

    RF.fit(X_train, y_train)
    LR.fit(X_train, y_train)

    list_acc_RF.append(accuracy_score(y_test, RF.predict(X_test)))
    list_acc_LR.append(accuracy_score(y_test, LR.predict(X_test)))
    print(f"Fold {fold}  RF={list_acc_RF[-1]:.4f}  LR={list_acc_LR[-1]:.4f}")

fig, ax = plt.subplots()
ax.boxplot([list_acc_RF, list_acc_LR])
ax.set_xticklabels(['RF', 'LR'])
ax.set_title('Accuracy — validation croisée (10 folds)')
ax.set_ylabel('Accuracy')
plt.grid(linestyle=':')
plt.tight_layout()
plt.show()
```

**Questions :**

- Quelle est la variance des scores entre les folds ? Un modèle instable
  (grande variance) est-il fiable ?
- Random Forest et Régression Logistique donnent-ils des performances
  similaires ? Qu’est-ce que cela implique sur la complexité du problème
  ?

**Réponse**

La forêt aléatoire présente une variance plus faible que la régression logistique, ce qui indique une meilleure stabilité. Un modèle instable n’est pas fiable car ses performances varient fortement selon les données d’entraînement. De plus, la forêt aléatoire obtient de meilleures performances que la régression logistique, ce qui montre que le problème est non linéaire et nécessite des modèles capables de capturer des relations complexes dans les séries temporelles NDVI.

```python
# essayez de limiter la profondeur de la forêt (max_depth=10)
# et comparez les résultats
RF_limited = RandomForestClassifier(max_depth=10, random_state=0)

list_acc_RF_limited = []

for fold, (train_index, test_index) in enumerate(skf.split(X, y_true)):
    X_train, y_train = X[train_index], y_true[train_index]
    X_test,  y_test  = X[test_index],  y_true[test_index]

    RF_limited.fit(X_train, y_train)
    
    acc = accuracy_score(y_test, RF_limited.predict(X_test))
    list_acc_RF_limited.append(acc)

    print(f"Fold {fold}  RF_limited={acc:.4f}")

# comparaison visuelle
fig, ax = plt.subplots()
ax.boxplot([list_acc_RF, list_acc_RF_limited])
ax.set_xticklabels(['RF', 'RF max_depth=10'])
ax.set_title('Impact de la profondeur sur RF')
ax.set_ylabel('Accuracy')
plt.grid(linestyle=':')
plt.tight_layout()
plt.show()
```

## Importance des variables (features)

La Random Forest mesure l’importance de chaque variable : quelle
réduction d’impureté moyenne elle apporte lors des coupures dans les
arbres. Une date importante est une date dont la valeur NDVI aide le
plus à distinguer le blé du maïs.

```python
RF_full = RandomForestClassifier(random_state=0)
RF_full.fit(X, y_true)  # entraîné sur toutes les données pour un score stable

importances = RF_full.feature_importances_

fig, ax = plt.subplots(figsize=(10, 4))
ax.bar(list_clean_dates, importances)
ax.set_xlabel("Date")
ax.set_ylabel("Importance")
ax.set_title("Importance des variables (Random Forest — toutes dates)")
_ = plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

for d, imp in zip(list_clean_dates, importances):
    print(f"{d} : {imp:.4f}")
```

**Questions :**

- Quelles dates ont la plus forte importance ? Est-ce cohérent avec les
  profils NDVI observés dans le notebook de visualisation ?
- Les dates importantes correspondent-elles aux moments où les deux
  cultures se différencient le plus sur la courbe temporelle ?

**Remarque** : si deux dates sont très corrélées (mesurées à quelques
jours d’intervalle), la Random Forest tend à n’en utiliser qu’une. Une
importance faible ne signifie pas forcément qu’une date est inutile.

**Réponses**

Les dates les plus importantes sont celles où les valeurs de NDVI permettent le mieux de distinguer les cultures. Ces dates correspondent généralement aux périodes clés du cycle végétatif, comme la croissance ou la maturation.

Oui, ces dates sont cohérentes avec les profils NDVI observés précédemment. Elles correspondent aux périodes où les courbes des différentes cultures présentent les plus grandes différences.

Oui, les dates les plus importantes correspondent aux moments où les deux cultures présentent les différences les plus marquées dans leurs valeurs de NDVI, ce qui facilite leur discrimination.

Remarque: Les variables corrélées (dates proches dans le temps) peuvent se substituer les unes aux autres. Ainsi, une faible importance n’implique pas nécessairement qu’une date est inutile, mais plutôt qu’elle apporte une information redondante.

L’importance des variables montre que certaines dates sont particulièrement discriminantes pour la classification. Ces dates correspondent aux périodes où les profils NDVI des cultures diffèrent le plus. Cela confirme que la dynamique temporelle de la végétation est un facteur clé pour distinguer les cultures.
