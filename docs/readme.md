<<<<<<< HEAD
Sources de données & métadonnées en géomatique
1) Pourquoi ces deux sujets sont indissociables
En géomatique, une donnée n’existe vraiment que si l’on sait d’où elle vient, ce qu’elle représente, comment elle a été produite et comment on peut la réutiliser.

Les sources de données définissent le quoi (contenu, étendue, précision, fréquence de mise à jour). Les métadonnées assurent le comment et le pourquoi (provenance, qualité, méthodes, droits).

Bien gérés, ces deux volets rendent les projets traçables, comparables et réutilisables, et réduisent les coûts cachés (temps perdu, doublons, erreurs d’analyse).
=======
# L'objectif est de créer un site web de documentation
## Sources de données & métadonnées en géomatique




# Auteur: GUENE Abdou Lahat, géomaticien à AUDC de Châlons-en-Champagne
## <span style="color:pink;">Sources de données utilisées à l’AUDC de Châlons-en Champagne</span>
---

### 1. <span style="color:red;">INSEE</span> - Institut National de la Statistique et des Études Économiques
Sources mobilisées :
- Données de **population** (effectifs, âge, indices de vieillissement/jeunesse, évolution).
- **Revenu médian** et niveaux de vie (FiLoSoFi).
- **Flux de population** :
  - Déplacements **domicile–travail**.
  - Mobilités **résidentielles**.
- Indicateurs socio-économiques : emploi, chômage, ménages, catégories sociales.

### 2. <span style="color:red;">SITADEL</span> - Données sur la construction et le logement
Données utilisées :
- **Permis de construire**.
- **Achèvements** de logements et de locaux.
- Informations détaillées sur :
  - Type de logement (individuel / collectif).
  - Nombre de logements créés ou démolis.
  - Surfaces de plancher.
  - Maîtrise d’ouvrage (publique / privée).
  - Suivi des dynamiques à l’échelle commune, EPCI, département, région.

### 3. <span style="color:red;">BPE</span> - Base Permanente des Équipements (INSEE)
Types d’équipements analysés :
- **Santé** : médecins, pharmacies, hôpitaux.
- **Éducation** : écoles, collèges, lycées.
- **Sports & loisirs** : stades, gymnases, complexes sportifs.
- **Culture** : bibliothèques, musées.
- **Commerces & services** : alimentation, services administratifs.

### 4. Grand Est Mobilité
Données utilisées pour :
- **Flux de déplacements** à l’échelle des **EPCI du Grand Est**.
- Matrices origine–destination.
- Déplacements domicile–travail, études, loisirs.
- Analyse des mobilités et de l’intermodalité.

### 5. <span style="color:red;">IGN</span> - Géoservices
Données vectorielles de référence :
- **Limites administratives** :
  - Communes, EPCI, départements, région.
- **Réseaux de transport** :
  - Routes, voies ferrées, gares, points d’arrêt.
- **Toponymie** et éléments ponctuels :
  - Villes, bourgs, lieux-dits.
- Données pour analyses SIG et cartographies.
- **Ortho-photos et MNT**

### 6. Enseignement supérieur - Partenaires universitaires
Données récupérées auprès d'universités :
- **Effectifs étudiants** (filière, site).
- **Alternants**.
- **Évolutions annuelles** des inscriptions.
- Parfois : réussite, insertion professionnelle.
- **Données isochrones générées à partir du plugin fourni**

### 7. <span style="color:red;">DREAL</span> / Data.gouv
Pour les données sur les diagnostics et la précarité énergétique (CSV et SHP)

### 8. <span style="color:red;">Atmo GE</span>
Pour la qualité de l'air

### 9. <span style="color:red;">DDT51</span>
- Plans situation dispositifs de production énergétique : éolien, photovoltaïque, méthanisation  
- Plans des risques naturels  
- Plans des risques technologiques
---
#### <span style="color:green;">Tableau Synthétique des Sources de Données Utilisées à l’AUDC</span>

**Légende :**  
- <span style="color:pink;">**INSEE**</span>  
- <span style="color:pink;">**SITADEL**</span>  
- <span style="color:pink;">**BPE**</span>  
- <span style="color:pink;">**IGN**</span>  
- <span style="color:pink;">**DREAL**</span>  
- <span style="color:pink;">**ATMO GE**</span>  
- <span style="color:pink;">**DDT51**</span>  

---

### Tableau des sources

