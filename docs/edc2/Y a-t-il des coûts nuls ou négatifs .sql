SELECT
    id,
    id_netex,
    cost
FROM geo_standards.v_troncon_pgrouting
WHERE cost <= 0;
