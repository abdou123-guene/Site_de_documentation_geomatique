
# **Cycle de vie des données**

## **Structure:**

1. Acquisition  
2. Vérification  
3. Validation  
4. Réutilisation  
5. Archivage  
6. Planification  
7. Retour à : Acquisition

---

## **Acquisition**

**Objectif : obtenir les données nécessaires à une mission.**

#### **Outils :**

* QGIS (WFS / WMS / téléchargements)  
* PostGIS (imports)  
* Data.gouv.fr, IGN, Etalab  
* Données envoyées par les collectivités (EPCI, communes, DDT)

#### **A l’AUDC (exemple):**

* Récupérer les données d’urbanisme (PLU, SCOT, zonages).  
* Télécharger les données BAN, BD TOPO, cadastre, population.  
* Importer les fichiers dans PostGIS.  
* Centraliser les données reçues des partenaires.

---

## **Vérification**

**Objectif : s’assurer que les données sont correctes techniquement.**

### **Outils :**

* QGIS : Validité géométrique, Topologie  
* PostGIS : `ST_IsValid`, `ST_IsEmpty`, `ST_Area`, `ST_DWithin`

### **Tu vérifies :**

* les géométries valides  
* les géométries vides ou nulles  
* les doublons  
* les projections (EPSG 2154, 4326\)  
* les attributs incohérents (nom commune, code INSEE, code postal)

Exemple AUDC :  
vérifier les différences entre `pertuis_mauvais` et la référence PLU.

---

## **Validation**

**Objectif : rendre la donnée fiable et utilisable.**

### **Outils :**

* PostGIS (MakeValid, unions, correctifs)  
* QGIS (réparations, cleaning)

### **A faire:**

* correction des géométries invalides  
* normalisation des champs (format texte, majuscules, codes)  
* mise au propre des attributs  
* validation avec un chef de projet si besoin

Exemple AUDC :  
Nettoyage BAN 2019 → version 2026\.

---

## **Réutilisation**

**Objectif : utiliser la donnée pour produire un résultat.**

### **Outils :**

* QGIS (analyses, mises en page)  
* PostGIS (analyses spatiales)  
* R (mapsf, tmap)

### **A faire :**

* analyses (densité, buffers, intersections)  
* création de cartes pour les études  
* extraction de données pour les urbanistes  
* jointures spatiales (adresses ↔ zonages)

Exemple AUDC :  
Cartes SCOT, cartes mobilité, diagnostics de territoire.

---

## **Archivage**

**Objectif : conserver une version stable des données.**

### **Outils :**

* PostGIS (tables \_archive, schémas versionnés)  
* Dossiers réseau (archives)

### **A faire :**

* sauvegarde de la version utilisée  
* archivage par année ou par projet  
* export GPKG / SHP si besoin  
* documentation : source, date, traitement, version

Exemple AUDC :  
Garder des copies des PLU ou des millésimes BAN.

---

## **Planification**

**Objectif : préparer la prochaine mise à jour.**

### **Outils :**

* Calendrier interne  
* Discussions avec responsables études  
* Planning de données partenaires (IGN, INSEE, collectivités)

### **A faire :**

* identifier les données à actualiser (PLU, adresses, zonages)  
* estimer le temps de travail  
* préparer les scripts (SQL, QGIS, modèles)

Exemple AUDC :  
Anticiper la mise à jour annuelle ou la réception d’un nouveau PLU.

---

## **Retour à l’Acquisition**

**Le cycle recommence.**

→ Tu acquiers de nouvelles données  
→ Tu vérifies  
→ Tu valides  
→ etc.


* actions que tu réalises