| Source | Type de données | Exemples | Usages principaux |
|--------|------------------|----------|-------------------|
| INSEE | Démographie, économie, mobilités | Population, revenus, flux domicile–travail | Portraits de territoires, analyses socio-économiques |
| SITADEL | Construction, habitat | Permis de construire, achèvements, typologie | Suivi de la construction, PLUi, SCOT |
| BPE | Équipements et services | Santé, sports, éducation, culture | Accessibilité, diagnostic territorial |
| Grand Est Mobilité | Mobilités, déplacements | Matrices O/D, flux inter-EPCI | Études de mobilité, intermodalité |
| IGN (Géoservices) | Données SIG | BD TOPO, limites admin., routes, ortho-photos | Cartographie, analyse spatiale |
| Enseignement supérieur | Données universitaires | Effectifs, alternants, évolutions, isochrones | Analyse des formations et de l’attractivité |
| DREAL / Data.gouv | Énergie, précarité | Diagnostics, CSV/SHP | Transition énergétique, observatoires |
| ATMO GE | Environnement | Qualité de l’air, polluants | Santé-environnement, suivi atmosphérique |
| DDT51 | Risques & énergie | Risques naturels, technologiques, éolien/PV | Planification, prévention des risques |

``
# 1) Pourquoi ces deux sujets sont indissociables
En géomatique, une donnée n’existe vraiment que si l’on sait d’où elle vient, ce qu’elle représente, comment elle a été produite et comment on peut la réutiliser.

Les sources de données définissent le quoi (contenu, étendue, précision, fréquence de mise à jour).
Les métadonnées assurent le comment et le pourquoi (provenance, qualité, méthodes, droits).

Bien gérés, ces deux volets rendent les projets traçables, comparables et réutilisables, et réduisent les coûts cachés (temps perdu, doublons, erreurs d’analyse).

# 2) Panorama des sources de données
## 2.1 Données institutionnelles (référentiels & thématiques)

Référentiels : limites administratives, adresses/toponymes, réseaux, MNT/MNS, orthophotos.
Thématiques publiques : occupation du sol, risques, biodiversité, socio‑économie, zonages.
Portails INSPIRE & open data : catalogues nationaux/régionaux avec politiques de mise à jour.

+ garanties de qualité/continuité, documentation, URI stables.
⚠️ surveiller les millésimes, le CRS et les licences.
## 2.2 Imagerie & télédétection

Satellite : optique (sub‑métrique → décamétrique), radar (toute météo), hyperspectral.
Aérien & drone : orthophotos, Lidar (MNT/MNS), relevés thermo/multispectraux.

Clés de choix : résolution (spatiale/temportelle/spectrale), angle de visée, conditions atmos., géoréférencement, modalités d’usage/licence.
## 2.3 GNSS, levés terrain & IoT

GNSS/RTK, tachéomètre, capteurs in situ (qualité eau/air), relevés mobiles (QField, Field Maps).
Points d’attention : plan de levé, tolérances, contrôle qualité sur le terrain, confidentialité (données perso).

## 2.4 Données collaboratives

OpenStreetMap & communs : riches, très à jour localement.
Bonnes pratiques : valider la fraîcheur, croiser avec des sources officielles, respecter l’ODbL.

## 2.5 Données privées / fournisseurs

Bases POI, trafic, imagerie à façon, géocodage, altimétrie premium.
À clarifier : périmètre d’utilisation, SLA, droits de dérivation, restitution, publication.


# 3) Évaluer une source : grille en 8 critères

Pertinence thématique (adéquation au besoin).
Couverture & échelle (emprise, résolution, généralisation).
Actualité (millésime, fréquence de MAJ, latence).
Qualité géométrique (précision planimétrique/altimétrique, topologie).
Qualité sémantique (dictionnaire d’attributs, contrôles de validité).
Traçabilité (lignage) (méthodes, traitements, sources amont).
Interopérabilité (formats: GPKG/GeoJSON/COG/Parquet, CRS, OGC APIs).
Licences & droits (réutilisation, attribution, commercial, RGPD).


Astuce : conserver cette grille dans une fiche de revue de source et la lier à l’enregistrement de métadonnées correspondant.


# 4) Métadonnées : principes, standards & profil minimal
## 4.1 Principes

Découvrabilité (mots‑clés, thèmes, emprise, temps).
Compréhensibilité (résumé, structure attributaire, usages).
Traçabilité/qualité (lignage, précision, limites d’usage).
Réutilisation (licence claire, contraintes).
FAIR : Findable, Accessible, Interoperable, Reusable.

## 4.2 Standards courants

ISO 19115/19139 (jeux & séries, encodage XML/ISO).
INSPIRE (exigences européennes, thèmes environnement).
DCAT / GeoDCAT‑AP (catalogage open data, interop portails/CKAN).

## 4.3 Profil minimal recommandé (catalogue interne)

