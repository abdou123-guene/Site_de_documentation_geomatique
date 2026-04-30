# Analyse d'évolution d'occupation du sol (1999 - 2011)

Analyse multi-temporelle de données raster par classification non supervisée (k-means)

---

### Objectif

Ce script R permet de réaliser une **analyse comparative d’images satellites multi-bandes** afin d’identifier et quantifier les **changements d’occupation du sol** entre deux dates : **1999** et **2011**.

L’approche repose sur :

- Une **classification non supervisée (k-means)**
- Une **analyse de transition entre classes**
- Une **estimation des surfaces en hectares**

---

### Méthodologie

### 1. Chargement des données

L’utilisateur sélectionne deux dossiers contenant des images raster (`.tif`) pour chaque année.

Les bandes sont chargées sous forme de **stack raster** via le package `terra`, permettant de manipuler plusieurs bandes simultanément.

---

### 2. Classification k-means

Une fonction dédiée applique un clustering sur les valeurs spectrales :

- Suppression des valeurs manquantes
- Regroupement en **3 classes**
- Reconstruction d’un raster classifié

Chaque pixel est assigné à une classe en fonction de sa signature spectrale.

---

### 3. Alignement spatial

Le raster de 2011 est **rééchantillonné** pour correspondre à celui de 1999 afin d’assurer une comparaison fiable pixel à pixel.

---

### 4. Matrice de transition

Une matrice croise les classes entre les deux dates :

- Lignes : classes 1999  
- Colonnes : classes 2011  

Elle met en évidence les dynamiques d’évolution des surfaces.

---

### 5. Calcul des surfaces

Les résultats sont convertis en hectares :

- Calcul de la surface d’un pixel  
- Conversion en hectares  
- Application à la matrice de transition  

Le résultat est une matrice directement exploitable pour l’analyse territoriale.

---

### 6. Signatures spectrales

Les centres des classes issus du k-means permettent de tracer les **signatures spectrales** :

- Une courbe par classe  
- Variation de la réflectance selon les bandes  

Ces graphiques facilitent l’interprétation des classes (végétation, eau, sol nu, etc.).

---

### 7. Visualisation

Le script génère :

- Les cartes classifiées (1999 et 2011)  
- Les graphiques de signatures spectrales  

---

### 8. Export des résultats

#### Rasters
- `classification_1999.tif`
- `classification_2011.tif`

#### Graphiques
- `signatures_1999.png`
- `signatures_2011.png`

#### Excel
- `evolution_classes_1999_2011.xlsx`
  - Matrice en pixels  
  - Matrice en hectares  

---

### 9. Contrôle qualité

Les centres des clusters sont affichés en console afin de faciliter l’interprétation et la validation des classes.

---

### Packages utilisés

- `terra` : gestion des rasters  
- `openxlsx` : export Excel  
- `reshape2` : transformation des données  
- `ggplot2` : visualisation  

---

### Points forts

- Méthode automatisée  
- Pas de données d’apprentissage nécessaires  
- Analyse spatiale et quantitative combinée  
- Export direct des résultats exploitables  

---

### Limites

- Correspondance des classes non garantie entre dates  
- Nombre de classes fixé arbitrairement  
- Interprétation experte nécessaire  

---

### Perspectives d’amélioration

- Classification supervisée  
- Optimisation du nombre de classes  
- Ajout d’indices spectraux (NDVI…)  
- Automatisation complète du workflow  

---

Projet réalisé dans un contexte de géomatique appliquée à l’analyse territoriale.

