SELECT
    id,
    "from" AS noeud_depart,
    "to"   AS noeud_arrivee
FROM geo_standards.troncon_cheminement
WHERE "from" = "to";
