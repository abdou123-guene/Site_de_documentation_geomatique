CREATE OR REPLACE VIEW geo_standards.v_troncon_pgrouting AS
SELECT
    t.id::bigint AS id,
    nd.id::bigint AS source,
    na.id::bigint AS target,
    t.longueur::double precision AS cost,
    t.id_netex,
    t.typtronco,
    t.statutvoi,
    t.longueur::double precision AS longueur,
    nd.altitude::double precision AS altitude_depart,
    na.altitude::double precision AS altitude_arrivee,
    (
        na.altitude::double precision
        - nd.altitude::double precision
    ) AS denivele,
    (
        (
            na.altitude::double precision
            - nd.altitude::double precision
        )
        / NULLIF(t.longueur::double precision, 0)
    ) * 100 AS pente,
    ABS(
        (
            (
                na.altitude::double precision
                - nd.altitude::double precision
            )
            / NULLIF(t.longueur::double precision, 0)
        ) * 100
    ) AS pente_absolue,
    t.geom
FROM geo_standards.troncon_cheminement AS t
JOIN geo_standards.noeud_cheminement AS nd
    ON nd.id_netex = t."from"
JOIN geo_standards.noeud_cheminement AS na
    ON na.id_netex = t."to"
WHERE t.id IS NOT NULL
  AND t."from" IS NOT NULL
  AND t."to" IS NOT NULL
  AND t.longueur IS NOT NULL
  AND t.longueur::double precision > 0
  AND t.geom IS NOT NULL;
