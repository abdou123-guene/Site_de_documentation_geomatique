# Visualisation des données

La visualisation des données est une étape préliminaire indispensable
avant d’appliquer tout algorithme d’apprentissage automatique. Elle
permet de mieux comprendre la structure des données et d’anticiper les
difficultés potentielles (chevauchement de classes, données aberrantes,
etc.).

Dans le notebook précédent, nous avons déjà visualisé quelques séries
temporelles pour vérifier la qualité de l’imputation. Ici, nous allons
explorer les données à une échelle plus globale.

**Remarque** : en pratique, on dispose souvent de peu de données
labellisées. Veillez à ne pas vous laisser influencer par le biais
d’étiquetage (*label bias*) : ne regardez les labels qu’après avoir
formé une première intuition sur les données brutes.

```python
import matplotlib.pyplot as plt
import geopandas as gpd
import numpy as np
import pandas as pd
# chemin
CLEANED_TIMESERIES_PATH = './sentinel2_data/cleaned_time_series'
# charger les données
cleaned_gdf = gpd.read_file(f'{CLEANED_TIMESERIES_PATH}/T31TCJ_median_ndvi.shp')
# récupérer les colonnes dates
cleaned_cols = cleaned_gdf.columns
list_clean_dates = [col for col in cleaned_cols if len(col) == 8 and col.isdigit()]
# transformation en dates
from datetime import datetime
dti = pd.to_datetime([x[0:4]+'-'+x[4:6]+'-'+x[6:] for x in list_clean_dates])
print(cleaned_gdf.shape)
```

```python
CLEANED_TIMESERIES_PATH = './sentinel2_data/cleaned_time_series'

data = gpd.read_file(f'{CLEANED_TIMESERIES_PATH}/T31TCJ_median_ndvi_knn_impute.shp')

list_clean_dates = [col for col in data.columns if len(col) == 8 and col.isdigit()]
feat = data[list_clean_dates]
lab = data['CODE_GROUP'].values.astype(int)

# Si des NaN subsistent (ex. : exercice 00600 non complété), on les comble
# par interpolation linéaire le long de l'axe temporel (axis=1 = par parcelle),
# puis bfill/ffill pour les bords de série (début ou fin entièrement manquants).
n_nan = feat.isna().sum().sum()
if n_nan > 0:
    print(f"Attention : {n_nan} NaN résiduels -> imputation par interpolation temporelle.")
    feat = feat.interpolate(axis=1).bfill(axis=1).ffill(axis=1)

print("Matrice de features :", feat.shape)  # parcelles x dates
print("Labels :", lab.shape)

dti = pd.to_datetime(pd.Series(list_clean_dates))
```

## Visualisation globale : médiane et IQR

Commençons par visualiser la médiane et l’intervalle interquartile (IQR)
de l’ensemble des parcelles, sans distinction de classe :

```python
median = np.nanmedian(feat.values, axis=0)
IQR = np.nanpercentile(feat.values, [25, 75], axis=0)

ts_median = pd.Series(median, index=dti)
ts_Q1 = pd.Series(IQR[0], index=dti)
ts_Q3 = pd.Series(IQR[1], index=dti)

fig, ax = plt.subplots()
ax.plot(ts_median, marker='x', color='grey', label='médiane globale')
ax.fill_between(ts_median.index, ts_Q1, ts_Q3, color='grey', alpha=0.2)
_ = plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

Cette visualisation mélange tous les types de cultures, ce qui n’est pas
très informatif.

## Visualisation par type cultural

Tracez maintenant la médiane et l’IQR séparément pour chaque classe
(label `1` = Blé tendre d’hiver, label `2` = Maïs), en utilisant la
variable `lab`.

Créez d’abord une fonction `compute_median_IQR_ts(df, dti)` qui retourne
`ts_median`, `ts_Q1` et `ts_Q3` pour une matrice de données donnée.

```python
# écrivez la fonction compute_median_IQR_ts
# def compute_median_IQR_ts(df, dti):
#     ...

# puis tracez les deux classes avec des couleurs différentes
# idx_1 = np.where(lab == 1)[0]
# idx_2 = np.where(lab == 2)[0]
```

**Solution en 4 étapes**

```python
# 1. Fonction compute_median_IQR_ts
def compute_median_IQR_ts(df, dti):
    
    # remplacer -9999 par NaN si nécessaire
    df = df.replace(-9999, np.nan)
    # calcul médiane et quartiles
    median_vals = df.median(axis=0)
    Q1_vals = df.quantile(0.25, axis=0)
    Q3_vals = df.quantile(0.75, axis=0)
    # conversion en séries temporelles
    ts_median = pd.Series(median_vals.values, index=dti)
    ts_Q1 = pd.Series(Q1_vals.values, index=dti)
    ts_Q3 = pd.Series(Q3_vals.values, index=dti)
    return ts_median, ts_Q1, ts_Q3
