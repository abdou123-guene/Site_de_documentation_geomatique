SELECT
    GeometryType(geom) AS type_geometrie,
    COUNT(*) AS nombre
FROM geo_standards.troncon_cheminement
GROUP BY GeometryType(geom);
