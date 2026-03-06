
# Queslques scripts SQL fréquents en géomatique


## 1. Création d’index
### Objectif
Créer un index partiel sur la colonne numpar pour accélérer les requêtes ciblant la parcelle c10436.
### Explication
Les index B‑Tree accélèrent les comparaisons textuelles.
L’usage de WHERE dans l’index le rend partiel, donc plus petit et plus rapide.
Spécialement utile pour les requêtes utilisant ILIKE.
### Code SQL
```sql
CREATE INDEX idx_parcel_numpar_c10436ON village.parcel (numpar)WHERE numpar ILIKE 'c10436';``Afficher plus de lignes
```

## 2. Création d’une vue matérialisée simplifiée
### Objectif
Créer une vue matérialisée de la couche des cours d’eau avec une géométrie simplifiée pour :
améliorer les performances,
accélérer l'affichage dans QGIS.
### Explication
st_simplify(geom, 20) réduit la complexité géométrique (tolérance = 20 m).
Les vues matérialisées stockent physiquement les résultats.
On ajoute un index spatial pour accélérer les requêtes ultérieures.
### Code SQL
```sql
CREATE MATERIALIZED VIEW carthage.cours_eau_simplifiee AS
SELECT gid, cdentitehy, nomentiteh, candidat, classe,
       ST_Simplify(geom, 20) AS geom
FROM carthage.cours;

CREATE INDEX geom_cours_eau_simplifiee
ON carthage.cours
USING GIST(geom);
```

## 3. Connaître le SRID d’une couche
### Objectif
Identifier le système de référence spatiale d’une couche.
### Explication
Find_SRID retourne le SRID déclaré dans la métadonnée PostGIS.
```sql
SELECT Find_SRID('carthage', 'cours', 'geom');
```

## 4. Longueur du réseau d'eau usée
### Objectif
Calculer la longueur totale du réseau d'assainissement.
### Explication
ST_Length(geom) calcule la longueur dans l’unité du SRID (souvent mètres).
SUM() additionne la longueur de toutes les lignes.
```sql
SELECT SUM(ST_Length(geom)) AS longueur
FROM village.o_usees;
```

## 5. Périmètre des zones PLU ND
### Objectif
Calculer le périmètre total des zones PLU ND (corrigé en hectares ou km).
```sql
SELECT SUM(ST_Perimeter(geom) / 10000) AS perimetre_haFROM village.pos;
SELECT SUM(ST_Perimeter(geom) / 10000) AS perimetre_ha
FROM village.pos;
```

## 6. Parcelles traversées par le réseau d’eau usée
### Objectif
Trouver les parcelles dont la géométrie intersecte la géométrie du réseau.
### Explication
ST_Intersects(a, b) retourne true si les géométries se coupent ou se touchent.
```sql
SELECT DISTINCT p.*
FROM village.parcel p
JOIN village.o_usees o
ON ST_Intersects(o.geom, p.geom);
```

## 7. Parcelles bâties
### Objectif
Sélectionner les parcelles contenant au moins un bâtiment.
### Explication
ST_Contains(p.geom, b.geom) vérifie si un bâtiment est entièrement dans une parcelle.
```sql
SELECT DISTINCT p.*FROM village.parcel pJOIN village.bati bON ST_Contains(p.geom, b.geom);Afficher plus de lignes
```

## 8. Départements traversés par la Garonne
### Objectif
Lister les départements qui intersectent La Garonne.
```sql
SELECT DISTINCT d.code_in
SELECT DISTINCT d.code_insee, d.nom, c.nomentiteh
FROM departement.departements d
JOIN carthage.cours c
ON ST_Intersects(c.geom, d.geom)
WHERE c.nomentiteh = 'La Garonne'
  AND c.classe = 1;
```

## 9. Parcelles voisines d'une parcelle donnée
### Objectif
Trouver les parcelles qui touchent la parcelle c10436.
### Explication
ST_Touches détecte les contacts par frontières (bordure), pas les intersections internes.
```sql
WITH req AS (
  SELECT *
  FROM village.parcel
  WHERE numpar ILIKE 'c10436'
)
SELECT DISTINCT p2.*
FROM village.parcel p2
JOIN req
ON ST_Touches(p2.geom, req.geom);
```

