#  Fiche complète PostgreSQL / PostGIS 
---
[🔗 Documentation officielle PostgreSQL](https://www.postgresql.org/docs/)  

##  1. Fonctions PostGIS dans SELECT et JOIN
  Fonctions dans **SELECT**
- ST_Buffer
- ST_Difference
- ST_Transform
- ST_Intersection
  Fonctions dans **JOIN / WHERE**
- ST_Intersects
- ST_Contains
- ST_Within
- ST_DWithin
##  2. Géotraitements
 2.1 Intersection (Découpe)
```sql
WITH req AS (
   SELECT sitecode, sitename,
          st_collectionextract(
               st_multi(st_intersection(r.geom, z.geom)), 3
          )::geometry(Multipolygon, 2154) AS geom_inter
   FROM public.zps AS z
   JOIN public.regions AS r ON st_intersects(r.geom, z.geom)
   WHERE r.code_reg = '72'
),
req_1 AS (
   SELECT sitecode, sitename,
          st_area(geom_inter) / 1000000 AS surface_km2
   FROM req
)
SELECT SUM(surface_km2) AS total_surface_km2
FROM req_1;
```
### 2.2 Différence + Buffer
```sql
WITH req AS (
   SELECT ST_Union(ST_Buffer(pav.geom, 500)) AS buffered_union
   FROM public.pav
)
SELECT commune.geom AS commune_geom,
       ST_Difference(commune.geom, req.buffered_union) AS zone_non_couverte
FROM public.communes_france AS commune, req
WHERE ST_Intersects(commune.geom, req.buffered_union);
```
### 2.3 ST_Distance (condition)
```sql
SELECT DISTINCT e.id, p.commune, p.code_postal,
       st_distance(e.geom, p.geom) AS distance
FROM public.pav p
JOIN public.ecole_elem_matern e
     ON st_distance(e.geom, p.geom) <= 100
GROUP BY e.id, p.commune, p.code_postal, e.geom, p.geom
ORDER BY distance ASC
LIMIT 5;
```
##  3. GROUP BY
```sql
WITH req AS (
   SELECT DISTINCT e.id, p.commune, p.code_postal, p.type_flux,
          st_distance(e.geom, p.geom) AS distance
   FROM public.pav p
   JOIN public.ecole_elem_matern e
       ON st_distance(e.geom, p.geom) <= 50
   WHERE p.type_flux = 'textile'
)
SELECT req.type_flux, COUNT(req.id)
FROM req
GROUP BY req.type_flux;
```
##  4. JOIN Avancés
### 4.1 ON TRUE
```sql
SELECT DISTINCT ON (e.id)
       e.id AS ecole_id, p.id AS pav_id,
       p.commune, p.code_postal,
       ST_Distance(e.geom, p.geom) AS distance
FROM public.pav p
JOIN public.ecole_elem_matern e
     ON TRUE
ORDER BY e.id, distance ASC;
```
### 4.2 ST_DWithin
```sql
WITH req AS (
   SELECT COUNT(DISTINCT e.id) AS ecole_textile
   FROM public.pav p
   JOIN public.ecole_elem_matern e
       ON ST_DWithin(e.geom, p.geom, 50)
   WHERE p.type_flux ILIKE '%textile%'
)
SELECT
   (SELECT COUNT(*) FROM public.ecole_elem_matern) - req.ecole_textile AS ecoles_sans_pav_textile,
   req.ecole_textile AS ecoles_avec_pav_textile
FROM req;
```
##  5. ST_Intersects vs ST_Intersection
| Fonction | Rôle |
|---------|------|
| ST_Intersects() | Vrai/Faux |
| ST_Intersection() | Zone commune (géométrie) |

```sql
SELECT SUM(ST_length(st_intersection(t1.geom, t2.geom))) / 1000 AS length_km
FROM public.filaire_de_voirie t1
JOIN public.jour_collect t2
   ON ST_Intersects(t1.geom, t2.geom);
```
##  6. Découper un linéaire par département
```sql
SELECT d.code_insee, d.nom AS departement, c.nomentiteh AS cours_eau,
       ST_Intersection(c.geom, d.geom) AS segment_geom
FROM departement.departements d
JOIN carthage.cours c
   ON c.nomentiteh = 'La Garonne'
WHERE ST_Intersects(c.geom, d.geom)
  AND NOT ST_IsEmpty(ST_Intersection(c.geom, d.geom));
```
##  7. Distance depuis un point
```sql
WITH req AS (
   SELECT commune,
          ST_Distance(geom, ST_GeomFromText('POINT(574103 6279386)', 2154)) AS distance
   FROM public.pav
   WHERE commune = 'Toulouse'
   ORDER BY distance ASC
)
SELECT AVG(distance) AS average_distance
FROM req;
```
##  8. Droits / Rôles / Groupes

### Création d’un rôle
```sql
CREATE ROLE Lea LOGIN PASSWORD 'toto';
GRANT SELECT (fid, geom), UPDATE (geom)
ON TABLE cadastre_tlse.parcelles, cadastre_tlse.batiments
TO Lea;
```
### Création de groupes
```sql
CREATE ROLE gr_visu;
CREATE ROLE gr_gestion_parcelles;
CREATE ROLE gr_gestion_batiments;
CREATE ROLE gr_dessin_cadastre;
CREATE ROLE gr_maj_type_bati;
```
### Affectation
```sql
GRANT SELECT ON ALL TABLES IN SCHEMA cadastre_tlse TO gr_visu;
GRANT SELECT,INSERT,UPDATE,DELETE ON cadastre_tlse.parcelles TO gr_gestion_parcelles;
GRANT UPDATE (geom) ON cadastre_tlse.parcelles TO gr_dessin_cadastre;
```
### Les privilèges (GRANT)
### Définition
Un privilège est un droit sur un objet de la base attribué à un rôle.
Les SGBD permettent généralement de spécifier assez finement les privilèges d'un utilisateur en fonction des objets manipulés :
base de données
schéma
table (relation)
colonne (attribut)
Ainsi, un utilisateur peut se voir attribuer un privilège pour toute une base de données, le contenu d'un schéma, ou seulement pour quelques tables, ou encore sur uniquement quelques colonnes de certaines tables.
### Fondamental
### Règles d'attribution des privilèges
### Règle n°0 : un mot de passe pour chacun
Tous les utilisateurs (clients, applications) doivent avoir un mot de passe.
### Règle n°1 : attribution du moindre privilège.
Les utilisateurs ne doivent avoir que le minimum de droits, ceux strictement nécessaires à l'accomplissement de leurs tâches. Les privilèges peuvent évoluer au cours du temps car les besoins et les tâches affectées ne sont pas immuables, mais à un moment donné, seuls les droits indispensables doivent être fournis à un utilisateur.
Il faut éviter de créer plusieurs comptes avec des droits d'administrateur.
### Règle n°2 : contrôle de la population.
Le personnel d'une entreprise bouge, il y a des départs, des arrivées, des promotions... Les privilèges doivent êtres synchrones avec la réalité de la population : il faut supprimer les comptes des utilisateurs quittant l'entreprise et de ceux n'étant plus affectés à telle ou telle tâche.
### Règle n°3 : supervision de la délégation des tâches d'administration.
Un administrateur peut être amené à déléguer auprès d'une autre personne les tâches d'attribution des privilèges de tout ou partie de la population des utilisateurs (cf WITH GRANT OPTION). Un contrôle a posteriori doit être réalisé afin de vérifier que le résultat de cette délégation est conforme à la politique adoptée.
### Règle n°4 : contrôle physique des connexions.
La connexion d'un utilisateur à une base de données peut être réalisée depuis n'importe où dans le monde grâce à Internet. Il est nécessaire de restreindre les connexions à des hôtes spécifiques connus (hba_conf).
Les principaux privilèges :
Les droits possibles sont :
### SELECT
Autorise une sélection sur toutes les colonnes, ou sur les colonnes listées spécifiquement, de la table, vue ou séquence indiquée. Autorise aussi l'utilisation de COPY TO. De plus, ce droit est nécessaire pour référencer des valeurs de colonnes existantes avec UPDATE ou DELETE.
### INSERT
Autorise une insertion d'une nouvelle ligne dans la table indiquée. Si des colonnes spécifiques sont listées, seules ces colonnes peuvent être affectées dans une commande INSERT, (les autres colonnes recevront par conséquent des valeurs par défaut). Autorise aussi COPY FROM.
### UPDATE
Autorise une mise à jour sur toute colonne de la table spécifiée, ou sur les colonnes spécifiquement listées. (En fait, toute commande UPDATE nécessite aussi le droit SELECT car elle doit référencer les colonnes pour déterminer les lignes à mettre à jour et/ou calculer les nouvelles valeurs des colonnes.)
### DELETE
Autorise la suppression d'une ligne sur la table indiquée. (En fait, toute commande DELETE nécessite aussi le droit SELECT car elle doit référencer les colonnes pour déterminer les lignes à supprimer.)
### TRUNCATE
Autorise la suppression de tous les enregistrements de la table.
### REFERENCES
Ce droit est requis sur les colonnes de référence et les colonnes qui référencent pour créer une contrainte de clé étrangère. Le droit peut être accordé pour toutes les colonnes, ou seulement des colonnes spécifiques.
### TRIGGER
Autorise la création d'un déclencheur sur la table indiquée.
### CREATE
Pour les bases de données, autorise la création de nouveaux schémas dans la base de données.
Pour les schémas, autorise la création de nouveaux objets dans le schéma. Pour renommer un objet existant, il est nécessaire d'en être le propriétaire et de posséder ce droit sur le schéma qui le contient.
Pour les tablespaces, autorise la création de tables, d'index et de fichiers temporaires dans le tablespace et autorise la création de bases de données utilisant ce tablespace par défaut. (Révoquer ce privilège ne modifie pas l'emplacement des objets existants.)
### CONNECT
Autorise l'utilisateur à se connecter à la base indiquée. Ce droit est vérifié à la connexion (en plus de la vérification des restrictions imposées par pg_hba.conf).
### TEMPORARY, TEMP
Autorise la création de tables temporaires lors de l'utilisation de la base de données spécifiée.
### EXECUTE
Autorise l'utilisation de la fonction indiquée et l'utilisation de tout opérateur défini sur cette fonction. C'est le seul type de droit applicable aux fonctions. (Cette syntaxe fonctionne aussi pour les fonctions d'agrégat)
### ALL PRIVILEGES
Octroie tous les droits disponibles en une seule opération. Le mot clé PRIVILEGES est optionnel sous PostgreSQL™ mais est requis dans le standard SQL.
### La commande SQL GRANT permet de définir les droits :
syntaxe générale : 
```sql
GRANT { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }
    [, ...] | ALL [ PRIVILEGES ] }
    ON { [ TABLE ] table_name [, ...]
         | ALL TABLES IN SCHEMA schema_name [, ...] }
    TO role_specification [, ...] [ WITH GRANT OPTION ]
```
### accorder des privilèges sur une colonne :
```sql
GRANT { { SELECT | INSERT | UPDATE | REFERENCES } ( column_name [, ...] )
    [, ...] | ALL [ PRIVILEGES ] ( column_name [, ...] ) }
    ON [ TABLE ] table_name [, ...]
    TO role_specification [, ...] [ WITH GRANT OPTION ]
```
L'aide sur la syntaxe SQL
L'annulation d'un privilège (révocation)
La commande REVOKE enlève un ou plusieurs privilèges à un utilisateur.
```sql
REVOKE [ GRANT OPTION FOR ]
    { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }
    [, ...] | ALL [ PRIVILEGES ] }
    ON { [ TABLE ] table_name [, ...]
         | ALL TABLES IN SCHEMA schema_name [, ...] }
    FROM { [ GROUP ] role_name | PUBLIC } [, ...]
    [ CASCADE | RESTRICT ]
```
GRANT OPTION FOR : seule l'option d'attribution du privilège est révoquée, pas le privilège lui-même ;
FROM PUBLIC : tous les utilisateurs dont les privilèges ont été attribués avec le mot clé PUBLIC (voir GRANT)
--L'utilisateur ne devant que consulter les tables, on définit le droit de 
--sélection dans les tables avec GRANT SELECT 
--(dans la fenêtre requête SQL) :
```sql
GRANT SELECT ON TABLE parcelles TO utilisateur;
GRANT SELECT ON TABLE proprio TO utilisateur;
--Définir les droits en lecture-écriture
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE parcelles TO operateur_saisie ;
```
##  9. UPDATE, CAST, ROUND
```sql
UPDATE public.regions
SET perimetre_km = ROUND(st_perimeter(geom) / 1000 :: numeric, 2);
```
##  10. Import Shapefile (GDAL)
```
ogr2ogr -f "PostgreSQL" PG:"dbname=GDAL user=postgres password=XXX host=localhost port=5434" "C:\path\REGION.shp" -nln regions -nlt MULTIPOLYGON
```
##  11. ST_Transform
```sql
CREATE TABLE table_reproj AS
SELECT ST_Transform(geom, 4326) AS geom, *
FROM table_originale;
```
##  12. INSERT INTO
```sql
INSERT INTO public.etat (type)
VALUES ('sain'), ('malade'), ('casse'), ('mort');
```
##  13. CREATE TABLE
```sql
CREATE TABLE arbre (
   id_arbre int generated always as IDENTITY PRIMARY KEY,
   diametre real,
   hauteur real,
   geom geometry(point,2154)
);
```
##  14. Import CSV + mise à jour des géométries
```sql
COPY faune_auvergne_temp
FROM 'C:\...aune.csv'
CSV HEADER DELIMITER ';';
```
Ajouter une colonne :
```sql
ALTER TABLE public.faune_auvergne_temp
ADD column geom geometry(point,2154);
```
Mettre à jour :
```sql
UPDATE public.faune_auvergne_temp f
SET geom = (
   SELECT geom
   FROM public.faune_auvergne t
   WHERE t.id = f.id_num
)
WHERE EXISTS (
   SELECT 1
   FROM public.faune_auvergne t
   WHERE t.id = f.id_num
);
```
##  15. Dates disponibles (generate_series)
```sql
SELECT jour
FROM generate_series(
   '2025-03-01'::date,
   '2025-03-31'::date,
   '1 day'::interval
) AS jour
WHERE jour NOT IN (
   SELECT date_location::date
   FROM louer
   WHERE id_salle = '3'
     AND EXTRACT(YEAR FROM date_location) = 2025
     AND EXTRACT(MONTH FROM date_location) = 3
);
```
##  16. Triggers
### Date automatique
```sql
CREATE OR REPLACE FUNCTION fn_set_date_creation()
RETURNS trigger AS $$
BEGIN
   NEW.date_creation := NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_date_creation
BEFORE INSERT ON public.test_mobilier
FOR EACH ROW
EXECUTE FUNCTION fn_set_date_creation();
```
### Surface automatique
```sql
CREATE OR REPLACE FUNCTION update_area()
RETURNS TRIGGER AS $$
BEGIN
   NEW.surface_m2 := ST_Area(NEW.geom);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_update_area
BEFORE INSERT OR UPDATE ON zones
FOR EACH ROW
EXECUTE FUNCTION update_area();
```
##  17. INDEX
```sql
CREATE INDEX idx_parcel_numpar_c10436
ON village.parcel (numpar)
WHERE numpar ILIKE 'c10436';
```
##  18. Pour connaitre la taille des tables
```sql
SELECT relname as "Table",pg_size_pretty(pg_total_relation_size(relid)) As "Size",
pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as "External Size"
FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC;
```
## 19. Sauvegarder et restaurer les données de postgreSQL en ligne de commande
### Sauver
### Sur pgAdmin 4, pour sauvegarder, on fait clic droit + Backup... 
### Et pour restorer avec ce fichier Back up, on fait clic droit + restore...
Ainsi après restore, ça recrée absolument tout (schémas, tables avec colonnes y compris geom etc.)
### Objectif : produire un fichier texte de commandes SQL (« fichier dump »), qui, si on le renvoie au serveur, recrée une base de données identique à celle sauvegardée.
PostgreSQL™ propose pour cela le programme utilitaire pg_dump.
```
pg_dump base_de_donnees > fichier_sauvegarde
```
### 1- Exemple : On fait le sauvegarde en fichier sql dans le dossier idgeo@GS8:~$  (home/idgeo)
```
idgeo@GS8:~$ pg_dump -f rugby_sauv.sql -d rugby_top -p 5432 -U postgrres
```
### 2- Exemple pour restaurer : On crée ici une base vide dans laquelle on va restaurer le backup
```
idgeo@GS8:~$ psql postgres postgres -p 5432 -c "CREATE DATABASE idgeo_locale";
```
### 3- Exemple pour restaurer : On restaure le fichier qu'on avait sauvegarder
```
psql -U postgres -p 5432 -d idgeo_locale < sauv_idgeo.sql
```
### 4- Exemple : On se reconnecte à la base de données en question
```
psql -U postgres -p 5432 -d idgeo_locale
```
Les extractions peuvent être réalisées sous la forme de scripts ou de fichiers d'archive.
Les scripts sont au format texte et contiennent les commandes SQL nécessaires à la reconstruction de la base de données dans l'état où elle était au moment de la sauvegarde. La restauration s'effectue en chargeant ces scripts avec psql.
La reconstruction de la base de données à partir d'autres formats de fichiers archive est obtenue avec pg_restore. Les formats de fichier en sortie les plus flexibles sont le format « custom » (-Fc) et le format « directory » (-Fd). Ils permettent la sélection et le ré-ordonnancement de tous les éléments archivés, le support de la restauration en parallèle. De plus, ils sont compressés par défaut. Le format « directory » est aussi le seul format à permettre les sauvegardes parallélisées.
### Remarque
pg_dump permet de restaurer des bases dans des versions du serveur plus récentes.
pg_dump est aussi la seule méthode qui fonctionnera lors du transfert d'une base de données vers une machine d'une architecture différente (comme par exemple d'un serveur 32 bits à un serveur 64 bits).
### Restaurer
Les fichiers texte créés par pg_dump peuvent être lus par le programme psql.
```
psql base_de_donnees < fichier_sauvegarde
```
### Remarque
Tous les utilisateurs possédant des objets ou ayant certains droits sur les objets de la base sauvegardée doivent exister préalablement à la restauration de la sauvegarde. S'ils n'existent pas, la restauration échoue pour la création des objets dont ils sont propriétaires ou sur lesquels ils ont des droits.
### Sauvegarder une base directement d'un serveur sur un autre
```
pg_dump -h serveur1 base_de_donnees | psql -h serveur2 base_de_donnees
```
### Conseil
Après la restauration d'une sauvegarde, il est conseillé d'exécuter ANALYZE sur chaque base de données pour que l'optimiseur de requêtes dispose de statistiques utiles.
### Utilisation de pg_dumpall
Permet une sauvegarde de tout un cluster (bases de données, rôles et tablespaces).
```
pg_dumpall > fichier_sauvegarde
```
Le fichier de sauvegarde résultant peut être restauré avec psql :
```
psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE nombase;"
psql -h localhost -p 5432 -U postgres -d nombase -c "CREATE EXTENSION postgis;"
psql -h localhost -p 5432 -U utilisateur -d nombase -f chemin\complet\du\fichier.sql
```
### Remarque
Il est préférable d'avoir les droits de superutilisateur de la base de données pour obtenir une sauvegarde complète.
Il faut obligatoirement avoir le profil superutilisateur pour restaurer une sauvegarde faite avec pg_dumpall, afin de pouvoir restaurer les informations sur les rôles et les tablespaces. Si les tablespaces sont utilisés, il faut s'assurer que leurs chemins sauvegardés sont appropriés à la nouvelle installation.
### Mettre en place une sauvegarde automatique
Encore une fois, suivant la taille de la structure des sauvegardes peuvent intervenir à plusieurs niveau.
Bien souvent, il existe une sauvegarde du serveur qui héberge le serveur PostgreSQL.
On peut mettre une sauvegarde au niveau d'une base de données en choisissant le rythme adéquat (mise à jour des données régulière, vs modèles peu évolutif)
### Exemple Script + crontab
Etablir une commande pg_dump dans un script bash vers une sortie « .dump »
Ce fichier pour s'appeler
On positionnera ce script dans le dossier /usr/bin/
```
DB_USER="postgres"         	# utilisateur de la base de données PostgreSQL
DB_NAME="ma_base"      	    # nom de la base de données à sauvegarder
DB_SCHEMA="pourquoi_pas"    # pour ne sauver que le schéma
current_date=$(date +%Y-%m-%d)
backup_file="/home/xxx/sauv_bdd/sauv_${DB_NAME}${DB_SCHEMA}${current_date}.dump"
```

```
if ! pg_dump -U "$DB_USER" -F c "$DB_NAME" -n "$DB_SCHEMA" > "$backup_file"; then
echo "Echec: La sauvegarde de la bdd a échouée"
return 1
fi
printf "Sauvegarde de la base ok"
```
Paramétrer une tâche « Crontab »
```
crontab -e
```

```
# m h  dom mon dow   command
20 * * * * /usr/bin/script_sauv.sh
```
### Comment régler le crontab ?
https://www.linuxtricks.fr/wiki/cron-et-crontab-le-planificateur-de-taches
```
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  *  user command to be executed
```
### Exemple d'une souvegarde automatique avec Ubuntu (Terminal)
On crée le fichier avec :
```
idgeo@GS8:~$ nano script_sauv_bdd.sh
```
En créant le fichier, ça s'ouvre et on met dedans: 
```
#!/bin/bash
pg_dump -f sauv_bdd_auto.sql -U postgres -p 5432 -d idgeo_locale
```
On rend le script executable avec:
```
idgeo@GS8:~$ chmod a+x script_sauv_bdd.sh
```
Ensuite on fait: 
```
idgeo@GS8:~$ crontab -e
```
Et si ouvert on écrit ça par exemple
```
58 * * * * /home/idgeo/script_sauv_bdd.sh
```
Puis tape ctrl + X (pas ctrl + O ou Entrée) et attendre, on a mise 58 car on est à 16h56 et à 16h58 ça s'execute pour enregistrer un fichier: sauv_bdd_auto.sql
## 20. Connexions distantes
Foreign Data Wrappers
Le FDW (Foreign Data Wrapper) natif de PostgreSQL postgres_fdw permet d'accéder aux tables à partir de serveurs PostgreSQL distants de manière très transparente.
Le FDW standard PostgreSQL permet également à la géométrie PostGIS de passer des hôtes distants aux hôtes locaux, ce qui est très pratique.
Données externes présentées comme des tables ;
En lecture/écriture (si supporté par le driver et à partir de PostgreSQL 9.3) :
PostgreSQL, Oracle, MySQL (lecture/écriture)
fichier CSV, fichier fixe (en lecture)
ODBC, JDBC, Multicorn
CouchDB, Redis (NoSQL)
```sql
--création d'un lien vers la base de données bd_test_postgis
CREATE SERVER foreign_bd
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (host 'localhost', port '5434', dbname 'bd_test_postgis');
--associer un utilisateur de la base de données distant à un utilisateur en local
CREATE USER MAPPING FOR postgres --utilisateur local
        SERVER foreign_bd
        OPTIONS (user 'postgres', password 'postgres'); --utilisateur distant
--création d'un table ayant la même structure que la table distante		
CREATE FOREIGN TABLE foreign_parkings (
    osm_id integer NOT NULL,
    date_heure timestamp without time zone,
    nom character varying ,
    type_obj character varying,
    xcoord double precision,
    ycoord double precision,
    geom geometry(Point,2154)
)
    SERVER foreign_bd
        OPTIONS (schema_name 'parkings', table_name 't_parking');
select * from foreign_parkings;
```
### Conseil
L'accès aux données des tables étrangères est plus lent et donc réservées à des accès intermittents (impossible de créer un index sur une table étrangère).
Il peut être pertinent d'encapsuler les tables distantes dans des vues matérialisées qui stockent les données en local.
Un FDW sur un WFS
Jouons avec les données de l'INPN => http://ws.carmencarto.fr/WFS/119/fxx_inpn
### Extension
En pré-requis, il faut que l'extension soit ajoutée (ça tombe bien nous l'avions prévue dans notre template).
```sql
CREATE EXTENSION IF NOT EXISTS ogr_fdw;
```
Vous pouvez aussi rajouter les extensions: postgres_fdw et file_fdw
Création du serveur
```sql
DROP SERVER IF EXISTS fdw_ogr_inpn_metropole;
```
```sql
CREATE SERVER fdw_ogr_inpn_metropole
FOREIGN DATA WRAPPER ogr_fdwOPTIONS (
datasource 'WFS:http://ws.carmencarto.fr/WFS/119/fxx_inpn?',
format 'WFS'
);
```
### Création d'un schéma dédié
```sql
CREATE SCHEMA IF NOT EXISTS inpn_metropole;
```
Récupération de l'ensemble des couches WFS comme des tables dans le schéma inpn_metropole
```sql
IMPORT FOREIGN SCHEMA ogr_all
FROM SERVER fdw_ogr_inpn_metropoleINTO inpn_metropoleOPTIONS (
-- mettre le nom des tables en minuscule et sans caractères bizarres
launder_table_names 'true',
-- mettre le nom des champs en minuscule
launder_column_names 'true');
```


