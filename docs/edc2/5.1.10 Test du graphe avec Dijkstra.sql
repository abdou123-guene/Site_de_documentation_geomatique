WITH chemin AS (
    SELECT *
    FROM pgr_dijkstra(
        'SELECT id, source, target, cost
         FROM geo_standards.v_troncon_pgrouting
         WHERE source IS NOT NULL
           AND target IS NOT NULL
           AND cost > 0',
        100,
        281,
        directed := false
    )
)
SELECT c.seq, c.path_seq, c.node, c.edge, c.cost AS cout_troncon,
       c.agg_cost AS cout_cumule, t.id AS troncon_id, t.source, t.target,
       t.longueur, t.pente, t.pente_absolue, t.geom
FROM chemin AS c
JOIN geo_standards.v_troncon_pgrouting AS t ON c.edge = t.id
WHERE c.edge <> -1
ORDER BY c.seq;
