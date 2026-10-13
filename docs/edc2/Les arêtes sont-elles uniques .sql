SELECT
    id,
    COUNT(*) AS nombre
FROM geo_standards.v_troncon_pgrouting
GROUP BY id
HAVING COUNT(*) > 1;