Titre & Résumé (concis, explicites).
Thèmes/mots‑clés contrôlés, Producteur & Contact.
Emprise (bbox) & Temporalité (dates d’observation / MAJ).
Qualité & lignage (méthodes, contrôles, précision).
Distribution (format, encodage, liens de téléchargement/services), CRS.
Licence (Etalab 2.0, ODbL, CC‑BY…), Contraintes (RGPD/sensibilité).
Version/identifiant (PID/DOI si possible), Responsables (propriétaire/mainteneur).


# 5) Exemple de fiche métadonnées (YAML minimal)
YAMLid: audc-occupation-sol-2024title: "Occupation du sol - AUDC (2024)"abstract: >  Cartographie de l’occupation du sol à 10 classes sur le territoire AUDC,  millésime 2024. Production par classification supervisée d’imagerie  multispectrale et validation terrain.keywords: [occupation du sol, classification, télédétection, AUDC]topic_category: environmentcontacts:  owner: "Direction SIG - AUDC"  maintainer: "sig@audc.example.org"spatial:  bbox: [-1.94, 48.04, -1.35, 48.28]   # minx, miny, maxx, maxy (WGS84)  crs: "EPSG:2154"temporal:  observation_date: "2024-05-01/2024-08-31"  update_frequency: "annually"quality:  positional_accuracy: "±2 m RMSE"  lineage: |    Imagerie SPOT6/7 & Sentinel-2 (2024) → corrections atmos → mosaïque →    indices (NDVI, NDBI…) → échantillonnage terrain →    classification (Random Forest) → lissage → validation (kappa 0.86)distribution:  formats: ["GPKG (layer: os10)", "COG (raster)"]  links:    download: "https://data.audc.example.org/os_2024.gpkg"    wms: "https://geoserver.audc.example.org/wms?service=WMS&request=GetCapabilities"license:  name: "Licence Ouverte / Etalab 2.0"  url: "https://www.etalab.gouv.fr/licence-ouverte-open-licence"version: "2024.1"pid: "doi:10.12345/audc.os.2024"constraints:  personal_data: false  sensitive: falseAfficher plus de lignes

# 6) Publier & rechercher la doc

Catalogue interne/externe : description, recherche, moissonnage.
GitHub Pages : publier docs/ comme site statique (guides, fiches, captures).
Liens relatifs : préférer les chemins relatifs pour garder la doc portable (branches/forks).


# 7) Licences & droits

Distinguer base de données, contenu, œuvres dérivées et code.
Préciser la réutilisation (commerciale, attribution, partage à l’identique).
Exemples : Licence Ouverte / Etalab 2.0, ODbL, CC‑BY/CC‑BY‑SA, contrats fournisseurs.
RGPD : anonymisation/agrégation si données perso, registres de traitement, durées de conservation.


# 8) Qualité & contrôle : check‑list

Avant intégration : CRS, géométrie (self‑intersections, doublons), types/valeurs attributaires.
À l’import : consigner millésime, source, licence, reprojection/traitements.
Après traitement : documenter scripts/paramètres/versions d’outils (reproductibilité).
En diffusion : fournir styles QGIS (QML), aperçus (PNG), métadonnées à jour.


# 9) Automatisation & traçabilité (Git/GitHub)

Versionnement : formats efficaces (GPKG/GeoParquet), Git‑LFS pour gros fichiers.
CI/CD documentaire : lint Markdown, validation YAML (schéma), génération de sommaire, publication Pages.
Revue : Pull Requests avec template dédié ; CODEOWNERS pour /docs/ & /docs/meta/.


# 10) Pièges fréquents & parades

Données sans licence → stop intégration tant qu’une licence explicite n’est pas fournie.
Millésimes mélangés → ajouter un champ millesime + documenter l’assemblage.
Pas de dictionnaire d’attributs → créer docs/schema_<couche>.md.
CRS implicite → stocker l’EPSG dans la fiche + vérifier au chargement.




# 11) Modèle de schéma attributaire (docs/schema_<couche>.md)
## Schéma attributaire — os10 (exemple)

| Champ        | Type   | Unités | Domaine / Codelist                      | Description                        |
|--------------|--------|--------|-----------------------------------------|------------------------------------|
| id           | int    | —      | unique                                  | Identifiant interne                |
| classe       | texte  | —      | 10 classes (cf. `docs/legend_os10.md`)  | Classe d’occupation du sol         |
| conf_score   | int    | 0–100  | —                                       | Score de confiance (classification)|
| date_obs     | date   | —      | AAAA‑MM‑JJ                               | Date d’observation                 |
Traitements non reproductibles → consigner scripts & versions (QGIS/GRASS/GDAL/Python/R).
>>>>>>> 5bb1979d0d2cb94d5ff50b60cacee0d2cd9501f1
