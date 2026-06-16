# Workflow Classification Raster — Buffer → Random Forest → Évaluation
---

## Objectif global
Mettre en place une chaîne complète de classification supervisée en télédétection :

1. Rasterisation des polygones (labels)
2. Apprentissage Random Forest
3. Évaluation du modèle

---

# 1. Rasterisation (création des labels)

## Objectif
Transformer un shapefile de polygones en raster de classes.

## Code
```python
import geopandas as gpd
import rasterio
from rasterio.features import rasterize
import numpy as np
from pathlib import Path

VECTOR_PATH = Path(r"C:\...\training_dataset.shp")
TARGET_RASTER = Path(r"C:\...\B02.tif")
OUT_LABEL_RASTER = Path(r"C:\...\training_labels.tif")

CLASS_FIELD = "classe"
NODATA = 0

gdf = gpd.read_file(VECTOR_PATH)

with rasterio.open(TARGET_RASTER) as src:
    meta = src.meta.copy()
    transform = src.transform
    H, W = src.height, src.width

if gdf.crs != meta['crs']:
    gdf = gdf.to_crs(meta['crs'])

gdf = gdf[~gdf.geometry.is_empty & gdf.geometry.notnull()]

shapes = [(geom, int(cls)) for geom, cls in zip(gdf.geometry, gdf[CLASS_FIELD])]

labels = rasterize(
    shapes=shapes,
    out_shape=(H, W),
    transform=transform,
    fill=NODATA,
    dtype="int16"
).astype(np.int8)

meta.update({"count":1,"dtype":"int8","nodata":NODATA})

with rasterio.open(OUT_LABEL_RASTER,"w",**meta) as dst:
    dst.write(labels,1)
```

Résultat : raster d’apprentissage

---

# 2. Random Forest

## Objectif
Apprendre un modèle pour prédire la classe de chaque pixel

## Code (simplifié et corrigé)
```python
from pathlib import Path
import rasterio
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import joblib

LABEL_RASTER_PATH = Path("training_labels.tif")
RASTER_DIR = Path("bands/")

# Lecture labels
with rasterio.open(LABEL_RASTER_PATH) as src:
    labels = src.read(1)

# Lecture bandes
paths = sorted(RASTER_DIR.glob("*.tif"))
stack = []

for p in paths:
    with rasterio.open(p) as src:
        stack.append(src.read(1))

data = np.stack(stack)

# Pixels valides
mask = labels > 0
X = data[:,mask].T
y = labels[mask]

# Train/test
X_train,X_test,y_train,y_test = train_test_split(X,y,test_size=0.2,stratify=y)

# Modèle
clf = RandomForestClassifier(n_estimators=1000,n_jobs=-1)
clf.fit(X_train,y_train)

print("Accuracy :",clf.score(X_test,y_test))

joblib.dump(clf,"rf_model.pkl")
```

Résultat : modèle + classification

---

# 3. Évaluation

## Objectif
Mesurer la performance du modèle

## Code corrigé
```python
import numpy as np
import geopandas as gpd
import rasterio
from sklearn.metrics import confusion_matrix

with rasterio.open("classification.tif") as src:
    raster = src

gdf = gpd.read_file("validation.shp")

if gdf.crs != raster.crs:
    gdf = gdf.to_crs(raster.crs)

coords = [(geom.x,geom.y) for geom in gdf.geometry]
values = list(raster.sample(coords))

y_true = gdf["class"].values
y_pred = np.array([v[0] for v in values])

mask = y_pred > 0
y_true = y_true[mask]
y_pred = y_pred[mask]

cm = confusion_matrix(y_true,y_pred)
print(cm)

accuracy = (y_true==y_pred).sum()/len(y_true)
print("Accuracy :",accuracy)
```

Résultat : matrice + accuracy

---

# Pipeline global

```
Vecteur → Raster labels
       ↓
Extraction pixels
       ↓
Random Forest
       ↓
Carte classifiée
       ↓
Évaluation
```

---

# Bonnes pratiques

- vérifier projection (CRS)
- supprimer NoData
- équilibrer classes
- utiliser validation indépendante

---

# Conclusion

Ce pipeline est un standard en géomatique et télédétection.

Il permet de transformer des données terrain en carte classifiée exploitable.
