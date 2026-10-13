--Nœud de départ : tout tronçon dont le champ from
SELECT t.id
FROM geo_standards.troncon_cheminement AS t
LEFT JOIN geo_standards.noeud_cheminement AS n
    ON t."from" = n.id_netex
WHERE n.id_netex IS NULL;
--Nœud d’arrivée : la même vérification est faite sur le champ to
SELECT t.id
FROM geo_standards.troncon_cheminement AS t
LEFT JOIN geo_standards.noeud_cheminement AS n
    ON t."to" = n.id_netex
WHERE n.id_netex IS NULL;
