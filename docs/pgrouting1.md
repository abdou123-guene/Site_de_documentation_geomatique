# Etapes de préparation pour le fonctionnement de pgrouting
---

## Récupération des données (bdtopo)

```sql
CREATE SCHEMA pgrouting;
SELECT r.fid, r.geom, nature,nombre_de_voies, largeur_de_chaussee,
sens_de_circulation,vitesse_moyenne_vl into pgrouting.voies
FROM bdtopo64.troncon_de_route r
  JOIN public.zone ON st_intersects(r.geom,zone.geom);
  ALTER TABLE pgrouting.voies
  ADD constraint pkvoies PRIMARY KEY (fid);
```

## Vérification de la topologie : détection des segments qui se croisent sans noeuds et création des tronçons :

```sql
SELECT id, sub_id, st_transform(st_force2d(geom),4326)
FROM pgr_separateCrossing('SELECT fid as id,geom from pgrouting.voies');
```

## Vérifier et corriger le sens des tronçons qui ne correspondent pas au sens de circulation

```sql
UPDATE pgrouting.voies 
set geom=ST_Reverse(geom)
 WHERE sens_de_circulation ='Sens inverse';
 ```
 
https://docs.pgrouting.org/latest/en/pgRouting-concepts.html#wiki-example 

## Création des vertices :

```sql
SELECT * INTO pgrouting.vertices
FROM pgr_extractVertices('SELECT fid as id, geom 
							FROM pgrouting.voies
						ORDER BY id');
```

## Ajout des champs source, target et x,y dans voies :

```sql
ALTER TABLE  pgrouting.voies
  ADD COLUMN source integer,
  ADD COLUMN target integer,
  ADD COLUMN x real,
  ADD COLUMN y real;
```

## Renseigner les colonnes créées précedement :
```sql
/* -- set the source information */
UPDATE pgrouting.voies AS e
SET source = v.id, x = v.x, y = v.y
FROM pgrouting.vertices AS v
WHERE ST_StartPoint(e.geom) = v.geom;
```

/* -- set the target information */

```sql
UPDATE pgrouting.voies AS e
SET target = v.id, x = v.x, y = v.y
FROM pgrouting.vertices AS v
WHERE ST_EndPoint(e.geom) = v.geom;
```
## Ajout du coût pour chaque tronçon :
```sql
ALTER TABLE pgrouting.voies
  ADD COLUMN cost real;
```

```sql
UPDATE pgrouting.voies
  set cost=st_length(geom);
```
## Ajout de la direction :
```sql
ALTER TABLE pgrouting.voies ADD COLUMN direction TEXT;
```

```sql
UPDATE pgrouting.voies SET
direction = CASE WHEN sens_de_circulation='Double sens' THEN 'B'   /* both ways */
           		 WHEN sens_de_circulation='Sens direct' THEN 'FT'  /* direction of the LINESSTRING */
            ELSE '' END;
```

## Petit souci !!! Création de table voies bien nettoye

```sql
CREATE TABLE pgrouting.voies_clean AS
SELECT *
FROM pgrouting.voies
WHERE source IS NOT NULL 
  AND target IS NOT NULL;
```

### POURQUOI ON A CRÉÉ voies_clean 

source = NULL
target = NULL
(tu avais même trouvé : 121 lignes ❌)

### CONSÉQUENCE

- pgRouting ne supporte pas ça :
- NULL dans source/target → erreur Dijkstra
- Résultat :

❌ erreur SQL
❌ ou 0 résultat
❌ graphe cassé

### OBJECTIF DE LA REQUÊTE

👉 Créer une table propre et utilisable immédiatement
➡️ en filtrant :
uniquement les lignes valides

### TESTS

```sql
SELECT * FROM pgr_dijkstra(
    'SELECT fid AS id, source, target, cost FROM pgrouting.voies_clean',
    419,
    431
);
```

```sql
SELECT v.geom
FROM pgr_dijkstra(
    'SELECT fid AS id, source, target, cost FROM pgrouting.voies_clean',
    419,
    431
) AS d
JOIN pgrouting.voies_clean v
ON d.edge = v.fid;
```




