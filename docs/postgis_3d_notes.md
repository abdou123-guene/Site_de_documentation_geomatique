# PostGIS 3D

## Vérifier la validité d'une géométrie

```sql
SELECT (st_isvaliddetail(geom)).location
FROM bdtopo64.commune
WHERE not st_isvalid(geom);
```

Correction auto-intersection :

```sql
UPDATE bdtopo64.commune
SET geom = st_makevalid(geom)
WHERE not st_isvalid(geom);
```

Correction trou sur le bord du polygone :

```sql
UPDATE bdtopo64.commune
SET geom = st_collectionextract(st_makevalid(geom), 3)
WHERE not st_isvalid(geom);
```

## Validité géométrie 3D

Est-ce que l'objet est plan ?

```sql
SELECT *
FROM bdtopo64.batiment
WHERE not CG_IsPlanar(st_geometryn(geom, 1));
```

## Import raster mnt.tif dans schema mnt_raster de la base postgis bd_3d_cpgeom

En ligne de commande (cmd) :

```
"C:\Program Files\PostgreSQL\18\bin\raster2pgsql.exe" -s 2154 -d -C -I -l 4 -M -t 256x256 mnt.tif mnt_raster.mnt | "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -W -p 5433 -d bd_3d_cpgeom
```

## Import dalles LiDAR dans un schema mnt_raster

```
"C:\Program Files\PostgreSQL\18\bin\raster2pgsql.exe" -s 2154 -d -C -I -l 4 -M -t 256x256 *M50_LAMB93_IGN69.tif mnt_raster.mnt_lidar | "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -W -p 5433 -d bd_3d_cpgeom
```

## Import MNT ASC de la BD ALTI

```
"C:\Program Files\PostgreSQL\18\bin\raster2pgsql.exe" -s 2154 -d -C -I -l 4 -M -t 256x256 *.asc mnt_raster.mnt_bdalti | "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -W -p 5433 -d bd_3d_cpgeom
```

## MNT vecteur

Ajouter une géométrie 3D :

```sql
ALTER TABLE mnt_vecteur.altimetrie_voies
ADD COLUMN geomz geometry(pointz, 2154);
```

### Créer des points Z à partir d'une géométrie 2D et d'un attribut d'altitude

```sql
SELECT
ST_GeomFromEWKT(
    'pointz(' || st_x(geom) || ' ' || st_y(geom) || ' ' || altimetrie || ')')
FROM mnt_vecteur.altimetrie_voies
ORDER BY fid ASC;
```

Mise à jour de la colonne geomz :

```sql
UPDATE mnt_vecteur.altimetrie_voies
SET geomz = ST_GeomFromEWKT(
    'pointz(' || st_x(geom) || ' ' || st_y(geom) || ' ' || altimetrie || ')');
```

Ou bien :

```sql
UPDATE mnt_vecteur.altimetrie_voies
SET geomz = st_makepoint(st_x(geom), st_y(geom), altimetrie);
```

## Orthophoto IGN WMTS

https://data.geopf.fr/annexes/ressources/wmts/ortho.xml

## Créer un point en 3D

```sql
SELECT st_makepoint(395959.8, 6212025.3, 2400);
```

## Gestion LiDAR

Créer un seul objet (vue matérialisée) :

```sql
CREATE MATERIALIZED VIEW mnt_raster.vm_lidar AS
SELECT 1 AS fid, st_union(rast)
FROM mnt_raster.o_4_mnt_lidar;
```
