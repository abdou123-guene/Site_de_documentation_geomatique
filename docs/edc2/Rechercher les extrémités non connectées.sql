SELECT
    t1.id,
    ST_EndPoint(t1.geom) AS extremite_non_connectee
FROM geo_standards.troncon_cheminement AS t1
WHERE NOT EXISTS (
    SELECT 1
    FROM geo_standards.troncon_cheminement AS t2
    WHERE t1.id <> t2.id
      AND (
            ST_DWithin(ST_EndPoint(t1.geom), ST_StartPoint(t2.geom), 0.01)
         OR ST_DWithin(ST_EndPoint(t1.geom), ST_EndPoint(t2.geom), 0.01)
      )
);
