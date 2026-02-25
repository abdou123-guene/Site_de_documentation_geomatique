#  Fiche complète PostgreSQL / PostGIS 

# 🔗 Documentation
- Documentation officielle PostgreSQL : https://www.postgresql.org/docs/

---

#  1. Fonctions PostGIS dans SELECT et JOIN

###  Fonctions dans **SELECT**
- ST_Buffer
- ST_Difference
- ST_Transform
- ST_Intersection

###  Fonctions dans **JOIN / WHERE**
- ST_Intersects
- ST_Contains
- ST_Within
- ST_DWithin

---

#  2. Géotraitements

## 2.1 Intersection (Découpe)

```sql
WITH req AS (
   SELECT sitecode, sitename,
          st_collectionextract(
               st_multi(st_intersection(r.geom, z.geom)), 3
          )::geometry(Multipolygon, 2154) AS geom_inter
   FROM public.zps AS z
   JOIN public.regions AS r ON st_intersects(r.geom, z.geom)
   WHERE r.code_reg = '72'
),
req_1 AS (
   SELECT sitecode, sitename,
          st_area(geom_inter) / 1000000 AS surface_km2
   FROM req
)
SELECT SUM(surface_km2) AS total_surface_km2
FROM req_1;
```

---

## 2.2 Différence + Buffer

```sql
WITH req AS (
   SELECT ST_Union(ST_Buffer(pav.geom, 500)) AS buffered_union
   FROM public.pav
)
SELECT commune.geom AS commune_geom,
       ST_Difference(commune.geom, req.buffered_union) AS zone_non_couverte
FROM public.communes_france AS commune, req
WHERE ST_Intersects(commune.geom, req.buffered_union);
```

---

## 2.3 ST_Distance (condition)

```sql
SELECT DISTINCT e.id, p.commune, p.code_postal,
       st_distance(e.geom, p.geom) AS distance
FROM public.pav p
JOIN public.ecole_elem_matern e
     ON st_distance(e.geom, p.geom) <= 100
GROUP BY e.id, p.commune, p.code_postal, e.geom, p.geom
ORDER BY distance ASC
LIMIT 5;
```

---

#  3. GROUP BY

```sql
WITH req AS (
   SELECT DISTINCT e.id, p.commune, p.code_postal, p.type_flux,
          st_distance(e.geom, p.geom) AS distance
   FROM public.pav p
   JOIN public.ecole_elem_matern e
       ON st_distance(e.geom, p.geom) <= 50
   WHERE p.type_flux = 'textile'
)
SELECT req.type_flux, COUNT(req.id)
FROM req
GROUP BY req.type_flux;
```

---

#  4. JOIN Avancés

## 4.1 ON TRUE

```sql
SELECT DISTINCT ON (e.id)
       e.id AS ecole_id, p.id AS pav_id,
       p.commune, p.code_postal,
       ST_Distance(e.geom, p.geom) AS distance
FROM public.pav p
JOIN public.ecole_elem_matern e
     ON TRUE
ORDER BY e.id, distance ASC;
```

## 4.2 ST_DWithin

```sql
WITH req AS (
   SELECT COUNT(DISTINCT e.id) AS ecole_textile
   FROM public.pav p
   JOIN public.ecole_elem_matern e
       ON ST_DWithin(e.geom, p.geom, 50)
   WHERE p.type_flux ILIKE '%textile%'
)
SELECT
   (SELECT COUNT(*) FROM public.ecole_elem_matern) - req.ecole_textile AS ecoles_sans_pav_textile,
   req.ecole_textile AS ecoles_avec_pav_textile
FROM req;
```

---

#  5. ST_Intersects vs ST_Intersection

| Fonction | Rôle |
|---------|------|
| ST_Intersects() | Vrai/Faux |
| ST_Intersection() | Zone commune (géométrie) |

```sql
SELECT SUM(ST_length(st_intersection(t1.geom, t2.geom))) / 1000 AS length_km
FROM public.filaire_de_voirie t1
JOIN public.jour_collect t2
   ON ST_Intersects(t1.geom, t2.geom);
```

---

#  6. Découper un linéaire par département

```sql
SELECT d.code_insee, d.nom AS departement, c.nomentiteh AS cours_eau,
       ST_Intersection(c.geom, d.geom) AS segment_geom
FROM departement.departements d
JOIN carthage.cours c
   ON c.nomentiteh = 'La Garonne'
WHERE ST_Intersects(c.geom, d.geom)
  AND NOT ST_IsEmpty(ST_Intersection(c.geom, d.geom));
```

