SELECT
    COUNT(*) AS nombre_total,
    COUNT(*) FILTER (WHERE id IS NULL) AS id_manquant,
    COUNT(*) FILTER (WHERE geom IS NULL) AS geometrie_manquante,
    COUNT(*) FILTER (WHERE "from" IS NULL) AS noeud_depart_manquant,
    COUNT(*) FILTER (WHERE "to" IS NULL) AS noeud_arrivee_manquant
FROM geo_standards.troncon_cheminement;
