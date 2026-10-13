SELECT
    ST_SRID(geom) AS srid,
    COUNT(*) AS nombre
FROM geo_standards.troncon_cheminement
GROUP BY ST_SRID(geom);
