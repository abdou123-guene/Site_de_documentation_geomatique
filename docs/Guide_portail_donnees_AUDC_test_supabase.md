# Guide de réalisation : portail de données de l’AUDC (version test Supabase + Render)

> **🔗 Interface en ligne : <https://audc-portail-donnees-supabase.onrender.com>**
>
> Dépôt GitHub : <https://github.com/abdou123-guene/audc-portail-donnees_supabase>

| Élément | Détail |
| --- | --- |
| **Version** | 1.1 – 26 novembre 2026 (adaptation du guide 1.0) |
| **Statut** | Version de test : données issues d’une base Supabase personnelle, sans valeur officielle |
| **Public** | Gestionnaire du portail et personnes qui le maintiendront |
| **Point de départ** | Une base Supabase avec PostGIS et un schéma `geo_standards` contenant des vues |
| **Résultat** | Un site web statique avec carte, tableau, téléchargements (CSV, GeoJSON, GeoPackage) et dictionnaire des données, publié sur Render |
| **Outils nécessaires** | Un navigateur et trois comptes (GitHub, Render, Supabase). Aucun terminal, aucune installation locale |

---

## 1. Objectif

Plutôt que d’envoyer des fichiers à chaque demande, on publie un petit site qui présente les données et permet de les télécharger. Ce guide décrit comment le site de test a été construit et comment le faire évoluer. À la différence du guide initial (base 3liz, indicateurs par commune), **toutes les vues du schéma sont publiées automatiquement**, quelle que soit leur géométrie (lignes, points ou polygones).

| Élément du site | Ce qu’il fait |
| --- | --- |
| **En-tête et menu** | Logo, titre, navigation Carte, Données, Dictionnaire, À propos |
| **Filtres** | Choix de la vue, de la colonne à représenter, du millésime et du schéma |
| **Carte** | Objets colorés selon la colonne choisie (lignes, points ou polygones), infobulle et légende |
| **Tableau** | Valeurs de la vue, triées sur la colonne sélectionnée (500 premières lignes affichées) |
| **Téléchargements** | CSV, GeoJSON et GeoPackage de la vue affichée |
| **Dictionnaire** | Liste des colonnes de chaque vue, avec source et millésime |
| **Pied de page** | Licence, date de dernière mise à jour, contact |

## 2. Architecture

```
Supabase (PostGIS)  →  build Render  →  site statique (dossier docs/)
 schéma geo_standards    export_donnees.py       carte, tableau, fichiers
```

1. À chaque déploiement, Render installe Python et ses bibliothèques, puis lance `scripts/export_donnees.py`.
2. Ce script se connecte à Supabase, découvre les vues du schéma et écrit pour chacune un GeoJSON, un CSV et un GeoPackage dans `docs/data/`, plus un `catalogue.json`.
3. Render publie le dossier `docs/`. Les visiteurs ne se connectent jamais à la base : ils ne lisent que des fichiers.

| Composant | Rôle |
| --- | --- |
| **Vues PostGIS (schéma `geo_standards`)** | Contiennent les données à diffuser |
| **`scripts/export_donnees.py`** | Lit les vues et écrit les fichiers et le catalogue |
| **`docs/data/catalogue.json`** | Décrit les jeux disponibles : le site s’en sert pour ses filtres et son dictionnaire |
| **`scripts/verifier_exports.py`** | Contrôle les fichiers avant publication (colonnes interdites, taille) |
| **Dépôt GitHub** | Conserve le code et l’historique |
| **Render (Static Site)** | Lance l’export puis publie `docs/` |
| **Leaflet** | Bibliothèque libre d’affichage de cartes |

### Ce qui change par rapport au guide initial

| Sujet | Guide initial | Version test |
| --- | --- | --- |
| Base de données | PostGIS hébergée chez 3liz | Supabase |
| Publication | GitHub Pages | Render (Static Site) |
| Lancement de l’export | Depuis un poste, à la main | Automatique, pendant le build Render |
| Choix des données | Vues déclarées une par une dans `indicateurs.yml` | Toutes les vues du schéma, découvertes automatiquement |
| Fichiers de données | Versionnés dans GitHub | Générés à chaque déploiement, absents du dépôt |
| Travail | Terminal, Git, Python en local | Interface web de GitHub et de Render |

## 3. Prérequis

