-----------------------------------------------------------
## 1. Création d’index
-----------------------------------------------------------
### Objectif
Créer un index partiel sur la colonne numpar pour accélérer les requêtes ciblant la parcelle c10436.
### Explication

Les index B‑Tree accélèrent les comparaisons textuelles.
L’usage de WHERE dans l’index le rend partiel, donc plus petit et plus rapide.
Spécialement utile pour les requêtes utilisant ILIKE.

### Code SQL
``
CREATE INDEX idx_parcel_numpar_c10436ON village.parcel (numpar)WHERE numpar ILIKE 'c10436';``Afficher plus de lignes
``
-----------------------------------------------------------
## 2. Création d’une vue matérialisée simplifiée
-----------------------------------------------------------
### Objectif
Créer une vue matérialisée de la couche des cours d’eau avec une géométrie simplifiée pour :

améliorer les performances,
accélérer l'affichage dans QGIS.

### Explication

st_simplify(geom, 20) réduit la complexité géométrique (tolérance = 20 m).
Les vues matérialisées stockent physiquement les résultats.
On ajoute un index spatial pour accélérer les requêtes ultérieures.

### Code SQL
``
CREATE MATERIALIZED VIEW carthage.cours_eau_simplifiee AS
SELECT gid, cdentitehy, nomentiteh, candidat, classe,
       ST_Simplify(geom, 20) AS geom
FROM carthage.cours;

CREATE INDEX geom_cours_eau_simplifiee
ON carthage.cours
USING GIST(geom);
``
-----------------------------------------------------------
## 3. Connaître le SRID d’une couche
-----------------------------------------------------------
### Objectif
Identifier le système de référence spatiale d’une couche.
### Explication

Find_SRID retourne le SRID déclaré dans la métadonnée PostGIS.
SELECT Find_SRID('carthage', 'cours', 'geom');

-----------------------------------------------------------
## 4. Longueur du réseau d'eau usée
-----------------------------------------------------------
### Objectif
Calculer la longueur totale du réseau d'assainissement.
### Explication

ST_Length(geom) calcule la longueur dans l’unité du SRID (souvent mètres).
SUM() additionne la longueur de toutes les lignes.
``
SELECT SUM(ST_Length(geom)) AS longueur
FROM village.o_usees;
``
-----------------------------------------------------------
## 5. Périmètre des zones PLU ND
-----------------------------------------------------------
### Objectif
Calculer le périmètre total des zones PLU ND (corrigé en hectares ou km).
``
SELECT SUM(ST_Perimeter(geom) / 10000) AS perimetre_haFROM village.pos;
SELECT SUM(ST_Perimeter(geom) / 10000) AS perimetre_ha
FROM village.pos;
``
-----------------------------------------------------------
## 6. Parcelles traversées par le réseau d’eau usée
-----------------------------------------------------------
### Objectif
Trouver les parcelles dont la géométrie intersecte la géométrie du réseau.
### Explication

ST_Intersects(a, b) retourne true si les géométries se coupent ou se touchent.
``
SELECT DISTINCT p.*
FROM village.parcel p
JOIN village.o_usees o
ON ST_Intersects(o.geom, p.geom);
``
-----------------------------------------------------------
## 7. Parcelles bâties
-----------------------------------------------------------
### Objectif
Sélectionner les parcelles contenant au moins un bâtiment.
### Explication

ST_Contains(p.geom, b.geom) vérifie si un bâtiment est entièrement dans une parcelle.
``
LSELECT DISTINCT p.*FROM village.parcel pJOIN village.bati bON ST_Contains(p.geom, b.geom);Afficher plus de lignes
``
-----------------------------------------------------------
## 8. Départements traversés par la Garonne
-----------------------------------------------------------
### Objectif
Lister les départements qui intersectent La Garonne.
``
SELECT DISTINCT d.code_in
SELECT DISTINCT d.code_insee, d.nom, c.nomentiteh
FROM departement.departements d
JOIN carthage.cours c
ON ST_Intersects(c.geom, d.geom)
WHERE c.nomentiteh = 'La Garonne'
  AND c.classe = 1;
  ``
 -----------------------------------------------------------
## 9. Parcelles voisines d'une parcelle donnée
-----------------------------------------------------------
### Objectif
Trouver les parcelles qui touchent la parcelle c10436.
📌 Explication

ST_Touches détecte les contacts par frontières (bordure), pas les intersections internes.
``
WITH req AS (
  SELECT *
  FROM village.parcel
  WHERE numpar ILIKE 'c10436'
)
SELECT DISTINCT p2.*
FROM village.parcel p2
JOIN req
ON ST_Touches(p2.geom, req.geom);
``
-----------------------------------------------------------
## 10. Comptage des zones d’occupation du sol autour des tourbières (412)
-----------------------------------------------------------
### Objectif
Trouver les zones de Corine Land Cover touchant les tourbières (code 412).
``
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
``
-----------------------------------------------------------
## 11. Distance des zones industrielles (121) à la Garonne
-----------------------------------------------------------
### Objectif
Calculer la distance entre les zones industrielles et La Garonne dans un rayon de 10 km.
``
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
``
-----------------------------------------------------------
## 12. Bâtiment le plus proche du réseau d’eau usée
-----------------------------------------------------------
### Version optimisée avec LATERAL
``
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
``
-----------------------------------------------------------
## 13. Pourcentage de périmètre non-touché par d’autres départements
-----------------------------------------------------------
➡️ (Version longue déjà fournie, conservée ici pour complétude : non modifiée)

-----------------------------------------------------------
## 14. Découper la Garonne par département
-----------------------------------------------------------
``
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
  ``
 -----------------------------------------------------------
## 15. Découper la Garonne en segments de 10 km
-----------------------------------------------------------
➡️ Version avancée conservée telle quelle (déjà très propre).

-----------------------------------------------------------
## 16. Comptages avancés (mobilier par parcelle / type)
-----------------------------------------------------------
(Version conservée, documentée si tu veux ensuite)

-----------------------------------------------------------
## 17. Triggers : ajout automatique de date de création
-----------------------------------------------------------
Objectif
Créer un trigger qui remplit automatiquement la colonne date_creation lors d'une insertion.

### Création de la table
``
CREATE TABLE public.test_mobilier (
    id_mobilier SERIAL PRIMARY KEY,
    id_parcelle INTEGER,
    id_type_mobilier INTEGER,
    date_creation TIMESTAMP
);
``
### Fonction du trigger
``
CREATE OR REPLACE FUNCTION public.fn_set_date_creation()
RETURNS trigger AS $$
BEGIN
    NEW.date_creation := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
``
### Création du trigger
``
CREATE TRIGGER trg_set_date_creation
BEFORE INSERT ON public.test_mobilier
FOR EACH ROW
EXECUTE FUNCTION public.fn_set_date_creation();
``
### Insertion de test
``
INSERT INTO public.test_mobilier (id_mobilier,id_parcelle, id_type_mobilier)
SELECT id_mobilier,id_parcelle, id_type_mobilier
FROM arbres.mobilier;
``