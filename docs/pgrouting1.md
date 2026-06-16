# Construction d'un graphe de routage avec pgRouting
---

Ce document décrit, étape par étape, la construction d'un réseau routable à partir de la couche `troncon_de_route` de la BD TOPO (schéma `bdtopo64`), restreinte à une zone d'étude (`public.zone`), puis l'exécution d'un calcul d'itinéraire avec **pgRouting**.

Toutes les tables de travail sont créées dans le schéma `pgrouting`.

---

## 1. Nettoyage préalable du schéma

```sql
DROP TABLE if exists pgrouting.vertices ;
DROP TABLE if exists pgrouting.voies ;
```

Avant de relancer le script, on supprime les tables `vertices` (les nœuds du réseau) et `voies` (les tronçons) si elles existent déjà. Cela permet de relancer l'ensemble du traitement à l'identique sans erreur de type « la table existe déjà », notamment pendant les phases de test et d'ajustement du modèle.

---

## 2. Extraction des voies de la zone d'étude

```sql
SELECT r.fid as id, st_force2d(r.geom) as geom, nature, nombre_de_voies, largeur_de_chaussee,
sens_de_circulation, vitesse_moyenne_vl into pgrouting.voies
FROM bdtopo64.troncon_de_route r
  JOIN public.zone ON st_intersects(r.geom, zone.geom);

ALTER TABLE pgrouting.voies
  ADD constraint pkvoies PRIMARY KEY (id);
```

Cette requête crée la table `pgrouting.voies` à partir de la table source `bdtopo64.troncon_de_route`, en ne conservant que les tronçons qui intersectent la zone d'étude (jointure spatiale avec `st_intersects`).

Quelques points importants :

- `r.fid` devient `id` : c'est l'identifiant unique de chaque tronçon, qui servira de clé primaire et de référence pour les calculs pgRouting.
- `st_force2d(r.geom)` force la géométrie en 2D (en supprimant la composante Z si elle existe). C'est nécessaire car pgRouting fonctionne sur des géométries 2D ; une géométrie 3D résiduelle peut casser les comparaisons géométriques utilisées plus loin (étape 6).
- Les attributs conservés (`nature`, `nombre_de_voies`, `largeur_de_chaussee`, `sens_de_circulation`, `vitesse_moyenne_vl`) ne sont pas utilisés directement par pgRouting, mais restent disponibles pour qualifier le réseau (filtrage par type de voie, pondération par vitesse, etc.).

