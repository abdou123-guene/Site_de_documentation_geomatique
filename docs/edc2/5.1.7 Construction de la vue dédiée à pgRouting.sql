ELECT
    t.id::bigint AS id,
    t.noeud_depart_id::bigint AS source,
    t.noeud_arrivee_id::bigint AS target,
    NULLIF(TRIM(t.distance), '')::double precision AS cost,
    t.troncon_id_netex,
    t.typetronco,
    t.statutvoi,
    NULLIF(TRIM(t.distance), '')::double precision AS longueur,
    t.pente,
    t.devers,
    ABS(t.pente) AS pente_absolue,
    ABS(t.devers) AS devers_absolu,
    t.geom
FROM geo_standards.troncon_cheminement AS t
WHERE t.id IS NOT NULL
  AND t.noeud_depart_id IS NOT NULL
  AND t.noeud_arrivee_id IS NOT NULL
  AND NULLIF(TRIM(t.distance), '')::double precision > 0
  AND t.geom IS NOT NULL;
