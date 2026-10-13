SELECT t.id
FROM geo_standards.troncon_cheminement AS t
LEFT JOIN geo_standards.noeud_cheminement AS n
    ON t."from" = n.id_netex
WHERE n.id_netex IS NULL;
