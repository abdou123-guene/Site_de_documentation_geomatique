SELECT
    t.id,
    t."from",
    t.noeud_depart_id,
    nd.id AS id_attendu_depart,
    t."to",
    t.noeud_arrivee_id,
    na.id AS id_attendu_arrivee
FROM geo_standards.troncon_cheminement AS t
JOIN geo_standards.noeud_cheminement AS nd
    ON nd.id_netex = t."from"
JOIN geo_standards.noeud_cheminement AS na
    ON na.id_netex = t."to"
WHERE nd.id <> t.noeud_depart_id
   OR na.id <> t.noeud_arrivee_id;
