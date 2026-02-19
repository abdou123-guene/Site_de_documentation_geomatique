# L'objectif est de créer un site web de documentation
## Sources de données & métadonnées en géomatique




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