- Un compte **GitHub** (avec authentification à deux facteurs) et un dépôt.
- Un compte **Render**, relié à GitHub.
- Un projet **Supabase** avec l’extension PostGIS et le schéma à publier.
- Chaque vue doit avoir une colonne de géométrie nommée **`geom`** et une colonne **`id`**.

## 4. Préparer la base Supabase

### 4.1 Conventions pour les vues

| Règle | Détail |
| --- | --- |
| **Schéma** | `geo_standards` (modifiable dans `config/indicateurs.yml`) |
| **Géométrie** | Colonne `geom`. Le SRID est lu dans la vue (EPSG:3943 pour ce test). Le GeoPackage garde la projection d’origine, le GeoJSON est reprojeté en WGS84 pour la carte |
| **Identifiant** | Colonne `id` (entier). **Une vue sans `id` est ignorée** lors de l’export |
| **Colonnes** | Toutes les colonnes de la vue sont publiées, sauf celles exclues dans la configuration. Aucune donnée personnelle |
| **Vues matérialisées** | Publiées aussi (option `inclure_vues_materialisees`) |

### 4.2 Paramètres de connexion

Dans Supabase, cliquer sur **Connect** puis **Session pooler**. La chaîne affichée a cette forme :

```
postgres://postgres.<ref>:[MOT-DE-PASSE]@aws-0-<region>.pooler.supabase.com:5432/postgres
```

| Variable | Valeur |
| --- | --- |
| `PGHOST` | `aws-0-<region>.pooler.supabase.com` (ce qui suit le `@`, jusqu’à `:5432`) |
| `PGPORT` | `5432` |
| `PGDATABASE` | `postgres` |
| `PGUSER` | `postgres.<ref>` (le `.<ref>` est obligatoire avec le pooler) |
| `PGPASSWORD` | Mot de passe de la **base** (pas une clé API) |
| `PGSSLMODE` | `require` |

Le pooler fonctionne en IPv4. La connexion directe (`db.<ref>.supabase.co`) est en IPv6 seulement et peut échouer depuis certains environnements.

### 4.3 Compte de lecture seule (recommandé)

Pour ne pas utiliser le compte administrateur, exécuter dans Supabase (SQL Editor) le script `site/sql/supabase_lecture_seule.sql` :

```sql
CREATE ROLE partage_ro LOGIN PASSWORD 'CHANGER_CE_MOT_DE_PASSE';
GRANT USAGE ON SCHEMA geo_standards TO partage_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA geo_standards TO partage_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA geo_standards GRANT SELECT ON TABLES TO partage_ro;
GRANT USAGE ON SCHEMA extensions TO partage_ro;
```

Avec ce compte, `PGUSER` devient `partage_ro.<ref>`.

## 5. Le dépôt GitHub

Arborescence du dépôt de test :

```
audc-portail-donnees_supabase/
├── requirements.txt          bibliothèques Python
├── .gitignore                ignore .env, .venv, etc.
├── .env.example              modèle des variables (sans secret)
├── README.md
└── site/
    ├── config/indicateurs.yml
    ├── scripts/export_donnees.py
    ├── scripts/verifier_exports.py
    ├── sql/supabase_lecture_seule.sql
    └── docs/                  dossier publié
        ├── index.html
        ├── .nojekyll
        └── assets/ (css, js, img, vendor/leaflet)
```

Les fichiers peuvent être envoyés avec **Add file → Upload files**. Pour créer un dossier, taper son nom suivi de `/` dans le nom du fichier.

**Ne jamais créer ni envoyer de fichier `.env`** : les identifiants se saisissent dans Render (partie 7).

## 6. Configuration : `site/config/indicateurs.yml`

```yaml
site:
  titre: "Portail de données partagées"
  organisme: "Agence d’urbanisme de Châlons-en-Champagne"
  contact: "[adresse e-mail]"
  licence: "[À PRÉCISER]"
  fond_osm: true        # false : aucun fond de carte
  maquette: true        # true : bandeau « version de test »

source:
  schema: geo_standards
  inclure_vues_materialisees: true
  exclure_vues: []                   # vues à ne pas publier
  colonne_geometrie: geom
  colonne_id: id
  srid_defaut: 3943                  # utilisé seulement si la vue n'indique pas son SRID
  simplification_m: 0                # simplification pour le web (unités de la projection) ; 0 = aucune
  source_defaut: "Base Supabase de test, schéma geo_standards"
  colonnes_exclues: []               # colonnes à ne jamais exporter
  exiger_id: true                    # true : les vues sans id sont ignorées
  tolerer_echecs: true               # true : une vue en échec n'empêche pas les autres
```