## 10. Comptage des zones d’occupation du sol autour des tourbières (412)
### Objectif
Trouver les zones de Corine Land Cover touchant les tourbières (code 412).
```sql
WITH req AS (
  SELECT c.*, ST_Area(geom)/1000000 AS surface_km2
  FROM corine.clc c
),
req1 AS (
  SELECT *
  FROM corine.clc
  WHERE code_18 LIKE '412'
)
SELECT COUNT(*) AS nombre_zone_ocsol,
       AVG(req.surface_km2) AS surface_moyenne_km2
FROM req
JOIN req1
ON ST_Touches(req.geom, req1.geom);
```

## 11. Distance des zones industrielles (121) à la Garonne
### Objectif
Calculer la distance entre les zones industrielles et La Garonne dans un rayon de 10 km.
```sql
WITH req AS (
  SELECT c.*, ST_Area(geom)/1000000 AS surface_km2
  FROM corine.clc c
  WHERE code_18 LIKE '121'
)
SELECT req.id,
       req.code_18,
       ST_Distance(req.geom, c.geom)/1000 AS distance_km,
       req.geom,
       req.surface_km2
FROM req
JOIN carthage.cours c
ON ST_DWithin(req.geom, c.geom, 10000)
WHERE c.nomentiteh = 'La Garonne'
  AND c.classe = 1
ORDER BY distance_km DESC;
```

## 12. Bâtiment le plus proche du réseau d’eau usée
### Version optimisée avec LATERAL
```sql
SELECT
    b.id,
    b."type",
    ST_Distance(b.geom, o.geom) AS distance_m,
    b.geom
FROM village.bati AS b
CROSS JOIN LATERAL (
    SELECT o.geom
    FROM village.o_usees AS o
    ORDER BY b.geom <-> o.geom
    LIMIT 1
) AS o
ORDER BY distance_m ASC;
```

## 13. Pourcentage de périmètre non-touché par d’autres départements
### Objectif
Pour chaque département, calculer :
son périmètre total
la longueur de frontière partagée avec d’autres départements
la longueur du périmètre sans contact avec un autre département
enfin, le pourcentage de périmètre non-touché
Ce type d’analyse permet par exemple de repérer :
les départements enclavés,
les départements côtiers,
ceux en limite internationale, etc.
### Explication claire (étape par étape)
### 1) On extrait la frontière du département
PostGIS extrait la géométrie linéaire représentant la frontière via :
ST_Boundary() : génère la frontière du polygone
ST_CollectionExtract(..., 2) : conserve uniquement les objets linéaires (type LineString)
Reprojection en 2154 pour des mesures fiables en mètres
### 2) On trouve la frontière partagée
On intersecte les frontières de chaque département avec tous les autres :
ST_Intersection() : extrait la section commune
ST_Union() : rassemble toutes les frontières partagées
ST_Length() : calcule la longueur totale de ces frontières
### 3) On calcule la frontière non-touchée
Formule :
périmètre_non_touché = périmètre_total - frontière_partagée
### 4) On calcule le pourcentage
pourcentage = (non_touché / périmètre_total) * 100
### Concepts PostGIS utilisés
ST_Boundary() → récupère le contour d’un polygone
ST_CollectionExtract() → filtre les LineStrings
ST_Intersection() → extrait la frontière commune
ST_Union() → fusionne les segments
ST_LineMerge() et ST_UnaryUnion() → nettoient les géométries
ST_Length() → calcule la longueur
ST_DWithin() → accélère la détection de frontières proches
### SQL complet, documenté et propre
```sql
WITH dep AS (
  -- 1) Extraction du périmètre de chaque département en 2154
  SELECT 
    d.code_insee,
    d.nom,
    ST_CollectionExtract(
      ST_Boundary(
        ST_Transform(d.geom, 2154)
      ), 2
    ) AS boundary_2154,
    ST_Perimeter(ST_Transform(d.geom, 2154)) AS perimeter_m
  FROM departement.departements d
),

shared AS (
  -- 2) Frontière partagée avec les départements voisins
  SELECT 
    d.code_insee,
    ST_Union(
      ST_Intersection(d.boundary_2154, d2.boundary_2154)
    ) AS shared_geom
  FROM dep d
  JOIN dep d2 
    ON d2.code_insee <> d.code_insee
    AND ST_DWithin(d.boundary_2154, d2.boundary_2154, 0.001)
  GROUP BY d.code_insee
),

shared_len AS (
  -- 3) Longueur totale des frontières partagées
  SELECT 
    d.code_insee,
    d.nom,
    d.perimeter_m,
    COALESCE(
      ST_Length(
        ST_LineMerge(
          ST_UnaryUnion(s.shared_geom)
        )
      ), 
      0
    ) AS shared_border_m
  FROM dep d
  LEFT JOIN shared s ON s.code_insee = d.code_insee
)
-- 4) Calcul du pourcentage de périmètre non-touché
SELECT
  code_insee,
  nom,
  perimeter_m,
  shared_border_m,
  GREATEST(perimeter_m - shared_border_m, 0) AS non_touching_m,
  ROUND(
    (100.0 * GREATEST(perimeter_m - shared_border_m, 0) / NULLIF(perimeter_m, 0))::numeric,
    2
  ) AS pct_non_touching
FROM shared_len
ORDER BY pct_non_touching DESC;
```

