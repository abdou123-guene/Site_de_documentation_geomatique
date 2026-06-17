# Construction d'un graphe de routage avec pgRouting
---

Ce document décrit, étape par étape, la construction d'un réseau routable à partir de la couche `troncon_de_route` de la BD TOPO (schéma `bdtopo64`), restreinte à une zone d'étude (`public.zone`), puis l'exécution d'un calcul d'itinéraire avec **pgRouting**.

Toutes les tables de travail sont créées dans le schéma `pgrouting`.

## 1. Nettoyage préalable du schéma

```sql
DROP TABLE if exists pgrouting.vertices ;
DROP TABLE if exists pgrouting.voies ;
```

Avant de relancer le script, on supprime les tables `vertices` (les nœuds du réseau) et `voies` (les tronçons) si elles existent déjà. Cela permet de relancer l'ensemble du traitement à l'identique sans erreur de type « la table existe déjà », notamment pendant les phases de test et d'ajustement du modèle.

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

## 7. Calcul du coût de chaque tronçon

```sql
UPDATE pgrouting.voies
  set cost=st_length(geom);
```

Le coût de chaque tronçon est ici défini comme sa longueur géométrique (`ST_Length`), exprimée dans l'unité du système de coordonnées de la couche (mètres si la projection est métrique). C'est ce coût qui sera additionné le long du trajet par `pgr_dijkstra` pour déterminer le chemin le plus court.

À titre indicatif, on pourrait affiner ce coût pour obtenir un temps de parcours plutôt qu'une distance, par exemple en divisant la longueur par `vitesse_moyenne_vl` (attribut déjà présent dans la table mais non utilisé dans ce script).

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

## 11. Pour aller plus loin

Ce script constitue une base de travail fonctionnelle. Quelques pistes d'amélioration possibles selon les besoins du projet :

- Exploiter réellement la colonne `direction` (sens unique) en passant `directed = true` dans `pgr_dijkstra`, afin de respecter les sens de circulation interdits.
- Remplacer le coût « distance » par un coût « temps de parcours » en combinant `st_length(geom)` et `vitesse_moyenne_vl`.
- Vérifier qu'aucun tronçon ne possède de `source` ou `target` resté `NULL` (signe d'un problème de topologie à corriger avant tout calcul d'itinéraire).
- Pour des réseaux plus complexes (giratoires, interdictions de tourner), envisager `pgr_trsp` qui gère les restrictions de virage.

## 12. Tests

Une fois le calcul d'itinéraire mis en place, il est utile de vérifier le résultat sous plusieurs angles : la liste des tronçons réellement parcourus, la longueur totale du trajet, et une estimation de la dénivelée le long du parcours.

### 12.1 Calcul de trajet

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