```

On observe un lien direct entre le NDVI et la phénologie de chaque
culture. Avec un seul indice spectral, les deux classes sont déjà bien
caractérisées.

```python
# 2. Séparer les classes (Blé vs Maïs)
# ces indices sont nécessaires pour la suite ; définissez-les si ce n'est pas déjà fait
idx_1 = np.where(lab == 1)[0]  # Blé tendre
idx_2 = np.where(lab == 2)[0]  # Maïs
```

```python
# 3. Calcul des statistiques par classe
# Blé
ts_median_1, ts_Q1_1, ts_Q3_1 = compute_median_IQR_ts(
    cleaned_gdf.iloc[idx_1][list_clean_dates],
    dti
)
# Maïs
ts_median_2, ts_Q1_2, ts_Q3_2 = compute_median_IQR_ts(
    cleaned_gdf.iloc[idx_2][list_clean_dates],
    dti
)
```

```python
# 4. VISUALISATION (IMPORTANT)
fig, ax = plt.subplots()
# Blé (bleu)
ax.plot(ts_median_1, color='blue', label='Blé - médiane')
ax.fill_between(ts_median_1.index, ts_Q1_1, ts_Q3_1,
                color='blue', alpha=0.2, label='Blé - IQR')
# Maïs (orange)
ax.plot(ts_median_2, color='orange', label='Maïs - médiane')
ax.fill_between(ts_median_2.index, ts_Q1_2, ts_Q3_2,
                color='orange', alpha=0.2, label='Maïs - IQR')
# mise en forme
ax.set_xlabel("Date")
ax.set_ylabel("NDVI médian")
ax.set_title("NDVI par type de culture")
plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

### Influence du choix des percentiles

L’IQR (P25–P75) ne décrit que la moitié centrale des données. Si l’on
utilise des percentiles extrêmes (P1–P99), la séparation visuelle entre
classes devient moins évidente : les distributions se chevauchent
davantage.

```python
def compute_median_P1_P99_ts(df, dti):
    median = np.nanmedian(df, axis=0)
    ts_median = pd.Series(median, index=dti)
    perc = np.nanpercentile(df, [1, 99], axis=0)
    ts_P1 = pd.Series(perc[0], index=dti)
    ts_P99 = pd.Series(perc[1], index=dti)
    return ts_median, ts_P1, ts_P99

ts_median_1, ts_P1_1, ts_P99_1 = compute_median_P1_P99_ts(feat.values[idx_1, :], dti)
ts_median_2, ts_P1_2, ts_P99_2 = compute_median_P1_P99_ts(feat.values[idx_2, :], dti)

fig, ax = plt.subplots()
ax.plot(ts_median_1, marker='x', color='darkcyan', label='1 (Blé tendre hiver)')
ax.fill_between(ts_median_1.index, ts_P1_1, ts_P99_1, color='darkcyan', alpha=0.2)
ax.plot(ts_median_2, marker='x', color='orange', label='2 (Maïs)')
ax.fill_between(ts_median_2.index, ts_P1_2, ts_P99_2, color='orange', alpha=0.2)
_ = plt.xticks(rotation=50)
plt.legend()
plt.tight_layout()
plt.show()
```

Les percentiles extrêmes révèlent que les queues de distribution des
deux cultures se chevauchent : il existe des parcelles de blé avec un
NDVI estival bas, et des parcelles de maïs avec un NDVI printanier
élevé. Ces cas atypiques (parcelles en bordure de champ, stress
hydrique, semis tardif…) seront inévitablement difficiles à classer.

**Conclusion pratique** : pour la suite du pipeline (clustering et
classification), on utilisera directement les valeurs NDVI brutes par
date — pas les percentiles. Cette visualisation sert uniquement à
comprendre la variabilité des données et à anticiper les erreurs de
classification sur les cas extrêmes.

## Réduction de dimensionnalité

Nos données ont autant de dimensions que de dates.

```python
print(f"Nous avons donc {feat.shape[1]} dimensions.")
```

Pour visualiser leur structure en 2D ou 3D, nous utilisons des méthodes
de réduction de dimensionnalité.

