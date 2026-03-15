# **GDAL en pratique sous Ubuntu/WSL**  
---
[**VRT \-- GDAL Virtual Format — GDAL documentation**](https://gdal.org/en/stable/drivers/raster/vrt.html)  
**\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_**  
**NB: Beaucoup de logiciels métiers aujourd’hui utilisent GDAL dont QGIS**

## **Installer GDAL dans Ubuntu / WSL**

**Installation complète (avec outils et drivers) :**
**Shell (plutôt dans Ubuntu)**  
```
sudo apt update  
sudo apt install gdal-bin
```
**Pour Python (optionnel mais utile pour la géomatique) :**  
```
sudo apt install python3-gdal
```
**Vérifier après installation**  
``` 
gdalinfo \--version
```  


## **Test de commande**

**Source:** [PSQL le client de PostgreSQL en mode CLI \[Le « bas niveau » pour alimenter les données\]](https://supports.idgeo.fr/cpgeom/2025-2027/A2_gdal_cli/co/GDAL_psql.html)  

### **Exercice : Le mode CLI**

### **Petites instructions et restitution avec une capture d'écran sur Digiforma**

Ouvrir PowerShell

Utiliser la commande pwd pour vérifier que vous êtes dans le dossier utilisateur de votre machine

Créer un dossier « cli »

Déplacez vous dans le dossier que vous venez de créer

Créer un fichier de type texte nommé exercice\_cli.txt avec une phrase de votre choix. (cf exemple du support de cours)

Renommer le fichier exercice\_cli.txt en exercice\_cli\_initial.txt

Copier le fichier en le nommant exercice\_cli\_copie.txt


**Résolution de l’exercice**  
<img width="728" height="411" alt="5" src="https://github.com/user-attachments/assets/65614c05-d696-4ca7-94ae-4babda33bdaf" />
 
**Code:**  
```
**idgeo@GS8:\~$** pwd  
/home/idgeo  
idgeo@GS8:\~$** mkdir clic  
idgeo@GS8:\~$** cd clic  
idgeo@GS8:\~/clic$** pwd  
/home/idgeo/clic  
idgeo@GS8:\~/clic$** echo "Je fais des tests sur Ubuntu." \> exercice\_cli.txt  
idgeo@GS8:\~/clic$** mv exercice\_cli.txt exercice\_cli\_initial.txt  
idgeo@GS8:\~/clic$** cp exercice\_cli\_initial.txt exercice\_cli\_copie.txt  
idgeo@GS8:\~/clic$** ls \-1
``` 
exercice\_cli\_copie.txt  
exercice\_cli\_initial.txt

**NB:** Si on souhaite se placer dans un dossier personnel: On utilise cd /mnt/+ lien dossier  
Le chemin est très intéressant et surtout par rapport à là ou on se trouve car ça peut varier par rapport à notre placement  
**Exemple:
```
idgeo@GS8:** **\~/clic$** cd /mnt/c/Users/aguene/Downloads/OGR  
idgeo@GS8: /mnt/c/Users/aguene/Downloads/OGR$**
``` 


## **Connection à une base de données PostgreSQL**

<img width="909" height="774" alt="Capture d’écran 2026-03-06 165126" src="https://github.com/user-attachments/assets/e21e9b64-140a-4bc3-ad9b-6c9553d51698" />
  
**Code:**  
– Pour se connecter:  
```
idgeo@GS8:\~/clic$** psql \-h 192.168.10.1 \-p 15432 \-U editeur \-d abdou\_lahat  
Password for user editeur:editeur2026
```
 
En se plaçant dans notre base de données, on peut maintenant faire des scripts SQL comme sur PGAdmin ou DBeaver  
```
abdou\_lahat=\> SELECT \*  
FROM address.adresses\_2026  
LIMIT 5;
```
## **Important:** Tape Ctrl+Z pour sortir de la base de données

### **Attention:** Il faut toujours mettre le point virgule (**;**) à la fin du code SQL



### **Pour télécharger un MNT dans un dossier bien déterminer:**

On se place sur le dossier d’abord avant de faire wget+lien raster  
```
idgeo@GS8: /mnt/d/gdal\_abdou/raster/mnt$** wget [https://data.geopf.fr/telechargement/download/BDALTI/BDALTIV2\_2-0\_25M\_ASC\_LAMB93-IGN69\_D031\_2021-05-12/BDALTIV2\_2-0\_25M\_ASC\_LAMB93-IGN69\_D031\_2021-05-12.7z](https://data.geopf.fr/telechargement/download/BDALTI/BDALTIV2_2-0_25M_ASC_LAMB93-IGN69_D031_2021-05-12/BDALTIV2_2-0_25M_ASC_LAMB93-IGN69_D031_2021-05-12.7z)
```


## **On dézippe le BDALTI:**
```
idgeo@GS8: /mnt/d/gdal\_abdou/raster/mnt$** 7z x BDALTIV2\_2-0\_25M\_ASC\_LAMB93-IGN69\_D031\_2021-05-12.7z
``` 


## **Créer un vrt à partir de nos images.asc**

**NB:** Le chemin est très intéressant et surtout par rapport à là ou on se trouve car ça peut varier par rapport à notre placement  
```
idgeo@GS8: /mnt/d/gdal\_abdou/raster/mnt$** gdalbuildvrt \-srcnodata 0 \-a\_srs EPSG:2154 mnt31.vrt BDALTIV2\_2-0\_25M\_ASC\_LAMB93-IGN69\_D031\_2021-05-12/BDALTIV2/1\_DONNEES\_LIVRAISON\_2021-10-00008/BDALTIV2\_MNT\_25M\_ASC\_LAMB93\_IGN69\_D031/\*.asc
```
Ci-dessus, à partir de BDALTIV2\_2-0\_25M\  etc, c’est le chemin vers les images puisqu’on est dans déjà dans le dossier mnt qui contient BDALTIV2\_2-0\_25M\_ etc  


## **Créer un shapefile à partir d’une autre et avec SQL (where)**
```
idgeo@GS8: /mnt/d/gdal\_abdou/vecteur$** ogr2ogr \-where "INSEE\_DEP='31'" HG.shp DEPARTEMENT.shp
```

### **Exemple 1: Découper un mnt par un shapefile** 
```
idgeo@GS8:** gdalwarp \-overwrite \-cutline vecteur/dept09.shp \-cl dept09 \-crop\_to\_cutline \-of VRT raster/mnt/mnt09.vrt raster/mnt/mnt09\_ariege.vrt
```
### **Exemple 2: Découper un mnt par un shapefile**
```
idgeo@GS8:** gdalwarp \-s\_srs EPSG:2154 \-t\_srs EPSG:2154 \-cutline vecteur/COMMUNE.shp \-cl COMMUNE \-cwhere "INSEE\_COM='31555'" \-crop\_to\_cutline \-overwrite raster/ortho/T31TCJ\_2154.vrt raster/ortho/T31TCJ\_2154\_TOULOUSE.vrt
```


## **Reprojeter en ortho en créant un nouveau fichier vrt avec suppression des nodata (pixel trous)**
```
idgeo@GS8:** gdalwarp \-s\_srs EPSG:3857 \-t\_srs EPSG:2154 \-of VRT \-r near \-dstnodata 99999 ortho/T31TCJ.tif ortho/T31TCJ\_2154.vrt
``` 


## **Créer des courbes de niveau à partir d’un mnt**
```
idgeo@GS8:** **/mnt/d/gdal\_abdou$** gdal\_contour \-a elev \-i 5 raster/mnt/mnt\_TOULOUSE.vrt vecteur/contour\_mnt.shp
```


## **Créer un raster ombrage à partir d’un mnt**
```
idgeo@GS8:** **/mnt/d/gdal\_abdou$** gdaldem hillshade raster/mnt/T31TCJ\_2154\_TOULOUSE.vrt raster/mnt/ombrage.tif
```


## **Colorer un mnt avec un fichier .txt contenant niveau altitude et valeurs couleurs RGB**
```
touch script.sh  
idgeo@GS8:** **/mnt/d/gdal\_abdou$** nano color.txt
```
![][image3]  
première valeur de chaque ligne veut dire altitude et les 3 valeurs suivantes indiques les couleurs RGB  
Ensuite on utilise ce color.txt qui est enregistrer dans le dossier raster pour colorer  
```
idgeo@GS8: /mnt/d/ariege/raster/mnt$** gdaldem color-relief mnt09\_ariege.vrt color09.txt raster/mnt/color\_mnt09.vrt
```


# **DEUXIÈME JOUR**

## **Création de dossier et du fichier de script**
```
idgeo@GS8:** **/mnt/d/gdal\_abdou$** touch script.sh  
idgeo@GS8:** **/mnt/d/gdal\_abdou$** nano script.sh
```
![][image4]  


## **Connexion à la base de données et chargement de la couche hg.shp**
```
idgeo@GS8:** **/mnt/d/gdal\_abdou$** ogr2ogr \-f "PostgreSQL" PG:"dbname=abdou\_lahat user=editeur password=editeur2026 host=  
192.168.10.1 port=15432" \-nln hg \-s\_srs EPSG:2154 \-t\_srs EPSG:2154 vecteur/HG.shp
```


## **Charger une couche dans ma base de données depuis un url WFS de la géoplateforme (geoservices)**
```
idgeo@GS8: /mnt/d/gdal\_abdou$** ogr2ogr \-of "PostgreSQL" PG:"dbname=abdou\_lahat user=editeu  
r password=editeur2026 host=  
192.168.10.1 port=15432" \-nln public.dept.09 \-s\_srs EPSG:4326 \-t\_srs EPSG:2154 WFS:https  
://data.geopf.fr/wfs/ows?VERSION=2.0.0 BDTOPO\_V3:departement \-where "code\_insee='09'"
```


## **Pour automatiser toutes ses tâches**

On crée ce dossier “ariege” avec ces contenus dedans: [Pour automatiser les taches \- Google Drive](https://drive.google.com/drive/u/0/folders/1qwZU_qZD9Wuy6a0WfoxqNx0nXd9Jrw3H)**  
Ensuite, rends le script exécutable et lance-le  
```
idgeo@GS8:/mnt/d/ariege$** chmod \+x mon\_dossier/script.sh && ./mon\_dossier/[script.sh](http://script.sh)
```
**NB:** Si vous vous exécutez ça dans une autre machine, il faudra dans ta terminal se placer sur **idgeo@GS8: /mnt/d/ariege$**  (si vous êtes sur Ubuntu)  
Et il faut aussi adapter les chemins dans le fichier [script.sh](http://script.sh)

**Important:** la solution de Olivier ([olivier\_ariege](https://drive.google.com/drive/u/0/folders/1qwZU_qZD9Wuy6a0WfoxqNx0nXd9Jrw3H)) est plus intéressant aussi, il te demande le numero departement et ensuite le lien du mnt dans geoservice  
Préalable:  Il faut placer le fichier de Olivier dans “**mon\_dossier**” et le renommé “**script.sh**”  
**Remarque:** Pour que ça fonctionne mieux encore et pour tous les départements, remplace le “polygon” dans [olivier\_ariege](https://drive.google.com/drive/u/0/folders/1qwZU_qZD9Wuy6a0WfoxqNx0nXd9Jrw3H) par “multipolygon”


