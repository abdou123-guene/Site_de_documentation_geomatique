# OpenEO
---

OpenEO est un standard communautaire et une API ouverte conçus pour simplifier l'accès, le traitement et l'analyse des données d'observation de la Terre (Earth Observation, EO) depuis le cloud.

`openeo.dataspace.copernicus.eu`est le backend openEO du Copernicus Data Space Ecosystem (CDSE), c'est-à-dire l'implémentation concrète de l'API openEO hébergée par l'infrastructure officielle Copernicus de l'Union européenne.

- https://openeo.dataspace.copernicus.eu : point d'accès qui utilise uniquement les ressources CDSE
- https://openeofed.dataspace.copernicus.eu : point d'accès fédéré (recommandé), qui donne accès en plus aux plateformes partenaires de l'écosystème.

Il donne accès aux données Sentinel-1, Sentinel-2, Sentinel-3, Sentinel-5P, Landsat, données CLMS, ...

Il propose les algorithmes suivants (le calcul se fait dans le cloud) :

- Chargement et export des données
    - load_collection : charger une collection (Sentinel-2, Sentinel-1, etc.)
    - save_result : exporter le résultat (GeoTIFF, NetCDF, JSON…)
    - ...

- Opérations sur les datacubes
    - filter_bbox : filtrer par emprise spatiale
    - filter_temporal : filtrer par période
    - filter_bands : sélectionner des bandes
    - filter_spatial : filtrer par géométrie (polygone)
    - resample_spatial / resample_cube_spatial : rééchantillonnage
    - merge_cubes : fusionner deux datacubes
    - apply / apply_neighborhood / apply_dimension : appliquer une fonction

- Réductions
    - reduce_dimension : réduire selon une dimension (ex : médiane temporelle)
    - aggregate_spatial : agréger sur des zones (polygones)
    - aggregate_temporal : agréger par intervalles de temps
    - ...


- Masquage et qualité
    - mask : appliquer un masque
    - mask_polygon : masquer par géométrie

- Séries temporelles et ML
    - fit_curve : ajustement de courbe (Fourier, etc.)
    - predict_curve : prédiction à partir d'un modèle ajusté
    - fit_regr_random_forest : Random Forest pour régression
    - predict_random_forest : prédiction via Random Forest
    - fit_class_random_forest : Random Forest pour classification


Les vers la doc : https://documentation.dataspace.copernicus.eu/APIs/openEO/Processes.html

## Connexion

```python
import openeo
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import rasterio
from rasterio.plot import show

# Connexion au backend
conn = openeo.connect("https://openeo.dataspace.copernicus.eu").authenticate_oidc()

# Vérifications importantes
print("Objet connexion :", conn)
print("Type :", type(conn))

# Test réel (accès au serveur)
collections = conn.list_collections()
print("Nombre de collections disponibles :", len(collections))
```

## Zone de travail

Pour avoir des petits temps de travail nous allons travailler sur une zone de 5×5 km autour de l'Île du Ramier (Toulouse)

```python
# AOI : Île du Ramier + berges Garonne, Toulouse (~5x5 km)
# Centre : 43.578°N, 1.412°E
AOI = {"west": 1.384, "south": 43.555, "east": 1.448, "north": 43.600}
```

## 1. Indices spectraux à la volée

OpenEO calcule les indices **côté serveur** : on ne télécharge jamais les images brutes (13 bandes × toutes les dates), uniquement le résultat final.