Ces méthodes sont utiles pour :

1.  la visualisation exploratoire ;
2.  améliorer les performances des algorithmes (moins de variables
    corrélées) ;
3.  réduire la complexité de stockage et de calcul.

Avant tout, nous standardisons les données (moyenne = 0, variance = 1),
ce qui est recommandé pour la plupart des méthodes basées sur les
distances ou la variance.

```python
import sys
sys.path.append('/home/idgeo/.local/lib/python3.12/site-packages')
from sklearn.preprocessing import StandardScaler
```

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
X_scaled = scaler.fit_transform(feat)
print(X_scaled.shape)
```

### ACP (Analyse en Composantes Principales)

L’ACP (*Principal Component Analysis*, PCA) cherche les combinaisons
linéaires des variables d’origine qui maximisent la variance des données
projetées.

```python
from sklearn.decomposition import PCA

pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_scaled)
print("Variance expliquée :", pca.explained_variance_ratio_)

X_pca_1 = X_pca[idx_1, :]
X_pca_2 = X_pca[idx_2, :]

fig, ax = plt.subplots()
ax.scatter(X_pca_1[:, 0], X_pca_1[:, 1], color='darkcyan', label='1 (Blé tendre hiver)', alpha=0.5)
ax.scatter(X_pca_2[:, 0], X_pca_2[:, 1], color='orange', label='2 (Maïs)', alpha=0.5)
ax.set_xlabel('CP1')
ax.set_ylabel('CP2')
plt.legend()
plt.tight_layout()
plt.show()
```

On peut également afficher une troisième composante en 3D :

```python
pca_3d = PCA(n_components=3)
X_pca_3d = pca_3d.fit_transform(X_scaled)

X_pca_1_3d = X_pca_3d[idx_1, :]
X_pca_2_3d = X_pca_3d[idx_2, :]

fig = plt.figure()
ax = fig.add_subplot(projection='3d')
ax.scatter(X_pca_1_3d[:, 0], X_pca_1_3d[:, 1], X_pca_1_3d[:, 2],
           color='darkcyan', label='1 (Blé tendre hiver)', alpha=0.5)
ax.scatter(X_pca_2_3d[:, 0], X_pca_2_3d[:, 1], X_pca_2_3d[:, 2],
           color='orange', label='2 (Maïs)', alpha=0.5)
plt.legend()
plt.tight_layout()
plt.show()
```

#### Évaluation de l’ACP

Les deux classes sont clairement séparées dans l’espace CP1–CP2. Ces
résultats sont suffisants pour la suite du pipeline : nous nous arrêtons
donc ici pour la réduction de dimensionnalité.

**Les méthodes suivantes (Kernel PCA, t-SNE, Auto-encodeur, VAE) sont
présentées à titre indicatif**, pour vous donner une culture générale
des outils disponibles. Elles deviendraient pertinentes si :

- l’ACP ne séparait pas bien les classes (structure non linéaire) ;
- le nombre de classes ou la complexité des données augmentait ;
- on travaillait sur des données très haute dimension (images,
  hyperspectral).

Pour ce problème, les utiliser serait de la sur-ingénierie.

### ACP à noyau (Kernel PCA)

L’ACP classique ne capture que les relations linéaires. La Kernel PCA
applique d’abord une transformation non linéaire des données (via une
fonction noyau), puis effectue une ACP dans cet espace transformé.

```python
from sklearn.decomposition import KernelPCA

kpca = KernelPCA(n_components=2, kernel='rbf')
X_kpca = kpca.fit_transform(X_scaled)
print(X_kpca.shape)

X_kpca_1 = X_kpca[idx_1, :]
X_kpca_2 = X_kpca[idx_2, :]

fig, ax = plt.subplots()
ax.scatter(X_kpca_1[:, 0], X_kpca_1[:, 1], color='darkcyan', label='1 (Blé tendre hiver)', alpha=0.5)
ax.scatter(X_kpca_2[:, 0], X_kpca_2[:, 1], color='orange', label='2 (Maïs)', alpha=0.5)
ax.set_xlabel('KCP1')
ax.set_ylabel('KCP2')
plt.legend()
plt.tight_layout()
plt.show()
```

### t-SNE

Le t-SNE (*t-Distributed Stochastic Neighbor Embedding*) est une méthode
non linéaire qui place les points similaires proches et les points
dissimilaires loin les uns des autres, avec une forte probabilité.

**Points d’attention** :

- t-SNE est plus puissant que l’ACP pour révéler des structures locales,
  mais plus lent.
- Il n’est **pas déterministe** : deux exécutions peuvent donner des
  résultats différents.
- Les distances absolues entre clusters n’ont pas de signification
  interprétable.

```python
from sklearn.manifold import TSNE