Cette requête reprend le principe de visualisation déjà utilisé précédemment (récupérer, dans `pgrouting.voies`, les tronçons dont l'`id` correspond aux arêtes renvoyées par `pgr_dijkstra`), avec une condition légèrement renforcée : `WHERE source IS NOT NULL AND target IS NOT NULL` exclut du graphe tout tronçon dont la topologie est incomplète, que ce soit côté source ou côté target, et pas uniquement côté target. C'est une sécurité supplémentaire pour garantir que seuls des tronçons correctement connectés au réseau sont pris en compte dans le calcul.

### 12.2 Longueur totale du trajet

```sql
SELECT
    v.id,
    v.geom,
    ST_Value(m.rast, ST_StartPoint(v.geom)) AS z_start,
    ST_Value(m.rast, ST_EndPoint(v.geom)) AS z_end,
    ST_Length(v.geom) AS longueur
FROM pgrouting.voies v,
     mnt_raster.mnt_zone m
WHERE ST_Intersects(v.geom, m.rast);
```

Cette requête permet de quantifier l'itinéraire calculé : elle récupère la liste des arêtes parcourues via `pgr_dijkstra`, les relie à la table `pgrouting.voies` (jointure sur `d.edge = v.id`), puis additionne la colonne `cost` de chaque tronçon. Le coût ayant été défini comme la longueur géométrique de chaque tronçon, le résultat `longueur_totale` correspond à la distance totale du trajet, exprimée dans l'unité du système de coordonnées de la couche (en mètres si la projection est métrique).

### 12.3 Calcul de la pente

La couche `voies` ne comportant pas d'attribut de pente, on l'estime en croisant le trajet avec la couche raster `mnt_lidar` du schéma `mnt_raster`, qui fournit l'altitude du terrain en tout point du réseau routier.

```sql
SELECT
    v.id,
    v.geom,
    ST_Value(m.rast, ST_StartPoint(v.geom)) AS z_start,
    ST_Value(m.rast, ST_EndPoint(v.geom)) AS z_end,
    ST_Length(v.geom) AS longueur,
    --calcul de la pente
    (
        ST_Value(m.rast, ST_EndPoint(v.geom)) -
        ST_Value(m.rast, ST_StartPoint(v.geom))
    ) / ST_Length(v.geom) AS pente
FROM pgrouting.voies v
JOIN mnt_raster.mnt_zone m
ON ST_Intersects(v.geom, m.rast);
```

Pour chaque tronçon, `ST_Value` interroge le raster `mnt_lidar` aux points de départ (`ST_StartPoint`) et d'arrivée (`ST_EndPoint`) de la géométrie afin d'en extraire l'altitude (`z_start` et `z_end`). La longueur du tronçon (`ST_Length`) est également récupérée. Ces trois valeurs constituent les éléments nécessaires au calcul de la pente, qui peut ensuite être obtenue avec la formule `(z_end - z_start) / longueur * 100` (en %).

À noter : la clause `WHERE ST_Intersects(v.geom, m.rast)` agit ici comme condition de jointure entre les tronçons et les dalles du raster. Si le MNT est découpé en plusieurs dalles, un même tronçon traversant plusieurs dalles peut apparaître en double dans le résultat ; il peut être utile de filtrer ou d'agréger les résultats en conséquence selon le découpage du raster utilisé.

### 12.4 Calcul de pente pour chaque tronçon du trajet d’un point A à un pointB

```sql
CREATE materialized VIEW pgrouting.vm_trajets AS
WITH trajet0 AS (
    SELECT *
    FROM pgrouting.voies
    WHERE id IN (
        SELECT edge
        FROM pgr_dijkstra(
            'SELECT id, source, target, cost 
             FROM pgrouting.voies
             WHERE source IS NOT NULL AND target IS NOT NULL',
            120,
            244,
            false
        )
    )
),
trajet_point AS (
    SELECT 
        t.id,
        ST_Length(t.geom) AS longueur,
        (ST_DumpPoints(t.geom)).geom AS geom
    FROM trajet0 t
),
mnt AS (
    SELECT ST_Union(rast) AS rast1
    FROM mnt_raster.mnt_zone r
    JOIN trajet_point tp 
    ON tp.geom && r.rast
)
SELECT  
    t.id,
    t.geom,
    SUM(t.cost) AS longueur,
    (
        MAX(ST_Value(m.rast1, tp.geom)) - 
        MIN(ST_Value(m.rast1, tp.geom))
    ) / SUM(tp.longueur) * 100 AS pente
FROM trajet0 t
JOIN trajet_point tp ON tp.id = t.id
CROSS JOIN mnt m
GROUP BY t.id, t.geom;
```

### 12.5 Amélioration de la requête : à partir de coordonnées carto
point de départ :

- ***D'abord on a besoin de pgrouting.vm_troncons_pente***

```sql
CREATE MATERIALIZED VIEW pgrouting.vm_troncons_pente AS

SELECT
    v.id,
    v.geom,
    ST_Length(v.geom) AS longueur,

    (
        ST_Value(m.rast, ST_EndPoint(v.geom)) -
        ST_Value(m.rast, ST_StartPoint(v.geom))
    ) / ST_Length(v.geom) * 100 AS pente

FROM pgrouting.voies v
JOIN mnt_raster.mnt_lidar m
ON ST_Intersects(v.geom, m.rast)
WHERE v.source IS NOT NULL AND v.target IS NOT NULL;
```
- ***Ensuite:***

***NB:*** Ces coordonnées X,Y peuvent ne pas se trouver dans notre zone, donc trouver de bonnes coordonnées X,Y.

```sql
-- Coordonnées (EPSG:2154)
-- départ : 408042.24, 6207677.44 
-- arrivée : 409420.85, 6208085.38
WITH 
-- point de départ (vertex le plus proche)
depart AS (
    SELECT id
    FROM pgrouting.vertices
    ORDER BY geom <-> ST_SetSRID(ST_Point(408042.24, 6207677.44), 2154)
    LIMIT 1
),
-- point d'arrivée (vertex le plus proche)
arrivee AS (
    SELECT id
    FROM pgrouting.vertices
    ORDER BY geom <-> ST_SetSRID(ST_Point(409420.85, 6208085.38), 2154)
    LIMIT 1
)
-- calcul et récupération du chemin
SELECT 
    v.id,
    ST_Transform(v.geom, 4326) AS geom,
    v.longueur,
    v.pente
FROM pgrouting.vm_troncons_pente v
WHERE v.id IN (
    SELECT d.edge
    FROM depart, arrivee,
    pgr_dijkstra(
        $$SELECT id, source, target, cost 
          FROM pgrouting.voies
          WHERE source IS NOT NULL AND target IS NOT NULL$$,
        depart.id,
        arrivee.id,
        false
    ) AS d
);
```

- ***Enfin: Etape suivante : faire une fonction qui permet de trouver une chemin en entrant les coordonnées du point de départ, les coordonnées du point d’arrivée et false/true (pour voiture ou piéton)***

là on arrive à une vraie étape projet / examen

👉 créer une fonction pgRouting complète et réutilisable

***Objectif***

Créer une fonction qui :

👉 prend en entrée :

✅ coordonnées départ (X,Y)

✅ coordonnées arrivée (X,Y)

✅ mode (true = voiture / false = piéton)

👉 et renvoie :

➡️ le chemin (géométrie + éventuellement pente, longueur)

```sql
CREATE OR REPLACE FUNCTION pgrouting.f_trajet(
    x_dep DOUBLE PRECISION,
    y_dep DOUBLE PRECISION,
    x_arr DOUBLE PRECISION,
    y_arr DOUBLE PRECISION,
    mode_voiture BOOLEAN
)
RETURNS TABLE (
    id BIGINT,
    geom GEOMETRY,
    longueur DOUBLE PRECISION,
    pente DOUBLE PRECISION
)
AS $func$
BEGIN

RETURN QUERY

WITH 

depart AS (
    SELECT vtx.id AS id_dep
    FROM pgrouting.vertices vtx
    ORDER BY vtx.geom <-> ST_SetSRID(ST_Point(x_dep, y_dep), 2154)
    LIMIT 1
),

arrivee AS (
    SELECT vtx.id AS id_arr
    FROM pgrouting.vertices vtx
    ORDER BY vtx.geom <-> ST_SetSRID(ST_Point(x_arr, y_arr), 2154)
    LIMIT 1
),

trajet AS (
    SELECT *
    FROM pgr_dijkstra(
        'SELECT v.id, v.source, v.target, v.cost 
         FROM pgrouting.voies v
         WHERE v.source IS NOT NULL 
           AND v.target IS NOT NULL
           AND (
               ' || mode_voiture || ' = TRUE 
               OR v.nature NOT IN (''autoroute'', ''voie rapide'')
           )',
        (SELECT id_dep FROM depart),
        (SELECT id_arr FROM arrivee),
        false
    )
)

SELECT 
    v.id,
    v.geom,
    v.cost::DOUBLE PRECISION AS longueur,

    (
        ST_Value(m.rast, ST_EndPoint(v.geom)) -
        ST_Value(m.rast, ST_StartPoint(v.geom))
    ) / NULLIF(ST_Length(v.geom), 0) * 100 AS pente

FROM trajet t
JOIN pgrouting.voies v ON t.edge = v.id
LEFT JOIN mnt_raster.mnt_lidar m 
ON ST_Intersects(v.geom, m.rast);

END;
$func$ LANGUAGE plpgsql;
```

***Tester la fonction***

***Attention :*** 

- les points X et Y utilisés pour les tests doivent se situer dans la zone d’étude,
- 
- sinon la requête retournera 0 ligne.

- ***TEST 1 – CAS DE BASE (VOITURE)***

```sql
SELECT *
FROM pgrouting.f_trajet(
    408042.24, 6207677.44,
    409420.85, 6208085.38,
    true
);
```

- ***TEST 2 - MODE PIÉTON***

```sql
SELECT *
FROM pgrouting.f_trajet(
    408042.24, 6207677.44,
    409420.85, 6208085.38,
    false
);
```

- ***TEST 3 - TRAJET COURT (VOISIN)***

```sql
SELECT *
FROM pgrouting.f_trajet(
    408000, 6207600,
    408100, 6207650,
    true
);
```

- ***TEST 4 - TRAJET LONG***

```sql
SELECT *
FROM pgrouting.f_trajet(
    408000, 6207000,
    410000, 6209000,
    true
);
```

- ***TEST 5 - VÉRIFIER LA LIGNE CONTINUE***

```sql
SELECT ST_Union(geom)
FROM pgrouting.f_trajet(
    408042.24, 6207677.44,
    409420.85, 6208085.38,
    true
);
```

- ***TEST 6 - LONGUEUR TOTALE***

```sql
SELECT SUM(longueur) AS distance_totale
FROM pgrouting.f_trajet(
    408042.24, 6207677.44,
    409420.85, 6208085.38,
    true
);
```
- ***TEST 7 – PENTE MOYENNE***

```sql
SELECT AVG(pente) AS pente_moyenne
FROM pgrouting.f_trajet(
    408042.24, 6207677.44,
    409420.85, 6208085.38,
    true
);
```

- ***TEST 8 – CAS LIMITE (POINTS IDENTIQUES)***

```sql
SELECT *
FROM pgrouting.f_trajet(
    408042.24, 6207677.44,
    408042.24, 6207677.44,
    true
);
```

- ***TEST 9 – POINT HORS ZONE***

```sql
SELECT *
FROM pgrouting.f_trajet(
    100000, 1000000,
    200000, 2000000,
    true
);
```

- ***TEST 10 – COMPARAISON VOITURE / PIÉTON***

```sql
-- voiture
SELECT ST_Union(geom)
FROM pgrouting.f_trajet(..., true);
-- piéton
SELECT ST_Union(geom)
FROM pgrouting.f_trajet(..., false);
```

- ***Fonction bis créer par le prof***

***Différence entre les deux fonctions***

- **1. Ta fonction `f_trajet`***

Fonctionne avec :

- coordonnées X, Y directement

Avantages :

- ✅ plus flexible
- 
- ✅ plus "application réelle"
- 
- ✅ style Google Maps

***2. Fonction du prof `f_trajet_bis`***

Fonctionne avec :

- table `pgrouting.depart_arrivee`
- 
- colonnes : `nom`, `geom`, `d` (point départ), `a` (point arrivée)

Avantages :

- ✅ plus simple
- 
- ✅ pédagogique
- 
- ✅ utilisé pour démonstration

## Comparaison claire

| Fonction | Entrée | Avantage |
|---|---|---|
| `f_trajet` | coordonnées | ✅ dynamique |
| `f_trajet_bis` | table | ✅ simple |

```sql
DROP FUNCTION IF EXISTS pgrouting.f_trajet_bis();

CREATE OR REPLACE FUNCTION pgrouting.f_trajet_bis()
RETURNS TABLE (
    id BIGINT,
    geom GEOMETRY,
    longueur DOUBLE PRECISION,
    pente DOUBLE PRECISION
)
AS $func$
BEGIN

RETURN QUERY

WITH 

-- vertex de départ
depart AS (
    SELECT v.id AS id_dep
    FROM pgrouting.vertices v, pgrouting.depart_arrivee da
    WHERE da.nom = 'd'
    ORDER BY v.geom <-> da.geom
    LIMIT 1
),

-- vertex d’arrivée
arrivee AS (
    SELECT v.id AS id_arr
    FROM pgrouting.vertices v, pgrouting.depart_arrivee da
    WHERE da.nom = 'a'
    ORDER BY v.geom <-> da.geom
    LIMIT 1
)

-- résultat final (reprend ton exemple prof)
SELECT 
    voies.id,
    ST_Transform(voies.geom, 4326) AS geom,
    voies.longueur::DOUBLE PRECISION,
    voies.pente::DOUBLE PRECISION
FROM pgrouting.vm_troncons_pente voies,
     depart,
     arrivee
WHERE voies.id IN (
    SELECT d.edge
    FROM pgr_dijkstra(
        'SELECT id, source, target, cost 
         FROM pgrouting.voies
         WHERE source IS NOT NULL AND target IS NOT NULL',
        (SELECT id_dep FROM depart),
        (SELECT id_arr FROM arrivee),
        false
    ) AS d
);

END;
$func$ LANGUAGE plpgsql;
```