```r
library(terra)
library(openxlsx)
library(reshape2)
library(ggplot2)

# ================================
# 1. CHARGEMENT DES DONNÉES
# ================================

cat("Choisir dossier 1999\n")
chemin1999 <- choose.dir()
bandes1999 <- list.files(chemin1999, pattern = ".tif$", full.names = TRUE)
lena1999 <- rast(bandes1999)

cat("Choisir dossier 2011\n")
chemin2011 <- choose.dir()
bandes2011 <- list.files(chemin2011, pattern = ".tif$", full.names = TRUE)
lena2011 <- rast(bandes2011)

# ================================
# 2. CLASSIFICATION
# ================================

classification_kmeans <- function(raster) {
  
  vals <- raster[]
  vals_valides <- na.omit(vals)
  
  set.seed(99)
  km <- kmeans(vals_valides, centers = 3, iter.max = 500, nstart = 5)
  
  r_class <- rast(raster[[1]])
  full <- rep(NA, ncell(raster))
  full[!is.na(vals[,1])] <- km$cluster
  r_class[] <- full
  
  return(list(raster = r_class, model = km))
}

res1999 <- classification_kmeans(lena1999)
res2011 <- classification_kmeans(lena2011)

class1999 <- res1999$raster
class2011 <- res2011$raster

# ================================
# 3. ALIGNEMENT
# ================================

class2011 <- resample(class2011, class1999, method = "near")

# ================================
# 4. MATRICE
# ================================

vals1999 <- class1999[]
vals2011 <- class2011[]

df <- na.omit(data.frame(vals1999, vals2011))
matrice <- table(df$vals1999, df$vals2011)

# ================================
# 5. SURFACE (hectares)
# ================================

res_m <- res(class1999)
surface_pixel <- res_m[1] * res_m[2]
surface_ha <- surface_pixel / 10000

matrice_surface <- matrice * surface_ha

# ================================
# 6. SIGNATURES SPECTRALES
# ================================

plot_signatures <- function(km, titre) {
  
  centres <- km$centers
  centres_melt <- melt(centres)
  colnames(centres_melt) <- c("Classe", "Bande", "Reflectance")
  
  p <- ggplot(centres_melt,
              aes(x = Bande,
                  y = Reflectance,
                  colour = as.factor(Classe),
                  group = Classe)) +
    geom_point() +
    geom_line() +
    ggtitle(titre)
  
  return(p)
}

plot1999 <- plot_signatures(res1999$model, "Signatures 1999")
plot2011 <- plot_signatures(res2011$model, "Signatures 2011")

# ================================
# 7. VISUALISATION
# ================================

par(mfrow=c(1,2))
plot(class1999, main="Classification 1999")
plot(class2011, main="Classification 2011")

print(plot1999)
print(plot2011)

# ================================
# 8. CHOIX DU DOSSIER DE SORTIE
# ================================

cat("Choisir dossier de sortie\n")
chemin_sortie <- choose.dir()

# ================================
# 9. SAUVEGARDE RASTERS
# ================================

writeRaster(class1999,
            file.path(chemin_sortie, "classification_1999.tif"),
            overwrite = TRUE)

writeRaster(class2011,
            file.path(chemin_sortie, "classification_2011.tif"),
            overwrite = TRUE)

# ================================
# 10. SAUVEGARDE GRAPHIQUES
# ================================

ggsave(file.path(chemin_sortie, "signatures_1999.png"), plot1999)
ggsave(file.path(chemin_sortie, "signatures_2011.png"), plot2011)

# ================================
# 11. EXPORT EXCEL
# ================================

wb <- createWorkbook()

addWorksheet(wb, "Matrice_pixels")
writeData(wb, "Matrice_pixels", as.data.frame(matrice))

addWorksheet(wb, "Matrice_hectares")
writeData(wb, "Matrice_hectares", as.data.frame(matrice_surface))

saveWorkbook(wb,
             file.path(chemin_sortie, "evolution_classes_1999_2011.xlsx"),
             overwrite = TRUE)

# ================================
# 12. CONTROLE FINAL
# ================================

cat("\nCentres 1999:\n")
print(res1999$model$centers)

cat("\nCentres 2011:\n")
print(res2011$model$centers)

cat("\nRésultats enregistrés dans :", chemin_sortie, "\n")
```








