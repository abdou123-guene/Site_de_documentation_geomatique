SELECT *
FROM geo_standards.troncon_cheminement
WHERE TRIM(id_netex::text) = ''
   OR TRIM("from"::text) = ''
   OR TRIM("to"::text) = '';
