# Script PHP – Consultation dynamique des départements (PostgreSQL)

## Objectif
<p>Ce script PHP permet :</p>
<ul>
  <li>d’interroger une base PostgreSQL</li>
  <li>de filtrer des données par région ou département</li>
  <li>d’afficher les résultats sous forme de tableau HTML</li>
</ul>
<p>Il s’agit d’un exemple simple d’application web de consultation de données territoriales.</p>

## Structure du projet
<pre>
/projet_depts/
├── index.php
├── connexion.php
├── style.css (optionnel)
└── README.md
</pre>

## Connexion à la base de données
<pre><code>
&lt;?php
include "connexion.php";
?&gt;
</code></pre>

### Contenu du fichier connexion.php
<pre><code>
&lt;?php
$dbconn = pg_connect("
    host=localhost
    dbname=ma_base
    user=mon_user
    password=mon_mdp
");
?&gt;
</code></pre>

<p>Cette connexion est nécessaire pour exécuter les requêtes SQL.</p>

## Structure HTML et styles
<pre><code>
.form-container {
    display: flex;
    justify-content: space-between;
}

.table-container {
    display: flex;
    justify-content: center;
}

.texte_rouge {
    color: red;
}
</code></pre>

### Fonction
<ul>
  <li>organisation du formulaire avec Flexbox</li>
  <li>affichage centré du tableau</li>
  <li>mise en évidence du nom du département</li>
</ul>

## Formulaire de sélection dynamique
<pre><code>
&lt;form method="GET"&gt;
</code></pre>

### Principe
<ul>
  <li>choix d’une région</li>
  <li>choix d’un département</li>
</ul>
<p>Les valeurs sont récupérées depuis la base de données.</p>

### Requête SQL pour les régions
<pre><code>
SELECT DISTINCT nom_region FROM depts ORDER BY nom_region;
</code></pre>

### Requête SQL pour les départements
<pre><code>
SELECT DISTINCT code_dept FROM depts ORDER BY code_dept;
</code></pre>

### Sécurité
<pre><code>
htmlspecialchars(...)
</code></pre>

<p>Permet de protéger contre les attaques XSS.</p>

## Traitement des filtres
<pre><code>
if ((isset($_GET['nom_region_utilisateur']) && $_GET['nom_region_utilisateur'] !== '') ||
    (isset($_GET['code_dept_utilisateur']) && $_GET['code_dept_utilisateur'] !== '')) {
</code></pre>

### Fonction
<ul>
  <li>vérifier la sélection utilisateur</li>
  <li>éviter les requêtes inutiles</li>
</ul>

## Sécurisation des entrées utilisateur
<pre><code>
pg_escape_string(...)
</code></pre>

<p>Permet de se protéger contre les injections SQL.</p>

## Construction dynamique de la requête
<pre><code>
WHERE 1=1
</code></pre>

<p>Permet d’ajouter facilement des conditions dynamiques :</p>

<pre><code>
ILIKE → recherche sans sensibilité à la casse
=     → correspondance exacte
</code></pre>

## Exécution de la requête
<pre><code>
pg_query($dbconn, $query)
</code></pre>

### Gestion des erreurs
<pre><code>
pg_last_error($dbconn)
</code></pre>

## Affichage des résultats
<p>Le script affiche un tableau contenant :</p>

<ul>
  <li>code département</li>
  <li>nom département</li>
  <li>code région</li>
  <li>nom région</li>
  <li>population</li>
</ul>

### Gestion des valeurs manquantes
<pre><code>
if ($ligne['pop'] == '') {
    echo "non renseigné";
}
</code></pre>

## Résultat pour l’utilisateur
<ul>
  <li>filtrage des données</li>
  <li>consultation dynamique</li>
  <li>affichage structuré</li>
</ul>

## Sécurité mise en place
<table border="1">
<tr>
  <th>Type de risque</th>
  <th>Solution</th>
</tr>
<tr>
  <td>XSS</td>
  <td>htmlspecialchars()</td>
</tr>
<tr>
  <td>Injection SQL</td>
  <td>pg_escape_string()</td>
</tr>
</table>

## Améliorations possibles
<ul>
  <li>utiliser des requêtes préparées (pg_prepare)</li>
  <li>séparer HTML / PHP (architecture MVC)</li>
  <li>ajouter pagination</li>
  <li>utiliser AJAX</li>
  <li>intégrer PostGIS</li>
</ul>

## Cas d’utilisation
<ul>
  <li>consultation de données territoriales</li>
  <li>formation SIG</li>
  <li>outil interne en agence d’urbanisme</li>
  <li>exemple pédagogique PHP + PostgreSQL</li>
</ul>

## Conclusion
<p>
Ce script constitue une base solide pour :
</p>

<ul>
  <li>l’interaction PHP – PostgreSQL</li>
  <li>la manipulation de données dynamiques</li>
  <li>le développement d’applications web en géomatique</li>
</ul>
