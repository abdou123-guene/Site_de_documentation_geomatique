# Pandas, DataFrames et analyse tabulaire
---

[Pandas](https://pandas.pydata.org) est une bibliothèque Python
proposant des structures de données et des outils de manipulation
efficaces pour analyser des données tabulaires.

Pandas utilise NumPy en interne pour ses calculs. Les performances sont
donc comparables à NumPy, avec en plus une interface orientée données
(étiquettes, index, types mixtes).

Pandas est une bibliothèque open-source, documentée sur
[pandas.pydata.org](https://pandas.pydata.org).

La convention d’import universelle est :

```python
import pandas as pd
import numpy as np
```

## Les structures de données Pandas

Pandas propose deux structures principales :

- **Series** : tableau à une dimension, avec un index. C’est
  l’équivalent d’une colonne d’un tableur.
- **DataFrame** : tableau à deux dimensions (lignes et colonnes) avec un
  index de lignes et des étiquettes de colonnes. C’est l’équivalent
  d’une feuille de tableur ou d’une table SQL.

Un DataFrame est en pratique la structure que vous utiliserez dans 95 %
des cas. Chaque colonne est une Series ; chaque Series est un ndarray
NumPy avec un index.

## Créer un DataFrame

### À partir d’un dictionnaire

```python
# Données fictives de 5 stations météo des Hautes-Pyrénées
df = pd.DataFrame({
    'nom'      : ['Tarbes', 'Lourdes', 'Bagnères', 'Arreau', 'Saint-Lary'],
    'altitude' : [320, 420, 550, 720, 830],
    'temp_moy' : [15.5, 14.8, 13.9, 11.2, 10.4],
    'pluvio'   : [850, 1050, 1200, 1400, 1600],
})
df
```

```python
# Aperçu des premières lignes
df.head(2)
```

```python
# Aperçu des dernières lignes
df.tail(3)
```

### Explorer la structure d’un DataFrame

```python
# Résumé : types, mémoire, valeurs non-nulles
df.info()
```

```python
# Statistiques descriptives des colonnes numériques
df.describe()
```

```python
# Noms des colonnes
df.columns
```

```python
# Index des lignes (entiers par défaut)
df.index
```

```python
# Nombre total d'éléments
df.size
```

```python
# Dimensions : (nombre de lignes, nombre de colonnes)
df.shape
```

```python
# Type de chaque colonne
df.dtypes
```

La fonction `describe` résume les statistiques de base (moyenne,
médiane, écart-type, quartiles) pour toutes les colonnes numériques, en
excluant les valeurs `NaN`.

## Accéder aux données : `loc` et `iloc`

### Accès par étiquette avec `loc`

`loc` sélectionne par **étiquette** : nom de ligne ou nom de colonne.

```python
# Accéder à une colonne entière -> renvoie une Series
df.loc[:, 'altitude']
```

```python
# Raccourci équivalent (notation crochets)
df['altitude']
```

```python
# Accéder à plusieurs colonnes -> renvoie un DataFrame
df.loc[:, ['nom', 'altitude', 'temp_moy']]
```

```python
# Raccourci équivalent
df[['nom', 'altitude', 'temp_moy']]
```

```python
# Accéder à une ligne par son index entier (ici index 0 = Tarbes)
df.loc[0]
```

```python
# Accéder à plusieurs lignes
df.loc[0:2]   # lignes 0, 1 et 2 incluses (loc est inclusif aux deux bouts)
```

```python
# Accéder à une cellule précise : ligne 1, colonne 'temp_moy'
df.loc[1, 'temp_moy']
```

**Exercice**

Quel est le type de `df['altitude']` et de
`df[['nom', 'altitude', 'temp_moy']]`. Pouvez-vous l’expliquer ?

### Accès par position avec `iloc`

`iloc` sélectionne par **position entière**, comme le slicing NumPy.

**votre réponse**

**df['altitude']** est une Series car c’est une seule colonne, tandis que **df[['nom', 'altitude', 'temp_moy']]** est un DataFrame car plusieurs colonnes sont sélectionnées

```python
# Toutes les lignes, colonnes 1 et 2 (altitude et temp_moy)
df.iloc[:, 1:3]
```

```python
# Lignes 0 à 2, toutes colonnes
df.iloc[0:3, :]
```

```python
# Une cellule précise : ligne 2, colonne 3
df.iloc[2, 3]
```

### Récupérer les valeurs sous forme de ndarray

```python
# .values renvoie un ndarray NumPy (c'est le pont NumPy <-> Pandas)
altitudes = df['altitude'].values
print(type(altitudes))
print(altitudes)
```

```python
# On peut alors utiliser toutes les fonctions NumPy
print("Altitude moyenne :", np.mean(altitudes))
print("Altitude max     :", np.max(altitudes))
print("Écart-type       :", np.std(altitudes))
```

## Sélection conditionnelle

Pandas permet de filtrer les lignes selon une condition, exactement
comme les masques booléens NumPy.

```python
# La condition produit une Series de booléens / avec and &
(df['altitude'] < 600) & (df['altitude'] >800)
```

```python
# La condition produit une Series de booléens / avec or |
(df['altitude'] < 450) | (df['altitude'] >800)
```

```python
# La condition produit une Series de booléens / avec not/different ~
~(df['altitude'] > 600)
```

```python
# Utiliser cette Series comme masque pour filtrer le DataFrame
df[df['altitude'] > 600]
```

```python
# bis: Utiliser cette Series comme masque pour filtrer le DataFrame 
df[(df['altitude'] < 450) | (df['altitude'] >800)]
```

```python
# Combiner plusieurs conditions : & (ET), | (OU), ~ (NON)
# Attention : chaque condition doit être entre parenthèses
df[(df['altitude'] > 400) & (df['temp_moy'] < 14.0)]
```

```python
# Filtrer sur une valeur de texte
df[df['nom'] == 'Tarbes']
```

```python
# Filtrer avec str.startswith, str.contains, etc.
df[df['nom'].str.startswith('B')]
```

#### Exercice 1

Créez un DataFrame contenant uniquement les stations dont l’altitude est
comprise entre 400 m et 700 m.

```python
# À vous !
df_filtre = df[(df['altitude'] >= 400) & (df['altitude'] <= 700)]
df_filtre
```

#### Exercice 2

Créez un DataFrame contenant les stations dont la pluviométrie est
supérieure à 1200 mm **et** la température moyenne inférieure à 13°C.

```python
# À vous !
df_filtre = df[(df['pluvio'] > 1200) & (df['temp_moy'] < 13)]
df_filtre
```

## Créer et transformer des colonnes

### Nouvelles colonnes calculées

```python
import pandas as pd
import numpy as np

df = pd.DataFrame({
    'nom': ['Tarbes', 'Lourdes', 'Bagnères', 'Arreau', 'Saint-Lary'],
    'altitude': [320, 420, 550, 720, 830],
    'temp_moy': [15.5, 14.8, 13.9, 11.2, 10.4],
    'pluvio': [850, 1050, 1200, 1400, 1600],
})
```

```python
# Température en Fahrenheit
df['temp_fahrenheit'] = df['temp_moy'] * 9/5 + 32
df
```

```python
df['temp_fahrenheit'] = df['temp_moy'] * 9/5 + 32
df
```

#### Exercice A

Ajoutez une nouvelle colonne : `altitude_km` qui est calculée à partir
de la colonne `altitude`

```python
# votre réponse 
df['altitude_km'] = df['altitude'] / 1000
df
```

#### Exercice B

La pluviométrie des stations varie entre 850 mm et 1600 mm, ce qui rend
les comparaisons directes difficiles avec d’autres variables comme la
température.

Créez une colonne `pluvio_norm` contenant la pluviométrie normalisée
selon le z-score (centrage-réduction) : pour chaque station, soustrayez
la moyenne de la colonne puis divisez par l’écart-type.

Une valeur de `pluvio_norm` proche de 0 indique une pluviométrie proche
de la moyenne du département ; une valeur positive (resp. négative)
indique une station plus humide (resp. plus sèche) que la moyenne.

Affichez les colonnes `nom`, `pluvio` et `pluvio_norm` pour vérifier.

```python
# votre réponse 
# 1. moyenne
mean = df['pluvio'].mean()
# 2. écart-type
std = df['pluvio'].std()
# 3. normalisation
df['pluvio_norm'] = (df['pluvio'] - mean) / std
# 4. affichage
df[['nom', 'pluvio', 'pluvio_norm']]
```

### Catégoriser avec `np.where`

`np.where` permet de créer une colonne catégorielle à partir d’une
condition. Syntaxe :
`np.where(condition, valeur_si_vrai, valeur_si_faux)`. On peut imbriquer
plusieurs `np.where` pour créer plus de deux catégories.

```python
# Catégorie d'altitude en 3 niveaux
df['categorie'] = np.where(
    df['altitude'] < 400, 'Plaine',
    np.where(df['altitude'] < 700, 'Colline', 'Montagne')
)
df[['nom', 'altitude', 'categorie']]
```

### Transformer avec `apply`

`apply` applique une fonction Python quelconque à chaque élément d’une
colonne. C’est plus flexible que les opérations vectorisées, mais
légèrement plus lent.

```python
# Mettre les noms en majuscules
df['nom_maj'] = df['nom'].apply(str.upper)
df[['nom', 'nom_maj']].head()
```

```python
# Appliquer une fonction personnalisée
def classer_temp(t):
    if t < 12:
        return 'froid'
    elif t < 15:
        return 'tempéré'
    else:
        return 'chaud'

df['climat'] = df['temp_moy'].apply(classer_temp)
df[['nom', 'temp_moy', 'climat']]
```

### Supprimer des colonnes

```python
# Supprimer les colonnes de travail (inplace=True modifie directement le DataFrame)
df.drop(columns=['temp_fahrenheit', 
                 'nom_maj', 'climat'], inplace=True)
df
```

## Trier les données

```python
# Trier par altitude croissante
df.sort_values('altitude')
```

```python
# Trier par température décroissante
df.sort_values('temp_moy', ascending=False)
```

```python
# Trier par catégorie puis par altitude
df.sort_values(['categorie', 'altitude'])
```

## Gestion des valeurs manquantes (`NaN`)

Les données réelles sont rarement complètes. Pandas représente les
valeurs manquantes par `NaN` (Not a Number), cohérent avec NumPy.

```python
# Créer un DataFrame avec des NaN
df_incomplet = pd.DataFrame({
    'station'  : ['A', 'B', 'C', 'D', 'E'],
    'altitude' : [320, np.nan, 550, 720, np.nan],
    'temp_moy' : [15.5, 14.8, np.nan, 11.2, 10.4],
})
df_incomplet
```

```python
# Détecter les NaN : True là où la valeur est manquante
df_incomplet.isnull()
```

```python
# Compter les NaN par colonne
df_incomplet.isnull().sum()
```

```python
# Supprimer les lignes contenant au moins un NaN
df_incomplet.dropna()
```

```python
# Remplacer les NaN par une valeur fixe
df_incomplet.fillna(0)
```

```python
# Remplacer par la moyenne de la colonne (stratégie courante)
df_incomplet['altitude'].fillna(df_incomplet['altitude'].mean())
```

## Lire et écrire un fichier CSV

### Télécharger la Base Adresse Nationale (BAN)

La [Base Adresse Nationale](https://adresse.data.gouv.fr) recense toutes
les adresses françaises. Elle est mise à jour quotidiennement et
disponible en licence ouverte Etalab.

```python
import os
import gzip
import shutil
import requests

# Répertoire de téléchargement
os.makedirs('data', exist_ok=True)

url = "https://adresse.data.gouv.fr/data/ban/adresses/latest/csv-bal/adresses-65.csv.gz"
gz_path  = "data/adresses-65.csv.gz"
csv_path = "data/adresses-65.csv"

# Téléchargement (seulement si le fichier n'existe pas déjà)
if not os.path.exists(csv_path):
    print("Téléchargement en cours...")
    response = requests.get(url, stream=True)
    with open(gz_path, 'wb') as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)

    # Décompression
    with gzip.open(gz_path, 'rb') as f_in:
        with open(csv_path, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)
    print(f"Fichier disponible : {csv_path}")
else:
    print(f"Fichier déjà présent : {csv_path}")
```

### Lire le CSV

```python
# Lecture du CSV avec gestion des types
df_ban = pd.read_csv(
    csv_path,
    sep=';',
    dtype={
        'uid_adresse'           : 'str',
        'cle_interop'           : 'str',
        'commune_insee'         : 'str',
        'commune_nom'           : 'str',
        'commune_deleguee_insee': 'str',
        'commune_deleguee_nom'  : 'str',
        'voie_nom'              : 'str',
        'lieudit_complement_nom': 'str',
        'numero'                : 'str',
        'suffixe'               : 'str',
        'position'              : 'str',
        'x'                     : 'float64',
        'y'                     : 'float64',
        'long'                  : 'float64',
        'lat'                   : 'float64',
        'cad_parcelles'         : 'str',
        'source'                : 'str',
        'date_der_maj'          : 'str',
        'certification_commune' : 'str',
    }
)
df_ban
```

**Exercice : Explorer la structure de la BAN**

En vous appuyant sur les propriétés et méthodes vues précédemment :

- Afficher un aperçu des 20 premières lignes
- Lister les colonnes
- Combien d’adresses et de colonnes contient `df_ban` ?
- Quelles colonnes contiennent des valeurs manquantes ? Combien par
  colonne ?

```python
# votre réponse
df_ban.head(20)
df_ban.columns
df_ban.shape
df_ban.isnull().sum()
```

Le code suivant permet d’extraire uniquement les chiffres en début de
chaîne :

```python
df_ban['numero_int'] = df_ban['numero'].str.extract(r'^(\d+)').astype('Int64')
```

Calculez le numéro maximal. Explorer ensuite les entrées qui ont ce
numéro

```python
# votre réponse
# extraction du numéro
df_ban['numero_int'] = df_ban['numero'].str.extract(r'^(\d+)').astype('Int64')
# maximum
max_num = df_ban['numero_int'].max()
# lignes correspondantes
df_ban[df_ban['numero_int'] == max_num]
```

### Sélectionner les colonnes utiles

```python
# Nous ne gardons que les colonnes pertinentes pour la suite
colonnes_utiles = ['uid_adresse', 'numero', 'voie_nom',
                   'commune_insee', 'commune_nom', 'x', 'y', 'long', 'lat']
df_ban = df_ban[colonnes_utiles]
df_ban.head()
```

### Écrire un fichier CSV

```python
# Sauvegarder le DataFrame allégé
df_ban.to_csv('data/adresses-65-simplifie.csv', index=False, sep=';')
print("Fichier sauvegardé.")
```

## Exploration des données BAN

### Valeurs uniques et comptages

```python
# Nombre de communes dans le département
df_ban['commune_nom'].nunique()
```

```python
# Liste des communes (premières valeurs)
df_ban['commune_nom'].unique()[:20]
```

```python
# Compter les adresses par commune (top 10)
df_ban['commune_nom'].value_counts().head(10)
```

**Exercice**

La fonction `value_counts` trie par défaut par ordre décroissant.
Comment savoir quelle est la commune avec le plus petit nombre
d’adresses ?

### Filtres sur les données réelles

**Exercice 1** Créez un DataFrame `df_tarbes` contenant uniquement les
adresses de la commune de Tarbes. Combien d’adresses y a-t-il ?

```python
# votre réponse
counts = df_ban['commune_nom'].value_counts()
counts.sort_values().head(1)
```

**Exercice 2** Combien d’adresses ont un nom de voie contenant le mot
`'PYRENEES'` (toutes casses confondues) dans le département ? Affichez
les 10 premières.

```python
# votre réponse
df_pyrenees = df_ban[df_ban['voie_nom'].str.contains('PYRENEES', case=False)]

# nombre total
len(df_pyrenees)

# affichage des 10 premières lignes
df_pyrenees.head(10)
```

**Exercice 3** Créez un DataFrame `df_lourdes_zone` contenant les
adresses situées dans le rectangle géographique suivant (bbox
approximative autour de Lourdes) :

- longitude entre `0.02` et `0.08`
- latitude entre `43.08` et `43.12`

Combien d’adresses se trouvent dans cette zone ?

```python
# votre réponse
df_lourdes_zone = df_ban[
    (df_ban['long'] >= 0.02) & (df_ban['long'] <= 0.08) &
    (df_ban['lat'] >= 43.08) & (df_ban['lat'] <= 43.12)
]
# nombre d’adresses
len(df_lourdes_zone)
```

## Groupby : agréger par groupe

`groupby` est l’une des opérations les plus puissantes de Pandas. Elle
permet de regrouper les lignes selon une ou plusieurs colonnes, puis
d’appliquer une fonction d’agrégation à chaque groupe.

```python
# Nombre d'adresses par commune
adresses_par_commune = df_ban.groupby('commune_nom').size().reset_index(name='nb_adresses')
adresses_par_commune.sort_values('nb_adresses', ascending=False).head(10)
```

```python
# Nombre de noms de voies distincts par commune
df_ban.groupby('commune_nom')['voie_nom'].nunique().sort_values(ascending=False).head(10)
```

```python
# Plusieurs agrégations en une fois avec .agg()
df_ban.groupby('commune_nom').agg(
    nb_adresses=('uid_adresse', 'count'),
    nb_voies=('voie_nom', 'nunique'),
    lon_moy=('long', 'mean'),
    lat_moy=('lat', 'mean'),
).sort_values('nb_adresses', ascending=False).head(10)
```

## Visualisation rapide avec Matplotlib

Pandas s’intègre nativement avec Matplotlib pour des visualisations
rapides. L’idée centrale est de construire d’abord la donnée à
visualiser (avec les outils Pandas vus précédemment), puis de la passer
à Matplotlib pour l’affichage.

La structure type est toujours la même :

1.  **Préparer la donnée** : filtrer, agréger, trier avec Pandas
2.  **Créer la figure** : `fig, ax = plt.subplots(...)`
3.  **Tracer** : `.plot(...)` ou `ax.scatter(...)`, `ax.hist(...)`
4.  **Habiller** : titres, labels, légende
5.  **Afficher** : `plt.show()`

```python
import matplotlib.pyplot as plt
```

### Graphique en barres horizontales

`fig, ax = plt.subplots()` crée une figure et un axe. Le paramètre
`figsize` contrôle la taille en pouces (largeur, hauteur).

Pandas s’intègre nativement avec Matplotlib. La méthode `.plot()` est
disponible directement sur une Series ou un DataFrame. Le paramètre
`kind` choisit le type : `bar` pour des barres verticales, `barh` pour
des barres horizontales, … (voir doc :
https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.plot.html
)

Notez le `.sort_values()` avant le tracé : `value_counts()` trie par
fréquence décroissante, mais pour un graphique en barres horizontales on
préfère l’ordre croissant pour que la barre la plus longue soit en haut.

```python
# Top 15 des communes par nombre d'adresses
top15 = (df_ban['commune_nom']
         .value_counts()   # trie par fréquence décroissante
         .head(15)         # garde les 15 premières
         .sort_values())   # retrie croissant pour l'affichage

fig, ax = plt.subplots(figsize=(10, 6))
top15.plot(kind='barh', ax=ax, color='steelblue')
ax.set_xlabel("Nombre d'adresses")
ax.set_title("Top 15 des communes - BAN Hautes-Pyrénées (65)")
plt.tight_layout()   # évite que les labels soient coupés
plt.show()
```

### Histogramme

Un histogramme découpe une variable continue en intervalles (`bins`) et
compte le nombre de valeurs dans chaque intervalle. C’est idéal pour
visualiser la distribution d’une variable numérique.

Ici on visualise la distribution Nord-Sud des adresses : une
concentration en plaine (latitude ~43.2°–43.3°, autour de Tarbes) et une
queue vers le sud (zone montagneuse, peu peuplée).

```python
# Histogramme de la latitude (distribution Nord-Sud des adresses)
fig, ax = plt.subplots(figsize=(9, 4))
df_ban['lat'].hist(bins=50, ax=ax, color='darkorange', edgecolor='white')
ax.set_xlabel("Latitude (deg)")
ax.set_ylabel("Nombre d'adresses")
ax.set_title("Distribution latitudinale des adresses - Hautes-Pyrénées")
plt.tight_layout()
plt.show()
```

### Nuage de points

`ax.scatter()` trace un point par adresse, avec `long` en abscisse et
`lat` en ordonnée. Les paramètres `s` (taille des points) et `alpha`
(transparence) sont essentiels ici : avec 128 000 points, des points
trop grands ou opaques formeraient un bloc illisible.

Le résultat donne un aperçu des zones habitées du département. Il y a
des zones plus habitées que d’autres (plaine au nord et les vallées
pyrénéennes au sud).

```python
# Nuage de points géographique rapide
fig, ax = plt.subplots(figsize=(8, 8))
ax.scatter(df_ban['long'], df_ban['lat'],
           s=0.5,        # points très petits (128 000 points)
           alpha=0.3,    # transparence pour voir les densités
           color='steelblue')
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.set_title("Répartition géographique des adresses (BAN 65)")
ax.set_aspect('equal')   # évite la déformation de la carte
plt.tight_layout()
plt.show()
```

Ce nuage de points préfigure déjà le GeoDataFrame que nous créerons dans
le module suivant (GeoPandas) en ajoutant un CRS à ces mêmes
coordonnées.

## Transformer un tableau “wide” en format “long”

### Pourquoi deux formats ?

Imaginons les températures hebdomadaires de 3 stations. La façon la plus
intuitive de les noter est le format **wide** : une ligne par station,
une colonne par semaine.

| station  | semaine_1 | semaine_2 | semaine_3 | semaine_4 |
|----------|-----------|-----------|-----------|-----------|
| Tarbes   | 15.5      | 16.2      | 14.8      | 17.1      |
| Lourdes  | 14.8      | 15.3      | 13.9      | 16.2      |
| Bagnères | 13.9      | 14.4      | 12.8      | 15.5      |

C’est lisible pour un humain, mais **problématique pour l’analyse** :
les semaines sont éparpillées sur plusieurs colonnes, ce qui rend
difficile de répondre à des questions comme “quelle est la température
moyenne toutes semaines confondues ?” ou “comment tracer une courbe par
station ?”.

Le format **long** (aussi appelé *tidy data*) résout ce problème en
plaçant **toutes les valeurs d’une même variable dans une seule
colonne** :

| station | semaine   | temperature |
|---------|-----------|-------------|
| Tarbes  | semaine_1 | 15.5        |
| Tarbes  | semaine_2 | 16.2        |
| Tarbes  | semaine_3 | 14.8        |
| …       | …         | …           |

Le tableau a plus de lignes, mais chaque colonne a un rôle clair :
`station` est un identifiant, `semaine` est une variable, `temperature`
est une valeur. C’est ce que Pandas, Matplotlib et la plupart des outils
d’analyse attendent.

### Quand utiliser chaque format ?

- **Wide** : saisie de données, tableaux de bord lisibles par un humain,
  export Excel.
- **Long** : calculs statistiques avec `groupby`, visualisations avec
  Matplotlib ou Seaborn, analyses temporelles.

En pratique, on reçoit souvent des données en wide (tableurs, exports)
et on les convertit en long dès qu’on veut les analyser.

La fonction `melt` réalise cette transformation, utile pour les
visualisations et les analyses temporelles.

```python
# Exemple : mesures hebdomadaires de 3 stations
df_wide = pd.DataFrame({
    'station'  : ['Tarbes', 'Lourdes', 'Bagnères'],
    'semaine_1': [15.5, 14.8, 13.9],
    'semaine_2': [16.2, 15.3, 14.4],
    'semaine_3': [14.8, 13.9, 12.8],
    'semaine_4': [17.1, 16.2, 15.5],
})
df_wide
```

```python
# Transformation wide -> long
df_long = pd.melt(
    df_wide,
    id_vars=['station'],         # colonnes identifiants (rester en colonnes)
    value_vars=['semaine_1', 'semaine_2', 'semaine_3', 'semaine_4'],
    var_name='semaine',          # nom de la nouvelle colonne d'identifiant
    value_name='temperature',    # nom de la nouvelle colonne de valeurs
)
df_long
```

```python
# Renommer pour plus de lisibilité
df_long.rename(columns={'station': 'Station', 'semaine': 'Semaine',
                         'temperature': 'Température (degC)'}, inplace=True)
df_long
```

```python
# Visualiser les séries temporelles par station
fig, ax = plt.subplots(figsize=(9, 5))
for station, groupe in df_long.groupby('Station'):
    ax.plot(groupe['Semaine'], groupe['Température (degC)'],
            marker='o', label=station)
ax.set_xlabel("Semaine")
ax.set_ylabel("Température (degC)")
ax.set_title("Températures hebdomadaires par station")
ax.legend()
plt.tight_layout()
plt.show()
```

## Le lien NumPy \<-\> Pandas

Une colonne Pandas **est** un ndarray NumPy avec un index. La propriété
`.values` expose ce tableau sous-jacent.

```python
# Récupérer les coordonnées comme ndarrays
lons = df_ban['long'].values
lats = df_ban['lat'].values

print("Type :", type(lons))
print("Shape :", lons.shape)
print("dtype :", lons.dtype)
```

```python
# Toutes les fonctions NumPy s'appliquent directement
print("Centre approximatif du département :")
print(f"  Longitude : {np.mean(lons):.4f}deg")
print(f"  Latitude  : {np.mean(lats):.4f}deg")
print(f"  Étendue   : {np.max(lons) - np.min(lons):.4f}deg X "
      f"{np.max(lats) - np.min(lats):.4f}deg")
```

```python
# Opération NumPy sur une colonne Pandas : conversion degrés -> radians
lons_rad = np.radians(lons)
lons_rad[:5]
```

Réciproquement, un ndarray peut être inséré comme colonne dans un
DataFrame :

```python
# Ajouter une colonne calculée par NumPy dans le DataFrame
df_ban['lon_rad'] = np.radians(df_ban['long'])
df_ban[['commune_nom', 'long', 'lon_rad']].head()
```

```python
# Nettoyage : supprimer la colonne temporaire
df_ban.drop(columns=['lon_rad'], inplace=True)
```

## Exercice récapitulatifs

**Question 1** Calculez, pour chaque commune, le nombre d’adresses et la
longitude moyenne. Triez par longitude croissante (Ouest -\> Est) et
affichez les 10 premières.

```python
# À vous !
result = df_ban.groupby('commune_nom').agg(
    nb_adresses=('uid_adresse', 'count'),
    lon_moy=('long', 'mean')
).reset_index()

result.sort_values('lon_moy').head(10)
```

**Question 2** Sur `df_tarbes`, créez une colonne `adresse_complete` qui
concatène `numero`, `' '` et `voie_nom` (ex : `"12 RUE DES FLEURS"`).

```python
# À vous !
df_tarbes = df_ban[df_ban['commune_nom'] == 'Tarbes']

df_tarbes['adresse_complete'] = df_tarbes['numero'] + ' ' + df_tarbes['voie_nom']

df_tarbes[['numero', 'voie_nom', 'adresse_complete']].head()
```

**Question 3** Tracez un histogramme du nombre d’adresses par commune.
Utilisez `bins=30`. Que remarquez-vous sur la distribution ?

```python
# À vous !
import matplotlib.pyplot as plt

df_ban['commune_nom'].value_counts().hist(bins=30)

plt.title("Histogramme du nombre d’adresses par commune")
plt.xlabel("Nombre d’adresses")
plt.ylabel("Nombre de communes")

plt.show()
```

**Question 4** Identifiez les communes ayant moins de 10 adresses dans
la BAN. Combien sont-elles ?

## Récapitulatif des fonctions clés

| Fonction / Méthode | Rôle |
|------------------------------------|------------------------------------|
| `pd.DataFrame({...})` | Créer un DataFrame depuis un dictionnaire |
| `pd.read_csv(path, sep=, dtype=)` | Lire un fichier CSV |
| `df.to_csv(path, index=False)` | Écrire un fichier CSV |
| `df.head(n)` / `df.tail(n)` | Aperçu des premières / dernières lignes |
| `df.info()` | Types, mémoire, valeurs non-nulles |
| `df.describe()` | Statistiques descriptives |
| `df.shape` / `df.size` | Dimensions / nombre total d’éléments |
| `df.dtypes` | Type de chaque colonne |
| `df.columns` / `df.index` | Étiquettes de colonnes / lignes |
| `df.loc[lignes, colonnes]` | Sélection par étiquette |
| `df.iloc[lignes, colonnes]` | Sélection par position |
| `df['col'].values` | Récupérer le ndarray sous-jacent |
| `df[condition]` | Filtrage par masque booléen |
| `df['col'].value_counts()` | Fréquences de chaque valeur |
| `df['col'].nunique()` | Nombre de valeurs distinctes |
| `df['col'].unique()` | Liste des valeurs distinctes |
| `df.sort_values('col')` | Tri par colonne |
| `df.groupby('col').agg(...)` | Agrégation par groupe |
| `df.isnull()` / `.sum()` | Détecter / compter les NaN |
| `df.dropna()` | Supprimer les lignes avec NaN |
| `df.fillna(valeur)` | Remplacer les NaN |
| `df.drop(columns=[...])` | Supprimer des colonnes |
| `df.rename(columns={...})` | Renommer des colonnes |
| `pd.melt(df, id_vars=, value_vars=)` | Transformer wide -\> long |
| `np.where(cond, vrai, faux)` | Créer une colonne catégorielle |
| `df['col'].apply(fonction)` | Appliquer une fonction élément par élément |

Dans le module suivant (GeoPandas A1), nous ajouterons une colonne
`geometry` à ce même DataFrame `df_ban` pour le transformer en
GeoDataFrame et visualiser les adresses sur une carte.
