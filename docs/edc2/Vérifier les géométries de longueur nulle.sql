SELECT
    id,
    ST_Length(geom) AS longueur
FROM geo_standards.troncon_cheminement
WHERE ST_Length(geom) = 0;