Réglages facultatifs **par vue** (clé = nom exact de la vue) :

```yaml
vues:
  v_troncon_pgrouting_conforme:
    libelle: "Tronçons pgRouting conformes"
    source: "Données de test"
    simplification_m: 1
    colonnes_exclues: [source, target]
    indicateurs: [pente_absolue, longueur]   # colonnes proposées pour colorer la carte
    definitions: {pente_absolue: "Pente en valeur absolue."}
```

## 7. Déploiement sur Render

Sur render.com : **New → Static Site**, choisir le dépôt (s’il n’apparaît pas, autoriser Render sur ce dépôt via **Credentials**, ou utiliser l’onglet *Public Git Repository*).

| Champ | Valeur |
| --- | --- |
| **Name** | `audc-portail-donnees_supabase` (détermine l’adresse du site) |
| **Branch** | `main` |
| **Root Directory** | `site` |
| **Build Command** | `pip install -r ../requirements.txt && python scripts/export_donnees.py && python scripts/verifier_exports.py` |
| **Publish Directory** | `docs` |

Le `../` devant `requirements.txt` est nécessaire parce que ce fichier est à la racine du dépôt alors que Render travaille depuis `site`. Si `requirements.txt` est déplacé dans `site/`, retirer le `../`.

**Variables d’environnement** (section *Advanced*, ou *Environment* après création), sans guillemets :

| Clé | Valeur |
| --- | --- |
| `PGHOST` | adresse du pooler Supabase |
| `PGPORT` | `5432` |
| `PGDATABASE` | `postgres` |
| `PGUSER` | `postgres.<ref>` ou `partage_ro.<ref>` |
| `PGPASSWORD` | mot de passe de la base |
| `PGSSLMODE` | `require` |
| `PYTHON_VERSION` | `3.12.3` |

Cliquer sur **Create Static Site**. Le premier déploiement dure environ une minute. L’adresse (`https://….onrender.com`) s’affiche sous le nom du site.

## 8. Fonctionnement de l’export

| Étape | Détail |
| --- | --- |
| **Découverte** | Liste les vues et vues matérialisées du schéma, hors `exclure_vues` |
| **Colonnes** | Lit les colonnes de chaque vue et leur type. Les colonnes de géométrie secondaires sont écartées. Les colonnes JSON ou tableaux sont converties en texte |
| **Vue sans `id`** | Ignorée (message « ignorée : pas de colonne id ») |
| **Indicateurs** | Colonnes numériques autres que `id`. S’il n’y en a pas, la carte se colore selon `id` |
| **Fichiers** | GeoPackage (projection d’origine), GeoJSON (WGS84, 5 décimales), CSV (séparateur `;`, virgule décimale, UTF-8 avec signature pour Excel) |
| **Colonne `fid`** | Renommée `fid_source` dans le GeoPackage seulement, pour éviter un conflit avec l’identifiant interne du format |
| **Échecs** | Une vue en échec est signalée dans le journal sans bloquer les autres. Le build échoue seulement si aucune vue n’est publiée |
| **Contrôle** | `verifier_exports.py` refuse les colonnes sensibles (`proprietaire`, `ddenom`, `date_naissance`, `telephone`, `email`, `mot_de_passe`…) et les fichiers de plus de 50 Mo |

## 9. Leaflet et logo

La carte a besoin de Leaflet. Pour le test, la solution la plus simple est de le charger depuis Internet : dans `site/docs/index.html`, remplacer

```html
<link rel="stylesheet" href="assets/vendor/leaflet/leaflet.css">
<script src="assets/vendor/leaflet/leaflet.js"></script>
```

par

```html
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
```

Pour une mise en production, il vaut mieux **héberger Leaflet dans le dépôt** (fichiers `leaflet.css`, `leaflet.js` et dossier `images` dans `site/docs/assets/vendor/leaflet/`), afin de ne pas dépendre d’un site externe.

Le logo se place dans `site/docs/assets/img/logo-audc.png`. Sans lui, l’image de l’en-tête apparaît cassée, sans effet sur le reste.

## 10. Vérifier le site

