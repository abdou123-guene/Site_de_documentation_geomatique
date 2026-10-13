SELECT
    id
FROM geo_standards.troncon_cheminement
WHERE geom IS NULL
   OR ST_IsEmpty(geom);
