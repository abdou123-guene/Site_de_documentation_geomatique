SELECT COUNT(*) AS nb_lignes_invalides
FROM geo_standards.v_troncon_pgrouting
WHERE id IS NULL
   OR source IS NULL
   OR target IS NULL
   OR cost IS NULL
   OR geom IS NULL;
