# pgRouting : définition, fonctionnement et exigences
---

## 1. Définition
pgRouting est une extension de PostgreSQL qui fonctionne en complément de PostGIS.
Elle permet d’effectuer des analyses de réseau en s’appuyant sur la théorie des graphes.
Elle transforme des données géographiques (par exemple un réseau routier) en un graphe orienté ou non orienté, composé de :

nœuds (vertices) : intersections ou points de connexion
arcs (edges) : segments de réseau (routes, conduites, etc.)

## 2. Objectifs
L’objectif principal de pgRouting est de modéliser les déplacements dans un réseau et de répondre à des problématiques de navigation ou d’optimisation.
Les objectifs sont notamment :

calculer le plus court chemin entre deux points
déterminer des itinéraires optimaux selon différents critères
analyser l’accessibilité d’un territoire
étudier le fonctionnement des réseaux (transport, eau, énergie)

## 3. Fonctionnement général
Le fonctionnement de pgRouting repose sur plusieurs étapes successives.
### 3.1 Préparation des données
Les données d’entrée doivent représenter un réseau sous forme de géométries de type LINESTRING.
Chaque ligne correspond à un tronçon du réseau.

### 3.2 Création de la topologie

Une étape essentielle consiste à créer la topologie du réseau avec la fonction :
```sql
SELECT pgr_createTopology('schema.table', tolerance, 'geom', 'id');
```
Cette fonction :

découpe les lignes aux intersections
crée des nœuds
attribue deux colonnes :

source : nœud de départ
target : nœud d’arrivée

Le réseau devient alors un graphe exploitable.

### 3.3 Définition du coût
Chaque tronçon doit posséder un coût, qui représente l’effort nécessaire pour le parcourir.
Exemples de coûts :

distance :
```sql
cost = ST_Length(geom)
```
temps de parcours (distance / vitesse)
coût personnalisé (trafic, type de route, etc.)

Il est possible d’ajouter un second coût :

reverse_cost : coût dans le sens inverse
→ permet de gérer les sens uniques
### 3.4 Calcul de chemin
Une fois la topologie créée, des algorithmes de graphes sont appliqués.
Exemple avec Dijkstra :
```sql
SELECT * FROM pgr_dijkstra(
    'SELECT id, source, target, cost FROM schema.table',
    start_node,
    end_node
);
```
La fonction renvoie la liste des arcs à parcourir.

## 4. Exigences de la table attributaire
Pour être utilisée avec pgRouting, une table doit respecter une structure précise.
### 4.1 Colonnes obligatoires
La table doit contenir les colonnes suivantes :

- id (entier)
- Identifiant unique de chaque tronçon
- source (entier)
- Identifiant du nœud de départ
- target (entier)
- Identifiant du nœud d’arrivée
- cost (numérique)
- Coût de déplacement sur le tronçon
- geom (géométrie LINESTRING)
- Géométrie du tronçon
### 4.2Colonnes optionnelles
Certaines colonnes sont facultatives mais souvent nécessaires :

- reverse_cost
- Coût dans le sens inverse
attributs métiers :

- type de route
- nombre de voies
- sens de circulation
- vitesse

Ces attributs peuvent être utilisés pour affiner les calculs.

### 4.3 Contraintes géométriques
La géométrie doit respecter certaines conditions :

type LINESTRING ou MULTILINESTRING
réseau connecté (pas de segments isolés)
intersections correctement définies
projection adaptée (souvent métrique, ex : EPSG:2154)

### 4.4 Qualité des données
Pour obtenir des résultats fiables, il est nécessaire de :

éviter les géométries invalides
corriger les discontinuités
vérifier la cohérence du réseau
éviter les doublons ou chevauchements incohérents

## 5. Principales fonctions
Les fonctions les plus utilisées sont :

pgr_dijkstra : plus court chemin
pgr_astar : optimisation du calcul
pgr_drivingDistance : zone accessible
pgr_ksp : plusieurs chemins possibles

## 6. Domaines d'application
pgRouting est utilisé dans plusieurs domaines :

transport et mobilité
urbanisme
réseaux techniques (eau, électricité)
analyse territoriale
systèmes d’aide à la décision

## 7. Conclusion
pgRouting est un outil puissant pour l’analyse de réseaux dans un environnement PostgreSQL/PostGIS.
Son fonctionnement repose sur la transformation d’un réseau géographique en graphe, nécessitant une structuration précise des données attributaires.
La qualité des résultats dépend directement de la qualité de la topologie et des coûts définis.
