# Random Forest (concept et évaluation)
---

## 1. Le principe

Un Random Forest combine plusieurs arbres de décision entraînés sur des sous-ensembles aléatoires des données et des features. Chaque arbre vote, et la majorité l'emporte.

L'aléatoire introduit entre les arbres les rend peu corrélés entre eux. Leur agrégation réduit la variance sans trop augmenter le biais. C'est ce qui rend le Random Forest plus robuste qu'un arbre unique.

En pratique, deux sources d'aléatoire y contribuent : un échantillonnage aléatoire des données (chaque arbre ne voit qu'une partie), et un tirage aléatoire des features à chaque nœud (chaque arbre ne considère qu'un sous-ensemble de variables à chaque décision).

```python
from sklearn.datasets import make_classification
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score,
    f1_score, confusion_matrix, roc_auc_score,
    classification_report
)
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# Donnees synthetiques : 1000 exemples, 10 features, 2 classes
# n_informative=5 : seulement 5 features sont vraiment utiles, les 5 autres sont du bruit
X, y = make_classification(
    n_samples=1000,
    n_features=10,
    n_informative=5,
    n_redundant=2,
    random_state=42
)

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print(f"Donnees d'entrainement : {X_train.shape}")
print(f"Donnees de test        : {X_test.shape}")
print(f"Classes                : {np.unique(y)}")
```

## 2. Entrainement

Les deux parametres les plus importants :

- **n_estimators** : nombre d'arbres dans la foret.
  Plus il y en a, plus le modele est stable, mais le temps d'entrainement augmente.
  Les gains deviennent negligeables apres ~100-200 arbres.

- **max_depth** : profondeur maximale de chaque arbre (nombre de questions successives).
  Trop faible -> underfitting (trop simpliste).
  Trop eleve -> overfitting (memorise le bruit).
  `None` = profondeur illimitee (valeur par defaut dans sklearn).

**Modifiez les variables ci-dessous pour experimenter.**

```python
# ── Parametres a modifier ──────────────────────────────
N_ESTIMATORS = 100   # nombre d'arbres (essayez 1, 10, 100, 500)
MAX_DEPTH    = None  # profondeur max (essayez 1, 3, 10, None)
# ──────────────────────────────────────────────────────

rf = RandomForestClassifier(
    n_estimators=N_ESTIMATORS,
    max_depth=MAX_DEPTH,
    random_state=42
)
rf.fit(X_train, y_train)

print(f"Modele entraine avec {N_ESTIMATORS} arbres, max_depth={MAX_DEPTH}")
```

### Effet du nombre d'arbres

Ci-dessous on entraine plusieurs modeles avec des valeurs croissantes de n_estimators
pour visualiser la stabilisation de la performance.

```python
n_values = [1, 5, 10, 20, 50, 100, 200]
scores   = []

for n in n_values:
    m = RandomForestClassifier(n_estimators=n, random_state=42)
    m.fit(X_train, y_train)
    scores.append(accuracy_score(y_test, m.predict(X_test)))

plt.figure(figsize=(8, 4))
plt.plot(n_values, scores, marker='o', color='#7F77DD', linewidth=2)
plt.xlabel("n_estimators")
plt.ylabel("Accuracy sur le test set")
plt.title("Stabilisation avec le nombre d'arbres")
plt.xticks(n_values)
plt.grid(axis='y', alpha=0.3)
plt.tight_layout()
plt.show()

print("Rendements decroissants : les gains ralentissent apres ~50 arbres")
```

## 3. Evaluation du modele

### La matrice de confusion

Tout part de 4 cases :

```
                  Predit 0     Predit 1
  Reel 0     TN (correct)  FP (fausse alerte)
  Reel 1     FN (rate)     TP (correct)
```

- **TP** (True Positive)  : predit 1, c'etait 1 -> correct
- **TN** (True Negative)  : predit 0, c'etait 0 -> correct
- **FP** (False Positive) : predit 1, c'etait 0 -> fausse alerte
- **FN** (False Negative) : predit 0, c'etait 1 -> rate

```python
y_pred  = rf.predict(X_test)
y_proba = rf.predict_proba(X_test)[:, 1]  # probabilite d'etre positif

cm = confusion_matrix(y_test, y_pred)
tn, fp, fn, tp = cm.ravel()

fig, ax = plt.subplots(figsize=(5, 4))
colors = [['#EAF3DE', '#FCEBEB'], ['#FCEBEB', '#EAF3DE']]
labels = [[f'TN\n{tn}', f'FP\n{fp}'], [f'FN\n{fn}', f'TP\n{tp}']]

for i in range(2):
    for j in range(2):
        ax.add_patch(plt.Rectangle((j, 1-i), 1, 1, color=colors[i][j]))
        ax.text(j+0.5, 1.5-i, labels[i][j], ha='center', va='center',
                fontsize=14, fontweight='bold',
                color='#3B6D11' if colors[i][j]=='#EAF3DE' else '#A32D2D')

ax.set_xlim(0, 2)
ax.set_ylim(0, 2)
ax.set_xticks([0.5, 1.5])
ax.set_xticklabels(['Predit 0', 'Predit 1'])
ax.set_yticks([0.5, 1.5])
ax.set_yticklabels(['Reel 1', 'Reel 0'])
ax.set_title('Matrice de confusion')
ax.tick_params(length=0)
for spine in ax.spines.values():
    spine.set_visible(False)
plt.tight_layout()
plt.show()
```

### Les 4 metriques

Toutes derivent de la matrice de confusion :

| Metrique  | Formule                          | Question posee                                      |
|-----------|----------------------------------|-----------------------------------------------------|
| Accuracy  | (TP+TN) / tout                   | Parmi toutes les predictions, combien sont justes ? |
| Precision | TP / (TP+FP)                     | Parmi les positifs predits, combien le sont vraiment ? |
| Recall    | TP / (TP+FN)                     | Parmi les vrais positifs, combien sont detectes ?   |
| F1 Score  | 2 * Precision*Recall / (P+R)     | Equilibre entre precision et recall                |

**Precision vs Recall** : ces deux metriques sont en tension.
Rendre le modele plus strict (seuil haut) augmente la precision mais baisse le recall.
Le F1 cherche le meilleur compromis.

```python
acc  = accuracy_score(y_test, y_pred)
prec = precision_score(y_test, y_pred)
rec  = recall_score(y_test, y_pred)
f1   = f1_score(y_test, y_pred)
auc  = roc_auc_score(y_test, y_proba)

print(f"Accuracy  : {acc:.3f}")
print(f"Precision : {prec:.3f}")
print(f"Recall    : {rec:.3f}")
print(f"F1 Score  : {f1:.3f}")
print(f"AUC-ROC   : {auc:.3f}")
print()
print(classification_report(y_test, y_pred))
```

### La courbe ROC et l'AUC

La courbe ROC montre le compromis TPR/FPR pour tous les seuils de decision possibles.

- **TPR** (True Positive Rate) = Recall = TP / (TP+FN)
- **FPR** (False Positive Rate) = FP / (FP+TN)

L'**AUC** (aire sous la courbe) resumes la qualite globale :
- 0.5 = modele aleatoire (diagonale)
- 1.0 = modele parfait
- > 0.9 = excellent en pratique

Avantage sur l'accuracy : l'AUC ne depend pas d'un seuil choisi a l'avance.

```python
from sklearn.metrics import roc_curve

fpr_vals, tpr_vals, thresholds = roc_curve(y_test, y_proba)

plt.figure(figsize=(6, 5))
plt.plot(fpr_vals, tpr_vals, color='#7F77DD', linewidth=2,
         label=f'Random Forest (AUC = {auc:.3f})')
plt.plot([0, 1], [0, 1], color='#AAAAAA', linestyle='--',
         linewidth=1, label='Aleatoire (AUC = 0.5)')
plt.fill_between(fpr_vals, tpr_vals, alpha=0.1, color='#7F77DD')
plt.xlabel('FPR (False Positive Rate)')
plt.ylabel('TPR (True Positive Rate = Recall)')
plt.title('Courbe ROC')
plt.legend(loc='lower right')
plt.grid(alpha=0.2)
plt.tight_layout()
plt.show()
```

## 4. Feature importance

Le Random Forest calcule automatiquement l'importance de chaque feature.
Elle mesure en moyenne de combien chaque feature reduit l'impurete (le desordre)
dans les arbres. La somme vaut toujours 1 (100%).

Rappel : nos donnees ont 5 features vraiment informatives et 5 features de bruit.
On devrait voir une separation nette dans le graphique.

```python
importances = rf.feature_importances_
feature_names = [f'feature_{i+1}' for i in range(X.shape[1])]

# Tri par importance decroissante
indices = np.argsort(importances)[::-1]

plt.figure(figsize=(8, 4))
plt.bar(
    range(len(importances)),
    importances[indices],
    color='#AFA9EC'
)
plt.xticks(range(len(importances)),
           [feature_names[i] for i in indices],
           rotation=45, ha='right')
plt.ylabel('Importance')
plt.title('Feature importance (reduction moyenne de l\'impurete)')
plt.tight_layout()
plt.show()

print("Top 5 features :")
for i in indices[:5]:
    print(f"  {feature_names[i]} : {importances[i]:.3f} ({importances[i]*100:.1f}%)")
```

## 5. Utiliser le modele

Une fois entraine, le modele expose deux methodes principales :

- **`predict`** : retourne directement la classe predite (0 ou 1)
- **`predict_proba`** : retourne une probabilite pour chaque classe

`predict_proba` est souvent plus utile car on garde le controle sur le seuil de decision.
Par defaut `predict` classe a 0.5, mais on peut choisir un seuil different selon le contexte.

```python
# Prediction sur un seul exemple
exemple = X_test[0:1]

classe_predite = rf.predict(exemple)
probabilites   = rf.predict_proba(exemple)

print(f"Classe predite : {classe_predite[0]}")
print(f"Probabilite classe 0 : {probabilites[0][0]:.3f}")
print(f"Probabilite classe 1 : {probabilites[0][1]:.3f}")
```

```python
# Choisir son propre seuil de decision
# ── Variable a modifier ───────────────────────────────
SEUIL = 0.5   # essayez 0.3 (recall haut) ou 0.7 (precision haute)
# ──────────────────────────────────────────────────────

y_proba_test  = rf.predict_proba(X_test)[:, 1]
y_pred_custom = (y_proba_test >= SEUIL).astype(int)

print(f"Seuil = {SEUIL}")
print(f"Precision : {precision_score(y_test, y_pred_custom):.3f}")
print(f"Recall    : {recall_score(y_test, y_pred_custom):.3f}")
print(f"F1 Score  : {f1_score(y_test, y_pred_custom):.3f}")
print()
print("Remarque : un seuil bas -> recall monte, precision baisse")
print("           un seuil haut -> precision monte, recall baisse")
```

## 6. Sauvegarder et recharger le modele

```python
import joblib

# Sauvegarde
joblib.dump(rf, 'random_forest.pkl')
print("Modele sauvegarde dans random_forest.pkl")

# Rechargement
rf_recharge = joblib.load('random_forest.pkl')
print(f"Modele recharge - accuracy : {accuracy_score(y_test, rf_recharge.predict(X_test)):.3f}")
```

## Recap

| Concept           | Ce qu'il faut retenir                                          |
|-------------------|----------------------------------------------------------------|
| n_estimators      | Plus d'arbres = plus stable, rendements decroissants apres ~100 |
| max_depth         | Controle le surapprentissage de chaque arbre                  |
| Accuracy          | Bonne metrique si classes equilibrees                         |
| Precision/Recall  | En tension : choisir selon le cout des erreurs                |
| F1 Score          | Compromis precision/recall, ideal si classes desequilibrees   |
| AUC-ROC           | Metrique globale independante du seuil                        |
| Feature importance| Interpretabilite partielle, attention aux features correlees  |
| predict_proba     | Permet de choisir son propre seuil de decision                |