---

#  7. Distance depuis un point

```sql
WITH req AS (
   SELECT commune,
          ST_Distance(geom, ST_GeomFromText('POINT(574103 6279386)', 2154)) AS distance
   FROM public.pav
   WHERE commune = 'Toulouse'
   ORDER BY distance ASC
)
SELECT AVG(distance) AS average_distance
FROM req;
```

---

#  8. Droits / Rôles / Groupes

## Création d’un rôle

```sql
CREATE ROLE Lea LOGIN PASSWORD 'toto';
GRANT SELECT (fid, geom), UPDATE (geom)
ON TABLE cadastre_tlse.parcelles, cadastre_tlse.batiments
TO Lea;
```

## Création de groupes

```sql
CREATE ROLE gr_visu;
CREATE ROLE gr_gestion_parcelles;
CREATE ROLE gr_gestion_batiments;
CREATE ROLE gr_dessin_cadastre;
CREATE ROLE gr_maj_type_bati;
```

## Affectation

```sql
GRANT SELECT ON ALL TABLES IN SCHEMA cadastre_tlse TO gr_visu;
GRANT SELECT,INSERT,UPDATE,DELETE ON cadastre_tlse.parcelles TO gr_gestion_parcelles;
GRANT UPDATE (geom) ON cadastre_tlse.parcelles TO gr_dessin_cadastre;
```

---

#  9. UPDATE, CAST, ROUND

```sql
UPDATE public.regions
SET perimetre_km = ROUND(st_perimeter(geom) / 1000 :: numeric, 2);
```

---

#  10. Import Shapefile (GDAL)

```
ogr2ogr -f "PostgreSQL" PG:"dbname=GDAL user=postgres password=XXX host=localhost port=5434" "C:\path\REGION.shp" -nln regions -nlt MULTIPOLYGON
```

---

#  11. ST_Transform

```sql
CREATE TABLE table_reproj AS
SELECT ST_Transform(geom, 4326) AS geom, *
FROM table_originale;
```

---

#  12. INSERT INTO

```sql
INSERT INTO public.etat (type)
VALUES ('sain'), ('malade'), ('casse'), ('mort');
```

---

#  13. CREATE TABLE

```sql
CREATE TABLE arbre (
   id_arbre int generated always as IDENTITY PRIMARY KEY,
   diametre real,
   hauteur real,
   geom geometry(point,2154)
);
```

---

#  14. Import CSV + mise à jour des géométries

```sql
COPY faune_auvergne_temp
FROM 'C:\...aune.csv'
CSV HEADER DELIMITER ';';
```

Ajouter une colonne :

```sql
ALTER TABLE public.faune_auvergne_temp
ADD column geom geometry(point,2154);
```

Mettre à jour :

```sql
UPDATE public.faune_auvergne_temp f
SET geom = (
   SELECT geom
   FROM public.faune_auvergne t
   WHERE t.id = f.id_num
)
WHERE EXISTS (
   SELECT 1
   FROM public.faune_auvergne t
   WHERE t.id = f.id_num
);
```

---

#  15. Dates disponibles (generate_series)

```sql
SELECT jour
FROM generate_series(
   '2025-03-01'::date,
   '2025-03-31'::date,
   '1 day'::interval
) AS jour
WHERE jour NOT IN (
   SELECT date_location::date
   FROM louer
   WHERE id_salle = '3'
     AND EXTRACT(YEAR FROM date_location) = 2025
     AND EXTRACT(MONTH FROM date_location) = 3
);
```

---

#  16. Triggers

## Date automatique

```sql
CREATE OR REPLACE FUNCTION fn_set_date_creation()
RETURNS trigger AS $$
BEGIN
   NEW.date_creation := NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_date_creation
BEFORE INSERT ON public.test_mobilier
FOR EACH ROW
EXECUTE FUNCTION fn_set_date_creation();
```

## Surface automatique

```sql
CREATE OR REPLACE FUNCTION update_area()
RETURNS TRIGGER AS $$
BEGIN
   NEW.surface_m2 := ST_Area(NEW.geom);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_update_area
BEFORE INSERT OR UPDATE ON zones
FOR EACH ROW
EXECUTE FUNCTION update_area();
```

---

#  17. INDEX

```sql
CREATE INDEX idx_parcel_numpar_c10436
ON village.parcel (numpar)
WHERE numpar ILIKE 'c10436';
```



