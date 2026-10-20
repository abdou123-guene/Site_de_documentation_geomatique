SELECT
    component,
    COUNT(*) AS nb_noeuds
FROM pgr_connectedComponents(
    'SELECT id, source, target, cost, cost AS reverse_cost
     FROM geo_standards.v_troncon_pgrouting'
)
GROUP BY component
ORDER BY nb_noeuds DESC;
