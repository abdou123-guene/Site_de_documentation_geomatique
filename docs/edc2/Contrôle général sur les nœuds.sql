SELECT
    COUNT(*) AS nombre_total,
    COUNT(*) FILTER (WHERE id_netex IS NULL) AS id_netex_manquant,
    COUNT(*) FILTER (WHERE geom IS NULL) AS geometrie_manquante,
    COUNT(*) FILTER (
        WHERE altitude IS NULL OR TRIM(altitude::text) = ''
    ) AS altitude_manquante
FROM geo_standards.noeud_cheminement;