## 14. Découper la Garonne par département
```sql
SELECT d.code_insee,
       d.nom AS departement,
       c.nomentiteh AS cours_eau,
       ST_Multi(ST_Intersection(c.geom, d.geom)) AS segment_geom
FROM departement.departements d
JOIN carthage.cours c
    ON c.nomentiteh = 'La Garonne'
   AND c.classe = 1
WHERE ST_Intersects(c.geom, d.geom)
  AND NOT ST_IsEmpty(ST_Intersection(c.geom, d.geom));
```

## 15. Découper la Garonne en segments de 10 km
### Objectif
Découper la géométrie de la Garonne en segments réguliers de 10 km, afin de pouvoir les styliser séparément dans QGIS.
### Explication
On commence par extraire la géométrie de la Garonne.
On la fusionne (ST_Union) puis on la linéarise (ST_LineMerge).
On la reprojecte en 2154 (unités = mètres).
On calcule la longueur totale.
On génère automatiquement une série de segments de 10 000 m.
Chaque segment devient une entité sélectionnable.
### SQL complet
```sql
WITH src AS (
  SELECT ST_CollectionExtract(c.geom, 2) AS geom
  FROM carthage.cours AS c
  WHERE c.nomentiteh ILIKE 'La Garonne' and c.classe =1
),
merged AS (
  SELECT (ST_Dump(ST_LineMerge(ST_Union(geom)))).geom AS geom
  FROM src
),
g2154 AS (
  SELECT ST_Transform(geom, 2154) AS geom
  FROM merged
),
parts AS (
  SELECT
    ROW_NUMBER() OVER () AS part_id,
    geom,
    ST_Length(geom) AS len_m
  FROM g2154
),
segs AS (
  SELECT
    p.part_id,
    seg_idx,
    ST_LineSubstring(
      p.geom,
      (seg_idx * 10000.0) / p.len_m,
      LEAST(((seg_idx + 1) * 10000.0) / p.len_m, 1.0)
    ) AS geom_2154
  FROM parts AS p
  CROSS JOIN LATERAL generate_series(
    0,
    GREATEST(CEIL(p.len_m / 10000.0)::int - 1, 0)
  ) AS seg_idx
)
SELECT
  ROW_NUMBER() OVER () AS fid,
  part_id,
  seg_idx,
  'La Garonne'::text AS cours_eau,
  ST_Multi(geom_2154) AS geom,
  ST_Length(ST_Multi(geom_2154))/1000::int AS longueur_km  
FROM segs                                                   
WHERE NOT ST_IsEmpty(geom_2154);
```