Une fois la table créée, une contrainte de clé primaire est ajoutée sur `id`, ce qui est requis par les fonctions de topologie de pgRouting (l'identifiant des arêtes doit être unique).

---

## 3. Correction du sens de tracé des géométries

```sql
UPDATE pgrouting.voies
SET geom = ST_Reverse(geom)
WHERE sens_de_circulation = 'Sens inverse';

UPDATE pgrouting.voies
SET sens_de_circulation = 'Sens direct'
WHERE sens_de_circulation = 'Sens inverse';
```

Dans la BD TOPO, l'attribut `sens_de_circulation` indique si le sens de circulation autorisé correspond au sens de numérisation de la géométrie (« Sens direct ») ou lui est opposé (« Sens inverse »). pgRouting, lui, se base uniquement sur l'orientation géométrique de la ligne (point de départ → point d'arrivée) pour déterminer la direction de circulation.

Il faut donc harmoniser les deux informations :

1. La première instruction inverse la géométrie (`ST_Reverse`) de tous les tronçons marqués « Sens inverse », afin que le sens de numérisation corresponde désormais au sens de circulation réel.
2. La seconde instruction met à jour l'attribut en conséquence : puisque la géométrie a été inversée, ces tronçons sont maintenant en « Sens direct ».

À la fin de ce bloc, l'attribut `sens_de_circulation` ne contient plus que deux valeurs possibles : `Sens direct` et `Double sens`, et l'orientation de chaque géométrie reflète fidèlement le sens de circulation autorisé.

---

## 4. Création des nœuds du réseau (vertices)

```sql
SELECT distinct * INTO pgrouting.vertices
FROM pgr_extractVertices('SELECT id, geom
                            FROM pgrouting.voies
                        ORDER BY id')
                        order by 1;
```

La fonction `pgr_extractVertices` parcourt l'ensemble des géométries de `pgrouting.voies` et en extrait tous les nœuds : c'est-à-dire les points de départ et d'arrivée de chaque tronçon. Chaque nœud distinct se voit attribuer un identifiant unique (`id`), ses coordonnées (`x`, `y`), ainsi que le nombre de tronçons entrants/sortants qui lui sont rattachés.

Le résultat est stocké dans la table `pgrouting.vertices`, qui constitue la table des sommets du graphe. C'est cette table qui sera utilisée à l'étape suivante pour relier chaque tronçon à ses nœuds source et destination.

---

## 5. Ajout des colonnes nécessaires aux calculs de routage

```sql
ALTER TABLE pgrouting.voies
  ADD COLUMN source integer,
  ADD COLUMN target integer,
  ADD COLUMN x real,
  ADD COLUMN y real,
  ADD COLUMN cost real,
  ADD COLUMN direction text
  ;
```

Cette instruction ajoute à la table `pgrouting.voies` les colonnes attendues par les algorithmes de pgRouting (comme `pgr_dijkstra`) :

- `source` et `target` : identifiants (issus de `pgrouting.vertices`) du nœud de départ et du nœud d'arrivée de chaque tronçon. C'est la topologie du graphe proprement dite.
- `x` et `y` : coordonnées d'un des nœuds du tronçon, utiles pour du contrôle visuel ou du débogage.
- `cost` : le coût (l'impédance) associé au parcours du tronçon, utilisé par les algorithmes de plus court chemin pour comparer les itinéraires.
- `direction` : indicateur du sens de parcours autorisé sur le tronçon (voir étape 8).

---

## 6. Renseignement des identifiants source et target

```sql
/* -- set the source information */
UPDATE pgrouting.voies AS e
SET source = v.id, x = v.x, y = v.y
FROM pgrouting.vertices AS v
WHERE ST_StartPoint(e.geom) = v.geom;

/* -- set the target information */
UPDATE pgrouting.voies AS e
SET target = v.id, x = v.x, y = v.y
FROM pgrouting.vertices AS v
WHERE ST_EndPoint(e.geom) = v.geom;
```

Ces deux mises à jour construisent la topologie du graphe en reliant chaque tronçon (`e`) à ses nœuds (`v`) :

- la première instruction recherche, pour chaque tronçon, le nœud dont la géométrie correspond exactement au point de départ de la ligne (`ST_StartPoint`), et renseigne `source` avec l'identifiant de ce nœud ;
- la seconde fait de même avec le point d'arrivée (`ST_EndPoint`) pour renseigner `target`.

La comparaison `ST_StartPoint(e.geom) = v.geom` fonctionne ici parce que les nœuds de `pgrouting.vertices` ont été extraits directement à partir des extrémités des géométries de `pgrouting.voies` (étape 4) : les coordonnées sont donc strictement identiques. C'est cette correspondance exacte qui permet de bâtir automatiquement la topologie sans avoir besoin d'une fonction de snapping ou de tolérance.

À noter : si un tronçon se retrouve avec un `target` (ou `source`) resté `NULL` après cette étape, cela signifie généralement un problème de géométrie (doublon de nœud à coordonnées légèrement différentes, géométrie invalide, etc.).

---

## 7. Calcul du coût de chaque tronçon

```sql
UPDATE pgrouting.voies
  set cost=st_length(geom);
```

Le coût de chaque tronçon est ici défini comme sa longueur géométrique (`ST_Length`), exprimée dans l'unité du système de coordonnées de la couche (mètres si la projection est métrique). C'est ce coût qui sera additionné le long du trajet par `pgr_dijkstra` pour déterminer le chemin le plus court.

À titre indicatif, on pourrait affiner ce coût pour obtenir un temps de parcours plutôt qu'une distance, par exemple en divisant la longueur par `vitesse_moyenne_vl` (attribut déjà présent dans la table mais non utilisé dans ce script).

---

## 8. Définition du sens de circulation logique

```sql
UPDATE pgrouting.voies
SET direction = CASE WHEN sens_de_circulation='Double sens'
                    THEN 'B'   /* both ways */
                 WHEN sens_de_circulation='Sens direct'
                    THEN 'FT'  /* direction of the LINESSTRING */
                ELSE '' END;
```

Cette instruction traduit l'attribut métier `sens_de_circulation` en un code standardisé compris par certaines fonctions de pgRouting :

- `B` (*both ways*) : circulation possible dans les deux sens ;
- `FT` (*From-To*) : circulation autorisée uniquement dans le sens de la géométrie (du point de départ vers le point d'arrivée), tel qu'il a été corrigé à l'étape 3.

Cette colonne `direction` est calculée et disponible, mais elle n'est pas exploitée par l'appel à `pgr_dijkstra` réalisé plus loin, puisque celui-ci est lancé en mode non orienté (`directed = false`). Pour que le sens unique soit réellement pris en compte dans le calcul d'itinéraire, il faudrait soit appeler `pgr_dijkstra` avec `directed = true` (en s'assurant que les colonnes `source`/`target` reflètent correctement le sens autorisé), soit filtrer/dupliquer les arêtes en fonction de cette colonne `direction`.

---

## 9. Calcul d'un itinéraire avec pgr_dijkstra

```sql
SELECT *
FROM pgr_dijkstra('SELECT  id, source, target, cost
       FROM pgrouting.voies
       WHERE target is not null', 24, 28, false);
```

Cette requête calcule le plus court chemin entre le nœud `24` (origine) et le nœud `28` (destination) avec l'algorithme de Dijkstra.

Le premier paramètre de `pgr_dijkstra` est une requête SQL qui définit le graphe : pour chaque arête, son identifiant (`id`), son nœud de départ (`source`), son nœud d'arrivée (`target`) et son coût (`cost`). La clause `WHERE target is not null` permet d'exclure les tronçons pour lesquels la topologie n'a pas pu être construite correctement à l'étape 6 (ce qui éviterait des erreurs ou des résultats faussés).

Les trois derniers paramètres sont :

- `24` : l'identifiant du nœud de départ ;
- `28` : l'identifiant du nœud d'arrivée ;
- `false` : indique que le graphe est traité comme **non orienté** (les arêtes peuvent être parcourues dans les deux sens, quelle que soit la colonne `direction`).

Le résultat est une table listant la séquence des arêtes (`edge`) et des nœuds (`node`) traversés, avec le coût de chaque segment (`cost`) et le coût cumulé depuis le départ (`agg_cost`).

---

## 10. Visualisation du trajet calculé

```sql
SELECT *
 FROM pgrouting.voies
   WHERE id in (SELECT edge
FROM pgr_dijkstra('SELECT  id, source, target, cost
       FROM pgrouting.voies
       WHERE target is not null', 24, 43, false));
```

Pour visualiser le trajet (par exemple dans QGIS), il ne suffit pas de récupérer la liste des arêtes parcourues : il faut aussi récupérer leur géométrie. Cette requête combine donc les deux étapes :

1. la sous-requête appelle à nouveau `pgr_dijkstra` (ici entre les nœuds `24` et `43`, à titre d'exemple) et n'en extrait que la colonne `edge`, c'est-à-dire la liste des identifiants de tronçons traversés ;
2. la requête principale sélectionne, dans `pgrouting.voies`, toutes les lignes dont l'`id` figure dans cette liste, ce qui retourne l'ensemble des attributs **et** la géométrie de chaque tronçon composant l'itinéraire.

Le résultat peut directement être chargé comme couche dans un SIG pour être affiché sur une carte.

---

## Pour aller plus loin

Ce script constitue une base de travail fonctionnelle. Quelques pistes d'amélioration possibles selon les besoins du projet :

- Exploiter réellement la colonne `direction` (sens unique) en passant `directed = true` dans `pgr_dijkstra`, afin de respecter les sens de circulation interdits.
- Remplacer le coût « distance » par un coût « temps de parcours » en combinant `st_length(geom)` et `vitesse_moyenne_vl`.
- Vérifier qu'aucun tronçon ne possède de `source` ou `target` resté `NULL` (signe d'un problème de topologie à corriger avant tout calcul d'itinéraire).
- Pour des réseaux plus complexes (giratoires, interdictions de tourner), envisager `pgr_trsp` qui gère les restrictions de virage.
## Tests
Calcul de trajet
```sql
SELECT *
FROM pgrouting.voies
WHERE id IN (
    SELECT edge
    FROM pgr_dijkstra(
        'SELECT id, source, target, cost 
         FROM pgrouting.voies
         WHERE source IS NOT NULL AND target IS NOT NULL',
        24,
        43,
        false
    )
);
```