tsne = TSNE(n_components=2, random_state=42)
X_tsne = tsne.fit_transform(X_scaled)
print(X_tsne.shape)

X_tsne_1 = X_tsne[idx_1, :]
X_tsne_2 = X_tsne[idx_2, :]

fig, ax = plt.subplots()
ax.scatter(X_tsne_1[:, 0], X_tsne_1[:, 1], color='darkcyan', label='1 (Blé tendre hiver)', alpha=0.5)
ax.scatter(X_tsne_2[:, 0], X_tsne_2[:, 1], color='orange', label='2 (Maïs)', alpha=0.5)
ax.set_xlabel('t-SNE 1')
ax.set_ylabel('t-SNE 2')
plt.legend()
plt.tight_layout()
plt.show()
```

### Auto-encodeur (AE)

Un auto-encodeur est un réseau de neurones entraîné à reconstruire ses
entrées après les avoir compressées dans un espace latent de faible
dimension. Il est composé de deux parties :

- l’**encodeur** : compresse les données de dimension `D` vers
  `latent_dim` ;
- le **décodeur** : reconstruit les données d’origine à partir de
  l’espace latent.

La représentation latente peut ensuite être utilisée pour la
visualisation.

```python
!pip install tensorflow --break-system-packages
```

```python
import sys
sys.path.append('/home/idgeo/.local/lib/python3.12/site-packages')
import tensorflow as tf
```

```python
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
```

```python
latent_dim = 2
intermediate_dim = 16
input_dim = X_scaled.shape[1]

# encodeur
encoder_inputs = keras.Input(shape=(input_dim,))
x = layers.Dense(input_dim, activation="relu")(encoder_inputs)
x = layers.Dense(input_dim, activation="relu")(x)
x = layers.Dense(intermediate_dim, activation="relu")(x)

encoded = layers.Dense(latent_dim)(x)  # linear

encoder = keras.Model(encoder_inputs, encoded, name="encoder")
encoder.summary()
```

```python
# décodeur
latent_inputs = keras.Input(shape=(latent_dim,))
x = layers.Dense(intermediate_dim, activation="relu")(latent_inputs)
x = layers.Dense(intermediate_dim, activation="relu")(x)
decoder_outputs = layers.Dense(input_dim, activation="linear")(x)
decoder = keras.Model(latent_inputs, decoder_outputs, name="decoder")
decoder.summary()
```

```python
# auto-encodeur complet
decoder_outputs_ae = decoder(encoder(encoder_inputs))
autoencoder = keras.Model(encoder_inputs, decoder_outputs_ae)
autoencoder.compile(optimizer='adam', loss='mse')
autoencoder.summary()
```

```python
X_train = X_scaled.copy()
history = autoencoder.fit(X_train, X_train, epochs=100, batch_size=32)
```

```python
mu = encoder.predict(X_train, batch_size=32)
mu = np.array(mu)

X_ae_1 = mu[idx_1, :]
X_ae_2 = mu[idx_2, :]

fig, ax = plt.subplots()
ax.scatter(X_ae_1[:, 0], X_ae_1[:, 1], color='darkcyan', label='1 (Blé tendre hiver)', alpha=0.5)
ax.scatter(X_ae_2[:, 0], X_ae_2[:, 1], color='orange', label='2 (Maïs)', alpha=0.5)
ax.set_xlabel('Latent 1')
ax.set_ylabel('Latent 2')
plt.legend()
plt.tight_layout()
plt.show()
```

### Auto-encodeur variationnel (VAE)

Le VAE est une extension probabiliste de l’AE classique. Au lieu de
produire un vecteur latent déterministe, l’encodeur produit une
distribution gaussienne paramétrée par `z_mean` et `z_log_var`. Un
vecteur `z` est alors échantillonné depuis cette distribution.

La fonction de perte combine une **perte de reconstruction** (MSE) et un
**terme de régularisation KL** qui force l’espace latent à rester proche
d’une gaussienne standard. Cela donne un espace latent plus lisse et
mieux structuré.

```python
class Sampling(layers.Layer):
    """Échantillonne z à partir de (z_mean, z_log_var)."""
    def call(self, inputs):
        z_mean, z_log_var = inputs
        batch = tf.shape(z_mean)[0]
        dim = tf.shape(z_mean)[1]
        epsilon = tf.keras.backend.random_normal(shape=(batch, dim))
        return z_mean + tf.exp(0.5 * z_log_var) * epsilon
