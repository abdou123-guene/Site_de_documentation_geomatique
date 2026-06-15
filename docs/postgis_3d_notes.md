# PostGIS 3D

## Vérification des géométries

```sql
SELECT (st_isvaliddetail(geom)).location
FROM bdtopo64.commune
WHERE NOT st_isvalid(geom);
```

## Correction auto-intersection

```sql
UPDATE bdtopo64.commune
SET geom = st_makevalid(geom)
WHERE NOT st_isvalid(geom);
```

## Correction trou sur bord du polygone

```sql
UPDATE bdtopo64.commune
SET geom = st_collectionextract(st_makevalid(geom),3)
WHERE NOT st_isvalid(geom);
```

## Vérifier géométrie 3D (planarité)

```sql
SELECT *
FROM bdtopo64.batiment
WHERE NOT CG_IsPlanar(st_geometryn(geom,1));
```

## Import raster MNT

```bash
raster2pgsql -s 2154 -d -C -I -l 4 -M -t 256x256 mnt.tif mnt_raster.mnt | psql -U postgres -W -p 5433 -d bd_3d_cpgeom
```

## Import LiDAR

```bash
raster2pgsql -s 2154 -d -C -I -l 4 -M -t 256x256 *M50_LAMB93_IGN69.tif mnt_raster.mnt_lidar | psql -U postgres -W -p 5433 -d bd_3d_cpgeom
```

## Ajouter géométrie 3D

```sql
ALTER TABLE mnt_vecteur.altimetrie_voies
ADD COLUMN geomz geometry(pointz,2154);
```

## Créer point Z

```sql
UPDATE mnt_vecteur.altimetrie_voies
SET geomz = st_makepoint(st_x(geom), st_y(geom), altimetrie);
```

## Créer point 3D

```sql
SELECT st_makepoint(395959.8, 6212025.3, 2400);
```

## Distance 2D / 3D

```sql
SELECT b.fid,l.fid,
       st_distance(b.geom,l.geom),
       st_3ddistance(b.geom,l.geom)
FROM bdtopo64.v_batis_zone b
CROSS JOIN bdtopo64.v_lignes_zone l
ORDER BY 4;
```

## Bâtiment le plus proche

```sql
SELECT b.fid,
       st_3ddistance(b.geom,l.geom) as distance
FROM bdtopo64.v_batis_zone b
CROSS JOIN bdtopo64.v_lignes_zone l
ORDER BY distance
LIMIT 1;
```

## Bâtiments à moins de 25m

```sql
SELECT b.fid,b.geom,b.hauteur
FROM bdtopo64.v_batis_zone b
JOIN bdtopo64.v_lignes_zone l
ON st_3ddistance(b.geom,l.geom) < 25;
```

## Calcul de pente

```sql
WITH sentier AS (
  SELECT fid, geom
  FROM bdtopo64.troncon_de_route
  WHERE fid = 248930
)
SELECT st_length(geom),
       max(st_value(rast, st_startpoint(geom))) as altitude_depart,
       max(st_value(rast, st_endpoint(geom))) as altitude_arrivee
FROM mnt_raster.vm_zone_lidar
JOIN sentier ON st_intersects(sentier.geom,rast)
GROUP BY sentier.geom;
```
