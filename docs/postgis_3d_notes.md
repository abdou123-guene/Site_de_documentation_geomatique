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

## 7. Quelques exemples d'affichage avec le Plugin QGIS2Three js

***Extension:*** Qgis2threeJS exporter pour faire une vue en 3D, mais attention, l’extension n’est pas disponible dans toutes les versions de qgis.

***Attention:*** créer une ligne (polygonale ou point) shp avec z, draper (boite à outil) la avec le MNT, ensuite créer une couche point avec z et digitalisez la avec les sommets de la ligne drapée (activez l’accrochage d’abord) 

<img width="602" height="339" alt="1" src="https://github.com/user-attachments/assets/01bd895d-07a9-41d6-b4bf-4fcf1fe5a04e" />

Ouverture de Qgis2threeJS exporter via l’onglet internet

<img width="602" height="339" alt="1" src="https://github.com/user-attachments/assets/600b6aad-f6b7-4e91-aafc-faa2a2b18f1d" />

Ensuite on peut jouer sur les paramètres pour rendre plus joli (clic droit sur la couche concernée pour voir les paramètres)

<img width="602" height="339" alt="1" src="https://github.com/user-attachments/assets/da7d50d7-e94f-4939-b61e-dccf9cbe7715" />

On peut également travailler avec la vue 3D ou ***PROFIL D'ÉLÉVATION*** dans l’onglet l’onglet vue de QGIS.

Ensuite décocher la ligne et les points dans le projet qgis pour ne plus les voir dans ton affichage 3D:

<img width="602" height="339" alt="1" src="https://github.com/user-attachments/assets/6edc9c01-69ca-4273-bccf-d9b3fa181d94" />

Sur ***profil d'élévation*** aussi, vous pouvez jouer sur les paramètres et aussi en faisant clic droit sur la couche.

<img width="602" height="339" alt="1" src="https://github.com/user-attachments/assets/6127fe2c-6582-4cc9-996b-64997ffb1e41" />

Avec un polygone, on peut appliquer la même procédure et jouer sur les paramètres pour avoir un “cube”. Jouez sur les paramètres: type, altitude et high.

<img width="602" height="339" alt="1" src="https://github.com/user-attachments/assets/13da9f3a-55bf-47c0-b445-17b2c4d1d3a1" />

<img width="602" height="339" alt="2" src="https://github.com/user-attachments/assets/6a10dbd3-6393-489d-97e9-6cd4b4e2a3e7" />

<img width="602" height="339" alt="3" src="https://github.com/user-attachments/assets/ae92f50b-8465-45c3-9373-ec9d26680d6f" />

Si le champ “hauteur” est disponible, il peut être utilisé pour ajuster la hauteur de vue des bâtiments afin de refléter leurs dimensions réelles.
Dans ce cas précis, nous avons multiplié toutes les valeurs de hauteur par 500 pour obtenir une représentation visuelle plus lisible. Cette opération n’altère pas l’information relative aux hauteurs, mais améliore la perception graphique.

Pour bien afficher les bâtiments, il faut une colonne des “hauteurs” 

***type:*** Extruded

***heigh:*** colonne “hauteur”

***mode:*** sélectionne la couche mnt

***expression*** =0

<img width="602" height="325" alt="1" src="https://github.com/user-attachments/assets/d4a5d33d-50dd-4aa3-bfcf-14df299562fa" />

<img width="602" height="323" alt="2" src="https://github.com/user-attachments/assets/fc5b6e96-be99-4bc7-a276-c0d2b4882305" />

Paramétrer les couches pour offrir une meilleure visualisation

<img width="602" height="392" alt="1" src="https://github.com/user-attachments/assets/54664462-c2f4-4731-ba1c-bd61fc41ef9a" />

<img width="602" height="339" alt="2" src="https://github.com/user-attachments/assets/923c8837-fdd9-4080-98f3-b237102056ea" />

<img width="602" height="339" alt="3" src="https://github.com/user-attachments/assets/e2b7dd1e-9b26-4f04-8089-3448c7b39793" />

<img width="602" height="339" alt="4" src="https://github.com/user-attachments/assets/4035017a-6edb-425d-99eb-08a83204b375" />

<img width="602" height="339" alt="5" src="https://github.com/user-attachments/assets/4bc64635-966c-4127-a6e3-ecec6d1c0116" />

<img width="602" height="339" alt="6" src="https://github.com/user-attachments/assets/e39540ce-a51d-4161-a83a-f741615e8d84" />