```

```python
latent_dim = 2
intermediate_dim = 32
input_dim = X_scaled.shape[1]

# encodeur VAE
encoder_inputs = keras.Input(shape=(input_dim,))
x = layers.Dense(input_dim, activation="relu")(encoder_inputs)
x = layers.Dense(intermediate_dim, activation="relu")(x)
z_mean = layers.Dense(latent_dim, name="z_mean")(x)
z_log_var = layers.Dense(latent_dim, name="z_log_var")(x)
z = Sampling()([z_mean, z_log_var])
encoder_vae = keras.Model(encoder_inputs, [z_mean, z_log_var, z], name="encoder_vae")
encoder_vae.summary()
```

```python
# décodeur VAE
latent_inputs = keras.Input(shape=(latent_dim,))
x = layers.Dense(intermediate_dim, activation="relu")(latent_inputs)
decoder_outputs = layers.Dense(input_dim, activation="linear")(x)
decoder_vae = keras.Model(latent_inputs, decoder_outputs, name="decoder_vae")
decoder_vae.summary()
```

# Corrigée juste en bas 

# modèle VAE complet avec perte combinée reconstruction + KL
decoder_outputs_vae = decoder_vae(encoder_vae(encoder_inputs)[2])
vae = keras.Model(encoder_inputs, decoder_outputs_vae, name='vae_mlp')

mse = tf.keras.losses.MeanSquaredError()
reconstruction_loss = mse(encoder_inputs, decoder_outputs_vae)

kl_loss = -0.5 * (1 + z_log_var - tf.square(z_mean) - tf.exp(z_log_var))
kl_loss = tf.reduce_mean(tf.reduce_sum(kl_loss, axis=1))

beta = 1.0
vae_loss = reconstruction_loss + beta * kl_loss
vae.add_loss(vae_loss)

```python
import keras
from keras import layers
from keras import ops

# --- classe VAE personnalisée ---
class VAE(keras.Model):
    def __init__(self, encoder, decoder, beta=1.0, **kwargs):
        super(VAE, self).__init__(**kwargs)
        self.encoder = encoder
        self.decoder = decoder
        self.beta = beta
    def call(self, inputs):
        # encoder
        z_mean, z_log_var, z = self.encoder(inputs)
        # decoder
        reconstructed = self.decoder(z)
        # reconstruction loss
        recon_loss = ops.mean(
            ops.sum(
                ops.square(inputs - reconstructed),
                axis=1
            )
        )
        # KL loss
        kl_loss = -0.5 * ops.mean(
            ops.sum(
                1 + z_log_var - ops.square(z_mean) - ops.exp(z_log_var),
                axis=1
            )
        )
        # perte totale
        self.add_loss(recon_loss + self.beta * kl_loss)
        return reconstructed
# --- création du modèle ---
vae = VAE(encoder_vae, decoder_vae, beta=1.0)
# --- compilation ---
vae.compile(optimizer='adam')
vae.summary()
```

```python
X_train = X_scaled.copy()
vae.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3))
history = vae.fit(X_train, X_train, epochs=30, batch_size=32)
```

```python
mu_vae, _, _ = encoder_vae.predict(X_train, batch_size=32)
mu_vae = np.array(mu_vae)

X_vae_1 = mu_vae[idx_1, :]
X_vae_2 = mu_vae[idx_2, :]

fig, ax = plt.subplots()
ax.scatter(X_vae_1[:, 0], X_vae_1[:, 1], color='darkcyan', label='1 (Blé tendre hiver)', alpha=0.5)
ax.scatter(X_vae_2[:, 0], X_vae_2[:, 1], color='orange', label='2 (Maïs)', alpha=0.5)
ax.set_xlabel('z_mean 1')
ax.set_ylabel('z_mean 2')
plt.legend()
plt.tight_layout()
plt.show()
```

### Remarques finales sur la réduction de dimensionnalité

- Les AE et VAE ont tendance à sur-apprendre et sont difficiles à régler
  (de nombreux hyperparamètres à ajuster).
- En général, on préfère le VAE car son espace latent est plus régulier
  (normalisé, continu), ce qui facilite l’interprétation et la
  génération.
- Pour un problème aussi bien séparé que celui-ci, l’ACP linéaire suffit
  déjà à distinguer les classes : méfiez-vous de la sur-ingénierie.
