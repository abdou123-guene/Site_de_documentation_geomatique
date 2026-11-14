# Carte des tronçons : de Supabase/PostGIS à une application web en ligne

### 🌍 Voir l'application en ligne : **https://carte-supabase.onrender.com**

> L'hébergement est gratuit : si le site n'a pas été visité depuis un moment, la première ouverture peut prendre 30 à 50 secondes (le service "se réveille"). Patientez, la carte apparaît ensuite.

---

## 1. Ce que fait l'application

Elle affiche sur une carte interactive les tronçons de la vue PostGIS `geo_standards.v_troncon_pgrouting`, hébergée sur une base **Supabase**.

- La carte se centre automatiquement sur les données au premier chargement.
- Un clic sur un tronçon le surligne en orange et affiche **tous ses attributs** dans le panneau de gauche.
- Le bouton **Recharger cette zone** ne charge que les tronçons visibles à l'écran (filtre par emprise).
- Les données sont lues **en direct** dans la base à chaque affichage.

![Schéma de l'interface](images/09-schema-interface.svg)

*Schéma de la mise en page : panneau d'attributs à gauche, carte à droite.*

---

## 2. Architecture

![Schéma d'architecture](images/10-schema-architecture.svg)

Détail d'un affichage de la carte :

![Schéma d'une requête](images/11-schema-requete.svg)

| Brique | Rôle | Où |
|---|---|---|
| **Supabase / PostGIS** | Stocke les données géographiques | Cloud Supabase |
| **FastAPI (`main.py`)** | Lit la vue et renvoie du GeoJSON | Render |
| **Leaflet (`static/index.html`)** | Affiche la carte dans le navigateur | Servi par l'API |
| **GitHub** | Stocke le code, déclenche les déploiements | github.com |
| **Render** | Héberge l'API et le site | render.com |

---

## 3. Prérequis

- Un compte **Supabase** avec une base PostGIS contenant la vue `geo_standards.v_troncon_pgrouting`.
- Un compte **GitHub**.
- Un compte **Render** (gratuit, connexion avec GitHub).
- Un Mac avec **Python 3** (ici utilisé avec conda, le `(base)` visible dans les captures) et l'application **Terminal**.
- Un client SQL (ici **DBeaver**) pour consulter la base. Facultatif.

---

## 4. Étape 1 : les données sources (vue PostGIS)

La connexion à la base se fait dans DBeaver. La donnée utilisée est la **vue** `v_troncon_pgrouting` du schéma `geo_standards`.

![La vue source dans DBeaver](images/01-dbeaver-vue-source.png)

Points importants :

- C'est une **vue** (icône en forme d'œil), pas une table : l'application ne modifie rien, elle lit seulement.
- Le nom du schéma et de la vue sont des **paramètres** (`DB_SCHEMA`, `DB_VIEW`). Changer de vue ne demande aucune modification du code.
- La colonne géométrie est **détectée automatiquement** (voir `detect_geom_column` dans `main.py`).
- Si la vue a un système de coordonnées défini (par exemple Lambert 93, SRID 2154), il est converti en WGS84 (4326) pour Leaflet. Sans SRID, le code suppose du 4326.

### Où trouver la chaîne de connexion

Dans Supabase : bouton **Connect** en haut du projet, puis **Session pooler**. On obtient une adresse de la forme :

```
postgresql://postgres.IDENTIFIANT_PROJET:MOT_DE_PASSE@aws-1-eu-west-2.pooler.supabase.com:5432/postgres
```

On utilise l'adresse du **pooler** (`...pooler.supabase.com`), car la connexion directe ne fonctionne pas depuis Render.

---

## 5. Étape 2 : le code de l'application

### Structure du projet

```
carte_supabase/
├── main.py              # API FastAPI : lit la vue, renvoie du GeoJSON
├── requirements.txt     # bibliothèques Python
├── static/
│   └── index.html       # page web : carte Leaflet + panneau d'attributs
├── .env.example         # modèle de configuration (valeurs factices)
├── .gitignore           # fichiers à ne jamais envoyer sur GitHub
├── README.md            # ce document
└── images/         # captures et schéma utilisés ici
```

Le fichier `.env` (avec le vrai mot de passe) existe **seulement sur le Mac et sur Render**, jamais sur GitHub.

### `requirements.txt`

```
fastapi==0.115.6
uvicorn[standard]==0.34.0
psycopg[binary,pool]==3.2.3
python-dotenv==1.0.1
```

### `.env.example` (modèle, aucune donnée réelle)

```
DATABASE_URL=postgresql://postgres.xxxxx:MOT_DE_PASSE@aws-1-eu-west-2.pooler.supabase.com:5432/postgres
DB_SCHEMA=geo_standards
DB_VIEW=v_troncon_pgrouting
GEOM_COLUMN=
```

### `.gitignore`

```
.env
__pycache__/
.venv/
*.pyc
.DS_Store
```

### `main.py` : ce que fait chaque partie

| Élément | Rôle |
|---|---|
| `load_dotenv()` et `os.environ` | Lit `DATABASE_URL`, `DB_SCHEMA`, `DB_VIEW` (fichier `.env` en local, variables d'environnement sur Render) |
| `ConnectionPool(...)` | Garde quelques connexions ouvertes vers Supabase. `prepare_threshold=None` est nécessaire avec le pooler Supabase |
| `detect_geom_column()` | Cherche la colonne géométrie de la vue (`geometry_columns`, puis le type des colonnes) |
| `GET /api/colonnes` | Liste les colonnes de la vue (utile pour vérifier ce qui est disponible) |
| `GET /api/troncons` | Renvoie la vue en **GeoJSON** WGS84, limité à 5000 objets, filtrable avec `?bbox=minLon,minLat,maxLon,maxLat` |
| `GET /` | Sert la page `static/index.html` |

L'idée centrale de `/api/troncons` : PostgreSQL construit lui-même le GeoJSON.

```sql
SELECT jsonb_build_object('type', 'FeatureCollection',
                          'features', COALESCE(jsonb_agg(f), '[]'::jsonb))
FROM (
  SELECT jsonb_build_object(
           'type', 'Feature',
           'geometry', ST_AsGeoJSON(ST_Transform(geom, 4326), 6)::jsonb,
           'properties', to_jsonb(t) - 'geom'
         ) AS f
  FROM geo_standards.v_troncon_pgrouting t
  LIMIT 5000
) s;
```

`to_jsonb(t) - 'geom'` place **toutes les colonnes** de la vue dans les propriétés de chaque tronçon, sans avoir à les connaître à l'avance. C'est ce qui permet au panneau de gauche d'afficher n'importe quelle vue.

### `static/index.html` : ce que fait la page

- Charge **Leaflet** et le fond de carte **OpenStreetMap**.
- Appelle `/api/troncons`, dessine les tronçons (`L.geoJSON`) et ajuste la vue sur les données.
- Au clic, surligne le tronçon en orange et affiche ses attributs dans le panneau.
- Les valeurs sont insérées avec `textContent` (et non `innerHTML`), ce qui évite d'injecter du code venant de la base.

---

## 6. Étape 3 : lancer l'application sur son Mac

### 6.1 Récupérer le projet

1. Télécharger l'archive `carte-troncons.zip`.
2. Double-cliquer dessus dans le Finder : le dossier `carte-troncons` apparaît (ici dans `Téléchargements`).

### 6.2 Ouvrir le Terminal et aller dans le dossier

1. Ouvrir **Terminal** (Cmd + Espace, taper « Terminal »).
2. Se placer dans le dossier du projet :

```bash
cd /Users/admin/Downloads/carte-troncons
ls -a
```

`ls -a` affiche aussi les fichiers cachés. On doit voir `main.py`, `static`, `requirements.txt` et `.env.example`.

### 6.3 Créer le fichier `.env`

Le fichier `.env.example` est un **modèle** : on en fait une copie nommée `.env`, qui contiendra les vraies valeurs.

```bash
cp .env.example .env
open -e .env
```

`open -e` ouvre le fichier dans TextEdit. On remplace la ligne `DATABASE_URL=...` par la vraie chaîne de connexion Supabase (identifiant du projet et mot de passe réels), puis on enregistre avec **Cmd + S**.

![Création du fichier .env dans le Terminal](images/02-terminal-creation-env.png)

*Sur la capture, la première tentative échoue (`No such file or directory`) car le Terminal était dans le dossier personnel (`~`) et non dans `carte-troncons`. Après le `cd`, la copie fonctionne, et `ls -a` montre bien `.env` à côté de `.env.example`.*

> **Fichiers cachés sur Mac.** Les fichiers dont le nom commence par un point (`.env`, `.gitignore`) n'apparaissent pas dans le Finder. Raccourci pour les afficher ou les masquer : **Cmd + Maj + point**.

> **Ne pas confondre :** `.env.example` reste tel quel (modèle). Seul `.env` contient le mot de passe.

### 6.4 Installer et démarrer

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

- `python3 -m venv .venv` crée un environnement Python isolé pour le projet.
- `source .venv/bin/activate` l'active : `(.venv)` apparaît devant l'invite du Terminal.
- `pip install -r requirements.txt` installe FastAPI, uvicorn, psycopg et python-dotenv.
- `uvicorn main:app --reload` démarre le serveur.

Ouvrir ensuite **http://localhost:8000** : la carte s'affiche avec les tronçons. On peut aussi consulter **http://localhost:8000/api/colonnes** pour voir les colonnes de la vue.

Pour arrêter le serveur : **Ctrl + C** dans le Terminal.

---

## 7. Étape 4 : envoyer le code sur GitHub

### 7.1 Créer le dépôt

Sur github.com : **+** en haut à droite, puis **New repository**.

![Création du dépôt GitHub](images/03-github-creation-depot.png)

Réglages utilisés :

| Champ | Valeur |
|---|---|
| Owner | `abdou123-guene` |
| Repository name | `carte_supabase` |
| Visibility | **Public** |
| Add README | **Off** |
| Add .gitignore | **No .gitignore** |
| Add license | **No license** |

On crée le dépôt **vide** (rien de coché) pour éviter tout conflit avec les fichiers du projet.

### 7.2 Vérifier ce qui sera envoyé

Avant d'envoyer, le point essentiel est de vérifier que `.env` n'est **pas** dans la liste. Dans le Terminal, après `git init` et `git add .` :

```bash
git status --short
```

![git status dans le Terminal](images/04-terminal-git-status.png)

On voit `.env.example`, `.gitignore`, `README.md`, `main.py`, `requirements.txt` et `static/index.html`. Le fichier `.env` est absent : le `.gitignore` fonctionne. Seul `.DS_Store`, un fichier système du Mac sans intérêt, s'est glissé dans la liste. On l'écarte :

```bash
echo ".DS_Store" >> .gitignore
git rm --cached .DS_Store
git add .gitignore
```

> Sur la capture, on voit aussi des erreurs `command not found: A`. Elles viennent d'une liste de résultats collée dans le Terminal comme si c'étaient des commandes. Il ne faut copier que les blocs de commandes.

### 7.3 Envoyer les fichiers

Deux méthodes existent. Voici celle **réellement utilisée**, sans passer par un jeton d'accès, entièrement dans le navigateur.

**Fichiers visibles** (`main.py`, `requirements.txt`, `README.md`, `static/index.html`) : sur la page du dépôt, **Add file > Upload files**, puis glisser les fichiers. Le fichier `index.html` doit rester dans un dossier `static` (on peut le créer avec **Add file > Create new file** en tapant `static/index.html` comme nom).

**Fichiers cachés** (`.gitignore`, `.env.example`) : le sélecteur de fichiers du navigateur ne les voit pas. On les **crée directement sur GitHub** : **Add file > Create new file**, nom `.gitignore` (puis `.env.example`), coller le contenu indiqué à l'étape 5, puis **Commit changes**.

**Jamais `.env`.** Ce fichier contient le mot de passe de la base et ne doit pas quitter l'ordinateur.

> **Méthode alternative, en ligne de commande** (non utilisée ici). Elle demande un jeton d'accès personnel (GitHub > Settings > Developer settings > Personal access tokens, case `repo`), car GitHub n'accepte plus le mot de passe du compte :
> ```bash
> git branch -M main
> git remote add origin https://github.com/abdou123-guene/carte_supabase.git
> git push -u origin main
> ```
> Une autre option avec interface graphique est l'application **GitHub Desktop**.

### 7.4 Vérifier le dépôt

![Le dépôt GitHub avec ses fichiers](images/05-github-depot-fichiers.png)

Le dépôt contient bien `static`, `.env.example`, `.gitignore`, `README.md`, `main.py` et `requirements.txt`. **`.env` n'y figure pas.**

Le dernier commit visible, « Delete static/ss », correspond à un fichier de test supprimé à la main, sans conséquence. Le dossier `static` doit contenir `index.html` : sans lui, la carte ne s'affiche pas.

---

## 8. Étape 5 : mettre l'application en ligne avec Render

### 8.1 Créer le compte et le service

1. Aller sur **render.com**, cliquer sur **Get Started**, puis se connecter avec **GitHub** et autoriser l'accès au dépôt `carte_supabase`.
2. **New +**, puis **Web Service**, puis choisir le dépôt `abdou123-guene/carte_supabase` et cliquer sur **Connect**.

### 8.2 Réglages du service

| Champ | Valeur |
|---|---|
| Name | `carte-supabase` |
| Region | Frankfurt (EU Central), la plus proche de Paris |
| Branch | `main` |
| Root Directory | *(vide)* |
| Language | Python 3 |
| Build Command | `pip install -r requirements.txt` |
| Start Command | `uvicorn main:app --host 0.0.0.0 --port $PORT` |
| Instance Type | **Free** (0 $) |

Les lignes à 7, 25 et 85 $/mois sont payantes : vérifier que la ligne **Free** est bien sélectionnée.

### 8.3 Variables d'environnement

Plus bas sur la page, section **Environment Variables**. Chaque ligne a deux cases : **KEY** (le nom) à gauche, **VALUE** (la valeur) à droite. Le bouton **Add Environment Variable** ajoute une ligne.

![Variables d'environnement sur Render](images/06-render-variables-environnement.png)

| KEY | VALUE |
|---|---|
| `DATABASE_URL` | la chaîne de connexion Supabase complète, commençant par `postgresql://` |
| `DB_SCHEMA` | `geo_standards` |
| `DB_VIEW` | `v_troncon_pgrouting` |
| `PYTHON_VERSION` | `3.12.7` |

Précisions sur `DATABASE_URL` :

- On met **seulement la valeur** (`postgresql://...`), sans écrire `DATABASE_URL=` devant, sans guillemets, sans espace avant ou après.
- C'est ici, et non dans GitHub, que le mot de passe est enregistré.
- Le plus sûr est de **copier la valeur depuis le fichier `.env` local** (`open -e .env`) plutôt que de la retaper.
- `PYTHON_VERSION` évite que Render choisisse une version de Python trop récente pour les bibliothèques.

### 8.4 Déployer

Tout en bas, cliquer sur **Deploy Web Service**. La fenêtre de logs défile :

1. **Build** : installation des bibliothèques (1 à 3 minutes).
2. **Start** : lancement de `uvicorn`.
3. Le statut passe à **Live** et l'adresse du site s'affiche en haut de la page.

Ensuite, **chaque modification enregistrée sur GitHub redéploie le site automatiquement**.

![Schéma du déploiement automatique](images/12-schema-deploiement.svg)

---

## 9. Dépannage : les erreurs rencontrées et leurs corrections

| Symptôme | Cause | Correction |
|---|---|---|
| `cp: .env.example: No such file or directory` | Le Terminal n'était pas dans le dossier du projet | `cd /Users/admin/Downloads/carte-troncons` puis relancer |
| `.env` ou `.gitignore` introuvables dans le Finder | Fichiers cachés sur Mac | **Cmd + Maj + point**, ou `ls -a` dans le Terminal |
| Le sélecteur de fichiers de GitHub ne voit pas `.gitignore` | Même raison, fichiers cachés | Les créer avec **Add file > Create new file** |
| `zsh: command not found: A` | Une liste de résultats a été collée comme commande | Ne copier que les blocs de commandes |
| `git status` affiche `.DS_Store` | Fichier système du Mac | L'ajouter au `.gitignore` et faire `git rm --cached .DS_Store` |
| GitHub demande un mot de passe au `git push` | Les mots de passe de compte ne sont plus acceptés | Utiliser un jeton d'accès, GitHub Desktop, ou l'envoi par le navigateur |
| Déploiement Render en échec | Voir ci-dessous | Corriger `DATABASE_URL` |

### Le déploiement Render qui a échoué

Le premier déploiement a échoué après 1 minute 15 : l'installation s'était bien passée, mais l'application n'arrivait pas à démarrer.

![Déploiement Render en échec](images/07-render-deploiement-echoue.png)

Dans les logs, l'erreur finale est `psycopg_pool.PoolTimeout: couldn't get a connection after 30.00 sec` : l'application n'a pas réussi à se connecter à la base. En remontant dans les logs, la ligne qui explique la cause :

![Logs Render : erreur de connexion](images/08-render-logs-erreur-connexion.png)

`error connecting in 'pool-1': [Errno -2] Name or service not known` signifie que l'adresse du serveur n'a pas pu être lue. La variable `DATABASE_URL` saisie sur Render était **mal formée** : après une première correction, le message est devenu `missing "=" after "//postgres..."`, ce qui montrait que la valeur commençait par `//postgres...` au lieu de `postgresql://postgres...` (le début avait été perdu au copier-coller).

**Correction :**

1. Sur Render, ouvrir **Environment** et modifier `DATABASE_URL`.
2. Effacer la valeur, puis coller la chaîne copiée depuis le fichier `.env` local (qui fonctionnait).
3. Vérifier qu'elle commence par **`postgresql://`** (le mot entier).
4. Cliquer sur **Save, rebuild and deploy**.

Le déploiement suivant est passé au statut **Live**.

### Autres erreurs possibles

| Message dans les logs | Cause probable | Correction |
|---|---|---|
| `password authentication failed` | Mot de passe incorrect dans `DATABASE_URL` | Corriger le mot de passe |
| `Tenant or user not found` | Identifiant de projet ou région erroné | Recopier la chaîne depuis Supabase (**Connect > Session pooler**) |
| Mot de passe contenant `@ # / : ?` | Ces caractères cassent l'adresse | Les encoder (`@` devient `%40`, `#` devient `%23`, `/` devient `%2F`, `:` devient `%3A`, `?` devient `%3F`) ou choisir un mot de passe alphanumérique |
| `Aucune colonne géométrie trouvée` | La colonne n'est pas détectée | Ajouter la variable `GEOM_COLUMN` avec son nom |
| Site lent au premier chargement | Offre gratuite : le service s'endort | Patienter 30 à 50 secondes |

---

## 10. Résultat final

- Application en ligne : **https://carte-supabase.onrender.com**
- Code source : dépôt GitHub `abdou123-guene/carte_supabase`
- Données lues en direct depuis la vue `geo_standards.v_troncon_pgrouting` de Supabase
- Redéploiement automatique à chaque modification du dépôt

---

## 11. Sécurité

- **Dépôt public, secrets privés.** Le mot de passe de la base n'existe que dans `.env` (Mac, ignoré par Git) et dans les variables d'environnement de Render. Le dépôt ne contient que des valeurs factices (`.env.example`).
- **Les messages d'erreur peuvent afficher la chaîne de connexion.** Lors d'un échec de connexion, les logs de Render ont reproduit l'adresse complète, mot de passe compris. Avant de partager des logs ou une capture d'écran, il faut **masquer le mot de passe**. Si un mot de passe a été exposé, le changer dans Supabase (**Project Settings > Database > Reset database password**), puis mettre à jour `.env` et Render.
- **L'application est publique.** Toute personne qui connaît l'adresse voit les tronçons. Si les données sont sensibles, il faut ajouter une authentification.
- **Accès en lecture seule.** L'application n'exécute que des `SELECT`. Pour limiter davantage les risques, on peut créer dans Supabase un utilisateur dédié qui n'a le droit de lire que cette vue.

---

## 12. Alternative : GitHub Actions + GitHub Pages

GitHub Actions est un automate qui exécute des tâches : il n'héberge pas une application en continu. Une variante entièrement dans GitHub consiste à :

1. stocker `DATABASE_URL` dans **Settings > Secrets and variables > Actions** ;
2. faire exporter la vue en fichier GeoJSON par un workflow ;
3. publier la carte et ce fichier sur **GitHub Pages**.

| | Render (choix retenu) | Actions + Pages |
|---|---|---|
| Données | En direct | Copie figée, mise à jour à chaque exécution |
| Serveur Python | Oui | Non (site statique) |
| Temps de réveil | 30 à 50 s en offre gratuite | Aucun |
| Données exposées | Via l'API | Fichier GeoJSON public |

---

## 13. Pour aller plus loin

- Colorer les tronçons selon un attribut (type, longueur...).
- Ajouter un filtre ou une recherche.
- Calculer un itinéraire avec **pgRouting**, la vue étant déjà préparée pour cela.
- Proposer un autre fond de carte (plan clair, satellite).
- Ajouter une authentification si les données sont sensibles.

---

## 14. Aide-mémoire

**Local (Mac)**

```bash
cd /Users/admin/Downloads/carte-troncons
source .venv/bin/activate
uvicorn main:app --reload        # puis http://localhost:8000
```

**Configuration**

```bash
cp .env.example .env             # créer le fichier de configuration
open -e .env                     # le modifier (TextEdit), puis Cmd + S
ls -a                            # voir les fichiers cachés
```

**Variables à renseigner sur Render**

| KEY | VALUE |
|---|---|
| `DATABASE_URL` | `postgresql://postgres.IDENTIFIANT_PROJET:MOT_DE_PASSE@aws-1-eu-west-2.pooler.supabase.com:5432/postgres` |
| `DB_SCHEMA` | `geo_standards` |
| `DB_VIEW` | `v_troncon_pgrouting` |
| `PYTHON_VERSION` | `3.12.7` |

**Adresses utiles**

- Application : https://carte-supabase.onrender.com
- Liste des colonnes de la vue : https://carte-supabase.onrender.com/api/colonnes
- Données GeoJSON : https://carte-supabase.onrender.com/api/troncons