## 16. Comptages avancés (mobilier par parcelle / type)
### Objectif
Compter le mobilier par parcelle
Compter le mobilier par type
Compter le mobilier par parcelle ET par type
Ajouter le total général
### Explication
On utilise des CTE pour organiser le calcul :
req → total par parcelle
req1 → total par type
req2 → total par type et parcelle
total → total général
Puis on assemble toutes les informations en une seule table de sortie.
### SQL complet
```sql
WITH req AS (
    SELECT id_parcelle, COUNT(*) AS nbre_par_parcelle
    FROM arbres.mobilier 
    GROUP BY id_parcelle
    ORDER BY id_parcelle
),
req1 AS (
    SELECT id_type_mobilier, COUNT(*) AS nbre_par_type
    FROM arbres.mobilier 
    GROUP BY id_type_mobilier
    ORDER BY id_type_mobilier
),
req2 AS (
    SELECT id_type_mobilier, id_parcelle, COUNT(*) AS nbre_par_parcelle_type
    FROM arbres.mobilier 
    GROUP BY id_type_mobilier, id_parcelle
    ORDER BY id_type_mobilier
),
total AS (
    SELECT COUNT(*) AS total_mobilier
    FROM arbres.mobilier
)
SELECT 
    req.id_parcelle,
    req.nbre_par_parcelle,
    req1.id_type_mobilier,
    req1.nbre_par_type,
    req2.nbre_par_parcelle_type,
    total.total_mobilier
FROM req2
LEFT JOIN req ON req.id_parcelle = req2.id_parcelle
LEFT JOIN req1 ON req1.id_type_mobilier = req2.id_type_mobilier
CROSS JOIN total;
```

## 17. Triggers : ajout automatique de date de création
### Objectif
Automatiser la mise à jour de date_creation à chaque insertion dans test_mobilier.
### Explication
Un trigger BEFORE INSERT modifie la ligne NEW avant son insertion pour y injecter la date courante.
### 1. Création de la table
```sql
CREATE TABLE public.test_mobilier (
    id_mobilier SERIAL PRIMARY KEY,
    id_parcelle INTEGER,
    id_type_mobilier INTEGER,
    date_creation TIMESTAMP
);
```
### 2. Fonction du trigger
```sql
CREATE OR REPLACE FUNCTION public.fn_set_date_creation()
RETURNS trigger AS $$
BEGIN
    NEW.date_creation := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```
### 3. Création du trigger
```sql
CREATE TRIGGER trg_set_date_creation
BEFORE INSERT ON public.test_mobilier
FOR EACH ROW
EXECUTE FUNCTION public.fn_set_date_creation();
### 4. Insertion de test
INSERT INTO public.test_mobilier (id_mobilier, id_parcelle, id_type_mobilier)
SELECT id_mobilier, id_parcelle, id_type_mobilier
FROM arbres.mobilier;
```
### 5. Vérification
```sql
SELECT *
FROM public.test_mobilier
ORDER BY id_mobilier;
```

## 20 FONCTIONS TEMPORELLES SQL
Date du jour :
```sql 
CURRENT_DATE
```
Date + heure actuelle :
```sql 
CURRENT_TIMESTAMP 
```
Date et heure courantes :
```sql 
NOW() 
```
Extrait l’année :
```sql 
YEAR(date) 
```
Extrait le mois (1–12) :
```sql 
MONTH(date) 
```
Extrait le jour du mois :
```sql
DAY(date) 
```
Extrait l’heure :
```sql
HOUR(date) 
```
Extrait les minutes :
```sql
MINUTE(date)
```
Extrait les secondes :
```sql
SECOND(date) 
```
Extrait une partie spécifique (standard SQL) :
```sql
EXTRACT(part FROM date) 
```
Début de période (PostgreSQL)
```sql
DATE_TRUNC('month', date) 
```
Formate une date (MySQL) :
```sql
DATE_FORMAT(date, '%Y-%m') 
```
Ajoute une période :
```sql
DATE_ADD(date, INTERVAL 1 MONTH) 
```
Retire une période :
```sql
DATE_SUB(date, INTERVAL 1 MONTH) 
```
Ajoute une période (PostgreSQL) :
```sql
date + INTERVAL '1 month' 
```
Différence en jours :
```sql
DATEDIFF(date1, date2) 
```
Différence en mois, années, etc :
```sql
TIMESTAMPDIFF(unit, d1, d2) 
```
Dernier jour du mois :
```sql
LAST_DAY(date) 
```
Numéro du jour de la semaine :
```sql
DAYOFWEEK(date) 
```
Numéro de semaine :
```sql
WEEK(date) 
```