| Indice | Formule | Usage |
|---|---|---|
| **NDVI** | (B08−B04)/(B08+B04) | Végétation |
| **NDWI** | (B03−B08)/(B03+B08) | Eau libre |
| **EVI** | 2.5×(B08−B04)/(B08+6B04−7.5B02+1) | Végétation dense (robuste à l'atmosphère) |

```python
# Charger Sentinel-2 L2A — été 2023 (peu de nuages à Toulouse)
s2 = conn.load_collection(
    "SENTINEL2_L2A",
    spatial_extent=AOI,
    temporal_extent=["2023-06-01", "2023-08-31"],
    bands=["B02", "B03", "B04", "B08", "SCL"],
    max_cloud_cover=20,
)

# Masquage nuages via SCL
s2_masked = s2.process(
    "mask_scl_dilation",
    data=s2,
    scl_band_name="SCL",
    mask_values=[1, 2, 3, 7, 8, 9, 10],
).filter_bands(["B02", "B03", "B04", "B08"])

# Composite médiane temporelle
s2_median = s2_masked.reduce_dimension(reducer="median", dimension="t")
```

```python
# --- BANDES ---
nir   = s2_median.band("B08")
red   = s2_median.band("B04")
green = s2_median.band("B03")
blue  = s2_median.band("B02")
# --- NDVI ---
ndvi = (nir - red) / (nir + red)
# --- NDWI ---
ndwi = (green - nir) / (green + nir)
# --- EVI ---
evi = (2.5 * (nir - red)) / (nir + 6 * red - 7.5 * blue + 1)
# --- EXÉCUTION BATCH PLUS STABLE ---
print("Lancement job NDVI...")
job = ndvi.execute_batch(
    title="NDVI Toulouse",
    out_format="GTiff"
)
print("Job lancé ")
print("Statut :", job.status())
# attendre la fin
result = job.download_result("toulouse_ndvi.tiff")
print("✅ NDVI téléchargé avec succès !")
```

```python
def read_band(path):
    with rasterio.open(path) as src:
        return src.read(1).astype(float)

ndvi_arr = read_band("toulouse_ndvi.tiff")
ndwi_arr = read_band("toulouse_ndwi.tiff")
evi_arr  = read_band("toulouse_evi.tiff")

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

im0 = axes[0].imshow(ndvi_arr, cmap="RdYlGn", vmin=-0.2, vmax=0.8)
axes[0].set_title("NDVI — végétation"); axes[0].axis("off")
plt.colorbar(im0, ax=axes[0], fraction=0.046)

im1 = axes[1].imshow(ndwi_arr, cmap="Blues", vmin=-0.5, vmax=0.5)
axes[1].set_title("NDWI — eau (>0 = eau)"); axes[1].axis("off")
plt.colorbar(im1, ax=axes[1], fraction=0.046)

im2 = axes[2].imshow(evi_arr, cmap="YlGn", vmin=-0.1, vmax=0.6)
axes[2].set_title("EVI — végétation dense"); axes[2].axis("off")
plt.colorbar(im2, ax=axes[2], fraction=0.046)

plt.suptitle("Indices spectraux — Toulouse (été 2023)", fontsize=13)
plt.tight_layout()
plt.show()
```

## 2. Série temporelle NDVI sur 1 an

`aggregate_temporal_period` crée une composite mensuelle **directement sur le serveur**. On obtient 12 images NDVI en une seule requête, sans boucle Python.

Cela permet de voir la **phénologie** : cycles agricoles (blé, tournesol) et végétation urbaine autour de Toulouse.

```python
# Charger S2 sur toute l'année 2023
s2_year = conn.load_collection(
    "SENTINEL2_L2A",
    spatial_extent=AOI,
    temporal_extent=["2023-01-01", "2023-12-31"],
    bands=["B04", "B08", "SCL"],
    max_cloud_cover=70,  # plus permissif — la médiane mensuelle filtrera
)

# Masquage nuages
s2_year_masked = s2_year.process(
    "mask_scl_dilation",
    data=s2_year,
    scl_band_name="SCL",
    mask_values=[1, 2, 3, 7, 8, 9, 10],
).filter_bands(["B04", "B08"])

# Agrégation mensuelle par médiane (dimension t → 12 périodes)
s2_monthly = s2_year_masked.aggregate_temporal_period(
    period="month",
    reducer="median",
)

# Dans un callback reduce_dimension, data est un ProcessBuilder (pas un DataCube)
# → utiliser array_element(label=...) au lieu de .band()
def compute_ndvi_callback(data):
    nir = data.array_element(label="B08")
    red = data.array_element(label="B04")
    return (nir - red) / (nir + red)

ndvi_monthly = s2_monthly.reduce_dimension(reducer=compute_ndvi_callback, dimension="bands")

# Le backend CDSE produit un fichier GeoTIFF par mois (12 fichiers séparés)
# → séparer création du job, attente, et téléchargement via download_files()
job = ndvi_monthly.create_job(
    title="NDVI mensuel Toulouse 2023",
    out_format="GTiff",
)
job.start_and_wait()
job.get_results().download_files("toulouse_ndvi_mensuel/")
print(f"Job terminé : {job.job_id}")
print("Fichiers téléchargés dans : toulouse_ndvi_mensuel/")
```

```python
import glob
import os

MOIS = ["Jan", "Fév", "Mar", "Avr", "Mai", "Jun",
        "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc"]

# Lire les 12 fichiers mensuels triés par date
files = sorted(glob.glob("toulouse_ndvi_mensuel/*.tif*"))
print(f"{len(files)} fichiers trouvés : {[os.path.basename(f) for f in files]}")

ndvi_ts = []
for f in files:
    with rasterio.open(f) as src:
        ndvi_ts.append(src.read(1).astype(float))

ndvi_ts = np.array(ndvi_ts)  # shape : (12, rows, cols)
n_mois = len(ndvi_ts)

# Affichage des 12 cartes NDVI
fig, axes = plt.subplots(3, 4, figsize=(18, 12))
for i, ax in enumerate(axes.flat):
    if i < n_mois:
        im = ax.imshow(ndvi_ts[i], cmap="RdYlGn", vmin=-0.2, vmax=0.8)
        ax.set_title(MOIS[i])
    ax.axis("off")
plt.suptitle("NDVI mensuel 2023 — Toulouse (Île du Ramier)", fontsize=14)
plt.colorbar(im, ax=axes, fraction=0.02, label="NDVI")
plt.tight_layout()
plt.show()

# Graphe de phénologie : NDVI moyen par mois
ndvi_mean = [np.nanmean(ndvi_ts[i][ndvi_ts[i] > -1]) for i in range(n_mois)]

fig, ax = plt.subplots(figsize=(10, 4))
ax.plot(range(1, n_mois + 1), ndvi_mean, marker="o", color="green", linewidth=2)
ax.set_xticks(range(1, n_mois + 1))
ax.set_xticklabels(MOIS[:n_mois])
ax.set_ylabel("NDVI moyen")
ax.set_title("Phénologie — NDVI moyen mensuel 2023 (Toulouse)")
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
```
