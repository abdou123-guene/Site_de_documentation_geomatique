# Analyse du script PHP d’affichage des départements

---

## 1. Connexion à la base de données

```php
<?php
// Connexion à la base de données
include "connexion.php";
?>
 ```
Le fichier connexion.php contient la connexion à la base PostgreSQL.
Nécessaire avant toute requête.

2. Structure HTML et styles CSS

`````html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Consultation des départements</title>
    <style>
        .form-container {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        .texte_rouge {
            color: red;
        }
        .table-container {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }
        table {
            border-collapse: collapse;
        }
        th, td {
            padding: 8px;
        }
    </style>
</head>
<body>
</html>
 `````

Styles internes pour formater formulaire et tableau :

Formulaire en flex (menu région et département côte à côte)

Noms de départements en rouge

Tableau centré

3. Formulaire de sélection dynamique

 ```html
<form method="GET">
    <div class="form-container">
        <div>
            <label>Choisissez une région : </label>
            <select name="nom_region_utilisateur">
                <option value="">liste des régions par nom </option>
                <?php
                $query_regions = "SELECT DISTINCT nom_region FROM depts ORDER BY nom_region";
                $result_regions = pg_query($dbconn, $query_regions);
                while ($region = pg_fetch_array($result_regions, null, PGSQL_ASSOC)) {
                    echo "<option value=\"" . htmlspecialchars($region['nom_region']) . "\">" . htmlspecialchars($region['nom_region']) . "</option>";
                }
                ?>
            </select>
        </div>
        <div>
            <label>Choisissez un département: </label>
            <select name="code_dept_utilisateur">
                <option value="">liste des départements par code</option>
                <?php
                $query_depts = "SELECT DISTINCT code_dept FROM depts ORDER BY code_dept";
                $result_depts = pg_query($dbconn, $query_depts);
                while ($dept = pg_fetch_array($result_depts, null, PGSQL_ASSOC)) {
                    echo "<option value=\"" . htmlspecialchars($dept['code_dept']) . "\">" . htmlspecialchars($dept['code_dept']) . "</option>";
                }
                ?>
            </select>
        </div>
    </div>
    <button type="submit">Afficher le tableau de résultat</button>
</form>
 ```
 
Le formulaire propose deux menus déroulants remplis depuis la base :

Liste des régions (triées alphabétiquement)

Liste des codes départements

htmlspecialchars() protège contre l'injection XSS.

4. Affichage des résultats

 ```php
<?php
if ((isset($_GET['nom_region_utilisateur']) && $_GET['nom_region_utilisateur'] !== '') ||
    (isset($_GET['code_dept_utilisateur']) && $_GET['code_dept_utilisateur'] !== '')) {

    $nom_region = isset($_GET['nom_region_utilisateur']) ? pg_escape_string($dbconn, $_GET['nom_region_utilisateur']) : '';
    $code_dept = isset($_GET['code_dept_utilisateur']) ? pg_escape_string($dbconn, $_GET['code_dept_utilisateur']) : '';

    $query = "SELECT fid, code_dept, nom_dept, code_reg, nom_region, pop, geom
              FROM depts
              WHERE 1=1";

    if ($nom_region !== '') {
        $query .= " AND nom_region ILIKE '$nom_region%'";
    }
    if ($code_dept !== '') {
        $query .= " AND code_dept = '$code_dept'";
    }

    $result = pg_query($dbconn, $query);

    if (!$result) {
        echo "<p>Erreur dans la requête : " . pg_last_error($dbconn) . "</p>";
    } else {
        if (pg_num_rows($result) == 0) {
            echo "<p>Aucun département trouvé.</p>";
        } else {
            echo "<div class=\"table-container\">";
            echo "<table border=1>\n";
            echo "<tr><th>code_dep</th><th>nom_dep</th><th>code_reg</th><th>nom_region</th><th>pop</th></tr>\n";

            while ($ligne = pg_fetch_array($result, null, PGSQL_ASSOC)) {
                echo "<tr>";
                echo "<td>" . htmlspecialchars($ligne['code_dept']) . "</td>";
                echo "<td class=\"texte_rouge\">" . htmlspecialchars($ligne['nom_dept']) . "</td>";
                echo "<td>" . htmlspecialchars($ligne['code_reg']) . "</td>";
                echo "<td>" . htmlspecialchars($ligne['nom_region']) . "</td>";

                if ($ligne['pop'] == '') {
                    echo "<td>non renseigné</td>";
                } else {
                    echo "<td>" . htmlspecialchars($ligne['pop']) . "</td>";
                }
                echo "</tr>\n";
            }
            echo "</table>";
            echo "</div>";
        }
    }
}
?>
 ```
Explications :

Condition pour afficher uniquement si un filtre est sélectionné

Sécurisation SQL avec pg_escape_string()

Requête flexible avec WHERE 1=1 + conditions dynamiques

ILIKE pour recherche insensible à la casse sur la région

Affichage d'un tableau avec les résultats ou message "Aucun département trouvé"

Population affichée ou "non renseigné" si vide

Résumé
Le script est un exemple classique d’interaction PHP avec une base PostgreSQL.

Le formulaire dynamique récupère les options depuis la base.

Le résultat est filtré et sécurisé.

La mise en page est simple mais claire.
