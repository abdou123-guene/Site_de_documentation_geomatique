# PostGIS 3D – Mémo complet
---

## 1. Vérification et correction des géométries

### Vérifier la validité
```sql
SELECT (st_isvaliddetail(geom)).location
FROM bdtopo64.commune
WHERE NOT st_isvalid(geom);
```

### Correction auto-intersection
```sql
UPDATE bdtopo64.commune
SET geom = st_makevalid(geom)
WHERE NOT st_isvalid(geom);
```

### Correction trou sur bord du polygone
```sql
UPDATE bdtopo64.commune
SET geom = st_collectionextract(st_makevalid(geom), 3)
WHERE NOT st_isvalid(geom);
```

## 2. Géométrie 3D

### Vérifier si l’objet est plan
```sql
SELECT *
FROM bdtopo64.batiment
WHERE NOT CG_IsPlanar(st_geometryn(geom, 1));
```

### Créer un point 3D
```sql
SELECT st_makepoint(395959.8, 6212025.3, 2400);
```

## 3. Import raster

### Import MNT
```bash
raster2pgsql -s 2154 -d -C -I -l 4 -M -t 256x256 mnt.tif mnt_raster.mnt | psql -U postgres -W -p 5433 -d bd_3d_cpgeom
```

### Import LiDAR
```bash
raster2pgsql -s 2154 -d -C -I -l 4 -M -t 256x256 *M50_LAMB93_IGN69.tif mnt_raster.mnt_lidar | psql -U postgres -W -p 5433 -d bd_3d_cpgeom
```

### Import BD ALTI
```bash
raster2pgsql -s 2154 -d -C -I -l 4 -M -t 256x256 *.asc mnt_raster.mnt_bdalti | psql -U postgres -W -p 5433 -d bd_3d_cpgeom
```

## 4. MNT vecteur

### Ajouter géométrie Z
```sql
ALTER TABLE mnt_vecteur.altimetrie_voies
ADD COLUMN geomz geometry(pointz, 2154);
```

### Créer points Z
```sql
UPDATE mnt_vecteur.altimetrie_voies
SET geomz = st_makepoint(st_x(geom), st_y(geom), altimetrie);
```

## 5. Orthophoto IGN WMTS

https://data.geopf.fr/annexes/ressources/wmts/ortho.xml

## 6. Gestion LiDAR

### Créer raster unique
```sql
CREATE MATERIALIZED VIEW mnt_raster.vm_lidar AS
SELECT 1 AS fid, st_union(rast)
FROM mnt_raster.o_4_mnt_lidar;
```
