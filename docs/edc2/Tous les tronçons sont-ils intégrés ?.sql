SELECT
    (SELECT COUNT(*) FROM geo_standards.troncon_cheminement) AS nb_troncons_source,
    (SELECT COUNT(*) FROM geo_standards.v_troncon_pgrouting) AS nb_troncons_reseau;
