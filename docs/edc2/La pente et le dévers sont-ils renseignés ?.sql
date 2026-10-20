SELECT
    COUNT(*) AS nombre_total,
    COUNT(*) FILTER (WHERE pente IS NULL) AS pente_manquante,
    COUNT(*) FILTER (WHERE devers IS NULL) AS devers_manquant
FROM geo_standards.v_troncon_pgrouting;
