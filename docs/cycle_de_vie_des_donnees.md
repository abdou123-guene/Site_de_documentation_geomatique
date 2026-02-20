**Consignes :** 

**\-** A l'aide de l'outil de votre choix,

**\-** en reprenant le trame des étapes décrites pendant le cours,

**\=\>** vous restituerez un schéma décrivant les outils et les détails qui semble nécessaires à la description du cycle de vie des données dans les missions que vous remplissez dans votre entreprise. Détaillez quelles sont les actions que vous effectuez à chaque étape.

Le résultat est à déposer dans la zone de dépôt qui suit ces consignes. Il permettra de valider les objectifs d'acquis du cours et aussi d'avoir un regard sur votre vision des missions qu'on vous confie.

En conclusion, nous partagerons nos différentes visions.  
\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

# **Cycle de vie des données – Version AUDC (modèle du professeur)**

### **👉 Structure imposée :**

1. Acquisition  
2. Vérification  
3. Validation  
4. Réutilisation  
5. Archivage  
6. Planification  
7. Retour à : Acquisition

Je te détaille **à chaque étape ce que tu fais réellement**.

---

# **Acquisition**

**Objectif : obtenir les données nécessaires à une mission.**

### **🧰 Outils :**

* QGIS (WFS / WMS / téléchargements)  
* PostGIS (imports)  
* Data.gouv.fr, IGN, Etalab  
* Données envoyées par les collectivités (EPCI, communes, DDT)

### **🧑‍💻 Ce que TU fais à l’AUDC :**

* Récupérer les données d’urbanisme (PLU, SCOT, zonages).  
* Télécharger les données BAN, BD TOPO, cadastre, population.  
* Importer les fichiers dans PostGIS.  
* Centraliser les données reçues des partenaires.

---

# **Vérification**

**Objectif : s’assurer que les données sont correctes techniquement.**

### **🧰 Outils :**

* QGIS : Validité géométrique, Topologie  
* PostGIS : `ST_IsValid`, `ST_IsEmpty`, `ST_Area`, `ST_DWithin`

### **🧑‍💻 Tu vérifies :**

* les géométries valides  
* les géométries vides ou nulles  
* les doublons  
* les projections (EPSG 2154, 4326\)  
* les attributs incohérents (nom commune, code INSEE, code postal)

Exemple AUDC :  
✨ vérifier les différences entre `pertuis_mauvais` et la référence PLU.

---

# **Validation**

**Objectif : rendre la donnée fiable et utilisable.**

### **🧰 Outils :**

* PostGIS (MakeValid, unions, correctifs)  
* QGIS (réparations, cleaning)

### **🧑‍💻 Tu fais :**

* correction des géométries invalides  
* normalisation des champs (format texte, majuscules, codes)  
* mise au propre des attributs  
* validation avec un chef de projet si besoin

Exemple AUDC :  
✨ nettoyage BAN 2019 → version 2026\.

---

# **Réutilisation**

**Objectif : utiliser la donnée pour produire un résultat.**

### **🧰 Outils :**

* QGIS (analyses, mises en page)  
* PostGIS (analyses spatiales)  
* R (mapsf, tmap)

### **🧑‍💻 Tu fais :**

* analyses (densité, buffers, intersections)  
* création de cartes pour les études  
* extraction de données pour les urbanistes  
* jointures spatiales (adresses ↔ zonages)

Exemple AUDC :  
✨ cartes SCOT, cartes mobilité, diagnostics de territoire.

---

# **Archivage**

**Objectif : conserver une version stable des données.**

### **🧰 Outils :**

* PostGIS (tables \_archive, schémas versionnés)  
* Dossiers réseau (archives)

### **🧑‍💻 Tu fais :**

* sauvegarde de la version utilisée  
* archivage par année ou par projet  
* export GPKG / SHP si besoin  
* documentation : source, date, traitement, version

Exemple AUDC :  
✨ garder des copies des PLU ou des millésimes BAN.

---

# **Planification**

**Objectif : préparer la prochaine mise à jour.**

### **🧰 Outils :**

* Calendrier interne  
* Discussions avec responsables études  
* Planning de données partenaires (IGN, INSEE, collectivités)

### **🧑‍💻 Tu fais :**

* identifier les données à actualiser (PLU, adresses, zonages)  
* estimer le temps de travail  
* préparer les scripts (SQL, QGIS, modèles)

Exemple AUDC :  
✨ anticiper la mise à jour annuelle ou la réception d’un nouveau PLU.

---

# **Retour à l’Acquisition**

**Le cycle recommence.**

→ Tu acquiers de nouvelles données  
→ Tu vérifies  
→ Tu valides  
→ etc.

---

# **Idée de schéma visuel (prêt à dessiner)**

Tu peux faire un schéma en cercle :

     \[Acquisition\]  
           ↓  
    \[Vérification\]  
           ↓  
      \[Validation\]  
           ↓  
     \[Réutilisation\]  
           ↓  
        \[Archives\]  
           ↓  
     \[Planification\]  
           ↓  
      \[Acquisition\]

Avec dans chaque bloc :

* outils que tu utilises  
* actions que tu réalises