1. Ouvrir l’adresse du site : les filtres doivent lister les vues publiées.
2. Ouvrir `https://audc-portail-donnees-supabase.onrender.com/data/catalogue.json` : le catalogue doit lister les jeux, leurs colonnes et leurs fichiers.
3. Choisir une vue : la carte, le tableau et les trois boutons de téléchargement doivent se mettre à jour.
4. Dans le journal du déploiement (Render, onglet **Deploys**), contrôler la ligne finale : `Terminé : X vue(s) exportée(s), Y ignorée(s), Z échec(s).`

## 11. Mettre à jour le site

| Besoin | Action |
| --- | --- |
| **Les données de la base ont changé** | Render → **Deploys** → **Manual Deploy** → **Deploy latest commit** : l’export est refait |
| **Le code ou la configuration a changé** | Modifier le fichier sur GitHub (**Commit changes**) : Render redéploie (vérifier l’option *Auto-Deploy* dans Settings) |
| **Ajouter une vue** | La créer dans le schéma avec `geom` et `id`, puis relancer un déploiement |
| **Retirer une vue du site** | L’ajouter à `exclure_vues` dans `indicateurs.yml` |
| **Changer le nom ou la source d’une vue** | Utiliser le bloc `vues:` (partie 6) |
| **Changer l’adresse du site** | Render → Settings → nom du service, ou domaine personnalisé (*Custom Domains*) |

| Fréquence | Tâche |
| --- | --- |
| **À chaque nouvelle donnée** | Relancer un déploiement et contrôler le journal |
| **Chaque trimestre** | Vérifier le site, les téléchargements et la licence |
| **À chaque départ ou arrivée** | Mettre à jour les accès GitHub, Render et Supabase |

## 12. Sécurité et conformité

> **Règles à respecter**
> - **Aucun mot de passe sur GitHub.** Les identifiants se saisissent uniquement dans les variables d’environnement de Render. Si un mot de passe a été envoyé par erreur, le changer immédiatement dans Supabase (*Project Settings → Database*) : supprimer le fichier ne suffit pas, l’historique le conserve.
> - **Compte de lecture seule** recommandé (partie 4.3).
> - **Site public = données publiques** : tout ce que publie le site est accessible à tous. Ne publier que des vues sans donnée personnelle.
> - Le dépôt GitHub ne contient pas les fichiers de données, mais le site les expose tous.

| Sujet | À faire |
| --- | --- |
| **Données personnelles** | Publier uniquement des données agrégées ou non personnelles |
| **Licence et droits** | Vérifier chaque source avant publication ; ne jamais publier de données sous convention restrictive |
| **Mentions légales** | Ajouter l’éditeur, le contact et l’hébergeur (Render) ; à faire valider par la direction |
| **Fond de carte** | OpenStreetMap reçoit l’adresse IP des visiteurs : mettre `fond_osm: false` pour supprimer cet appel |
| **Leaflet depuis Internet** | Le chargement depuis un site externe est acceptable pour un test ; héberger les fichiers dans le dépôt en production |
| **Accès** | Authentification à deux facteurs, au moins deux administrateurs sur le dépôt et sur Render |

## 13. Dépannage

Les quatre premières lignes correspondent à des erreurs réellement rencontrées pendant la mise en place.

| Symptôme (journal ou page) | Cause probable | Solution |
| --- | --- | --- |
| `can't open file '…/scripts/export_donnees.py'` | Les fichiers sont dans `site/` mais Render cherche à la racine | Renseigner **Root Directory** = `site` |
| `Could not open requirements file: 'requirements.txt'` | `requirements.txt` est à la racine, hors de `site/` | Mettre `../requirements.txt` dans la Build Command, ou déplacer le fichier dans `site/` |
| `Column named geom already exists` | Ancienne version de `export_donnees.py` | Utiliser la version actuelle du script |
| `UNIQUE constraint failed: …fid` | Une vue a une colonne `fid` en double | Corrigé dans la version actuelle (renommage dans le GeoPackage) |
| Site ouvert mais carte grise, « Impossible de charger les données de ce jeu » | Leaflet absent (`L is not defined`) | Voir partie 9 |
| « Impossible de charger le catalogue » | `catalogue.json` absent : l’export a échoué | Lire le journal du déploiement |
| `password authentication failed` | Mot de passe ou identifiant faux | Vérifier `PGUSER` (avec `.<ref>`) et `PGPASSWORD` |
| Connexion qui bloque puis `timeout` ou erreur réseau | Hôte direct en IPv6 | Utiliser l’hôte du **Session pooler** |
| `Aucune vue trouvée dans le schéma` | Nom du schéma faux ou droits insuffisants | Vérifier `schema` dans `indicateurs.yml` et les droits du compte |
| « ignorée : pas de colonne id » | La vue n’a pas de colonne `id` | Ajouter `id` à la vue, ou mettre `exiger_id: false` |
| Une vue manque sur le site | Vue en échec ou ignorée | Chercher son nom dans le journal du déploiement |
| Accents illisibles dans Excel | Mauvais encodage à l’ouverture | Ouvrir via *Données → À partir d’un fichier texte ou CSV* (UTF-8) |
| Logo cassé | `logo-audc.png` absent | Envoyer le fichier dans `site/docs/assets/img/` |

