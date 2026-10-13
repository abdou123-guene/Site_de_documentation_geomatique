SELECT
    id,
    COUNT(*) AS nombre_occurrences
FROM geo_standards.troncon_cheminement
GROUP BY id
HAVING COUNT(*) > 1;
