SELECT
    id,
    ST_IsValidReason(geom) AS motif
FROM geo_standards.troncon_cheminement
WHERE NOT ST_IsValid(geom);