## 14. Passage en production à l’AUDC

Points à traiter avant de remplacer la base de test par la base de l’agence :

- **Accès à la base.** La base 3liz n’accepte que des adresses IP autorisées (port 5432). Un build Render n’a pas forcément une adresse fixe : à vérifier avec la DSI et 3liz. Si la connexion n’est pas possible, l’export reste lancé depuis un poste autorisé, et les fichiers de `docs/data/` sont alors versionnés dans GitHub.
- **Paramètres.** Renseigner les variables `PG…` avec les valeurs de 3liz, et un compte de lecture seule limité au schéma de partage.
- **Schéma et vues.** Pointer `schema` vers le schéma de partage et vérifier que chaque vue respecte les conventions (partie 4.1).
- **Contenu.** Retirer le bandeau de test (`maquette: false`), renseigner licence et contact, et mettre un logo.
- **Hébergement et gouvernance.** Compte GitHub et Render de l’organisation, au moins deux administrateurs, authentification à deux facteurs.
- **Convention avec Châlons 360.** Faire valider par la direction les usages autorisés, la fréquence de mise à jour et la mention de la source.
- **Données.** Vérifier les droits de réutilisation de chaque source et l’absence de données personnelles.

## 15. Évolutions possibles

- Tri des colonnes du tableau et recherche d’un objet.
- Graphiques et comparaison entre plusieurs millésimes.
- Légende et classes de couleurs adaptées à chaque vue.
- Nom de domaine propre (réglage *Custom Domains* de Render).
- Déploiement automatique à heure fixe.
- Cartes plus riches publiées avec Lizmap, intégrées au site par un lien.

## 16. Checklist finale

| ✔ | Contrôle |
| --- | --- |
| ☐ | Vues du schéma vérifiées : `geom` et `id` présents, aucune donnée personnelle |
| ☐ | Compte de lecture seule créé et testé |
| ☐ | Fichiers du dépôt envoyés dans la bonne arborescence, aucun `.env` |
| ☐ | Site Render créé : Root Directory `site`, Build Command, Publish Directory `docs` |
| ☐ | Variables d’environnement saisies dans Render |
| ☐ | Déploiement réussi, journal lu (vues exportées, ignorées, en échec) |
| ☐ | Leaflet chargé, carte visible, logo en place |
| ☐ | Téléchargements CSV, GeoJSON et GeoPackage testés |
| ☐ | Licence, contact et mentions légales renseignés, bandeau de test retiré |
| ☐ | Adresse communiquée, procédure de mise à jour transmise à un suppléant |

## Glossaire

| Terme | Signification |
| --- | --- |
| **Dépôt (repository)** | Dossier suivi par Git, avec l’historique des modifications |
| **Render (Static Site)** | Service qui exécute une commande de build puis publie un dossier comme site web |
| **Build Command** | Commande lancée par Render avant chaque publication (ici : installation puis export) |
| **Root Directory** | Dossier du dépôt depuis lequel Render exécute ses commandes |
| **Publish Directory** | Dossier du résultat du build qui est mis en ligne (`docs`) |
| **Supabase** | Service d’hébergement de bases PostgreSQL, avec l’extension PostGIS |
| **Session pooler** | Point de connexion Supabase compatible IPv4, recommandé pour l’export |
| **Variable d’environnement** | Paramètre secret saisi dans Render, qui reste hors du dépôt |
| **Site statique** | Site composé de fichiers fixes, sans serveur applicatif |
| **GeoJSON** | Format de données géographiques utilisé sur le web |
| **GeoPackage** | Format de données géographiques lu par QGIS |
| **Leaflet** | Bibliothèque libre pour afficher des cartes dans un navigateur |
| **Catalogue** | Fichier `catalogue.json` qui décrit les jeux de données du site |

*AUDC – Guide de réalisation du portail de données – version test Supabase + Render*
