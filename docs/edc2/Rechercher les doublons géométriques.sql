SELECT
    a.id AS troncon_1,
    b.id AS troncon_2
FROM geo_standards.troncon_cheminement AS a
JOIN geo_standards.troncon_cheminement AS b
    ON a.id < b.id
   AND ST_Equals(a.geom, b.geom);
