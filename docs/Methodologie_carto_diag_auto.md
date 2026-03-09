
# Méthodologie d’automatisation de cartes thématiques
---

**Introduction** 
La simplification de ce travail commence par l'application d'un ***filtre sur les couches*** afin de ne conserver que les territoires qui nous intéressent. Cela permet d’éviter d’être perturbé par l’affichage de nombreuses données, comme c’est le cas pour les communes. 

Il est important de noter que les couches utilisées pour l’automatisation proviennent de **scripts SQL** exécutés directement sur la base de données, et non de couches stockées de manière permanente dans la base. 

Cependant, certaines exceptions existent, notamment pour les **rasters** et les **couches d’étiquettes**, qui peuvent être enregistrées séparément pour des raisons de performance et de gestion des données. 
## 1 . Automatisation de la couche de couverture
Certaines couches doivent être paramétrées afin de permettre l’automatisation de l’atlas. 
La **couche de génération de l’atlas** constitue la base du projet. Elle définit les différentes entités à cartographier et sert de référence pour la production des cartes. Grâce à une symbologie basée sur un ensemble de règles, chaque EPCI (Établissement Public de Coopération Intercommunale) peut être représenté individuellement tout en conservant une mise en page homogène.  
⚠️ **Attention :** Il est essentiel de choisir un champ unique pour identifier chaque entité et éviter les doublons. Par exemple, on peut utiliser le champ ***lib*** **(libellé)** ou ***code\_epci*** **(code EPCI)**. 

<img width="454" height="297" alt="image" src="https://github.com/user-attachments/assets/f037adc9-a49c-4abb-a39c-ce86b54404f2" />

**Figure 1 :** Configuration de la couche principale de l'atlas 
**Utilisation des expressions QGIS** 
● Les **expressions QGIS** sont souvent utilisées pour filtrer ou ajuster l'affichage des éléments en fonction de l'entité active dans l'atlas. ● Certaines permettent d'afficher uniquement les éléments correspondant à la page en cours lors de la génération des cartes. 
Cependant, la génération effective de l’atlas s’effectue uniquement dans la mise en page QGIS, où l’ensemble des paramètres définis prend effet. 
## 2\. Paramétrage des autres couches
**2.1 . Les couches de points** 
**2.1.1. Avec @atlas\_pagename** 
Si l’on souhaite afficher des couches de points (par exemple : gares TGV, arrêts bus), il est nécessaire de paramétrer leur symbologie à l’aide d’un **ensemble de règles**. Cela permet de restreindre leur affichage à l’emprise de l’entité de l’atlas en cours d’affichage. 
Le processus de paramétrage est similaire à celui de la couche de génération de l’atlas (partie 1), mais appliqué spécifiquement à chaque couche concernée.

<img width="454" height="297" alt="image" src="https://github.com/user-attachments/assets/535a27d3-6219-4d56-afaf-2831091bbe0d" />

**Figure 2 :** Configuration des couches à automatiser 
**2.1.2. Avec intersects($geometry, @atlas\_geometry)** 
L'expression intersects($geometry, @atlas\_geometry) ou un autre prédicat spatial tel que within, disjoint, etc. permet de contrôler l’affichage des couches de points, de lignes et de surfaces en fonction de la géométrie de l’entité de l’atlas actif. 
Cet outil est particulièrement utile lorsqu'on souhaite filtrer spatialement les entités, indépendamment de leurs attributs. Il peut être appliqué dans des symbologies catégorisées ou graduées, ce qui permet d'affiner l'affichage des éléments selon leur relation géographique avec l’entité active. 
Cependant, pour que ce filtrage fonctionne dans le cadre de symbologies catégorisées ou graduées, il est nécessaire de passer à une symbologie basée sur un **ensemble de règles** après avoir effectué la catégorisation ou la graduation. Cela permet d’appliquer des critères spatiaux tout en conservant une gestion de la symbologie dynamique et détaillée. 
La **Figure 3** illustre le cas où seuls les types d’**aérodromes** de l’EPCI actif sont affichés. 

<img width="454" height="151" alt="image" src="https://github.com/user-attachments/assets/fcf3f7c0-f10a-44da-815a-ebdcce0688fe" />

En revanche, la **Figure 4** montre un cas où **toutes les catégories surfaciques** sont masquées en dehors de l’entité active de l’atlas.  
**Figure 3 :** Exemple des couches de points catégorisées 
**Figure 4 :** Exemple des couches surfaciques classées par catégorie 
Il est également possible d'utiliser ces expressions pour gérer l'affichage des cercles proportionnels et des étiquettes en fonction de l'atlas. Ces réglages s'effectuent dans la section "***Rendu***" des diagrammes pour les cercles proportionnels, et dans la section "Étiquettes" pour les étiquettes. **La figure 5** illustre un exemple de positionnement des cercles proportionnels à l'intérieur de l'emprise définie par l'atlas. 

<img width="454" height="156" alt="image" src="https://github.com/user-attachments/assets/1109ec9a-7418-4eaa-b9d2-45edd51e4142" />

**Figure 5 :** Affichage des cercles proportionnels (type camembert) 
 **Différence entre** intersects($geometry, @atlas\_geometry) et @atlas\_pagename 
**\- @atlas\_pagename** 
**Principe** : Il s'agit d'une variable qui stocke la valeur du champ défini comme "nom" de l'atlas (souvent un identifiant ou un libellé). �� **Utilisation** : Permet de filtrer des couches en se basant sur une **correspondance attributaire** entre les données et la page active de l'atlas. 
**Exemple** :  
Si la couche de génération de l’atlas contient un champ nom\_epci, on peut filtrer une couche de gares en utilisant : ***"nom\_epci" \= @atlas\_pagename*** 
**\- intersects($geometry, @atlas\_geometry)** 
**Principe** : Vérifie si la **géométrie** d'une entité intersecte la géométrie de l’entité active dans l’atlas. 
**Utilisation** : Permet de filtrer les entités **géographiquement**, sans avoir besoin d’un champ commun. 
**Exemple** : 
Si l’atlas est basé sur une couche d’EPCI et qu'on veut afficher uniquement les gares situées à l’intérieur de l’EPCI actif : ***intersects($geometry, @atlas\_geometry) ou within($geometry, @atlas\_geometry)*** 

| Critère  | @atlas\_pagename | intersects($geometry,  @atlas\_geometry) |
| ----- | ----- | ----- |
| Basé sur  | Valeur attributaire  | Relation spatiale |
| Nécessite un champ commun  | ✅ Oui  | ❌ Non |
| Fonctionne avec | Données ayant un  identifiant partagé | Toutes les données  spatiales |
| Performance  | ⚡ Très rapide  | ⏳ Plus gourmand en calcul |
| Exemple d’usage  | Filtrer par nom d’epci | Filtrer par intersection géométrique |

**Figure 6 :** Tableau de comparaison synthétique 
## 3\. Visualisation des cartes
**3.1. Carte à plat** 
Les cartes à plat sont plus faciles à gérer et leurs ajustements posent moins de soucis. Lorsqu'il s'agit de symbologies graduées ou catégorisées,  
l'affichage des éléments dans l’atlas actif est géré de la même manière que décrite dans la section **2.1.2**. 
**3.2. Carte avec cercles proportionnels (camemberts)** 
La gestion de ce type de carte peut être complexe (***cf partie problématique***), car elle nécessite le réglage de plusieurs paramètres, notamment la taille et la position des cercles. La variabilité des tailles est directement liée aux données (valeurs minimales et maximales). 
Cependant, il est possible d’ajuster la taille globale des cercles afin d’optimiser leur affichage et de mieux les adapter aux entités spatiales représentées (figure 7). 

<img width="454" height="107" alt="image" src="https://github.com/user-attachments/assets/9c8cdb42-54a7-4580-82f7-b69b8218eaca" />

**Figure 7 :** Échelle de visualisation des diagrammes en camembert 
## 4\. Mise en page et génération de l’atlas
La première étape consiste à réaliser une **mise en page classique**, comme pour une carte sans atlas, en intégrant tous les **éléments cartographiques nécessaires** selon la demande reçue. 
Une fois tous ces éléments définis dans la mise en page, on peut passer à la **génération de l’atlas** en cliquant sur le bouton **paramètres de l’atlas** dans la barre d’outils. <img width="19" height="18" alt="image" src="https://github.com/user-attachments/assets/818391e5-4de5-45dc-917a-61e61607f696" />

Cela ouvre une fenêtre dans laquelle il faut renseigner la **couche de couverture**, définie plus haut (**partie 1**), qui contient les différentes entités à cartographier (EPCI). Cette couche sert de référence pour l’automatisation de l’atlas et permet de générer les cartes de manière dynamique. 

<img width="287" height="349" alt="image" src="https://github.com/user-attachments/assets/b9f02ae8-7602-422d-8034-cc45026a870d" />

**Figure 8 :** Paramétrage et génération de l'atlas 
Le champ **« lib »** est choisi pour identifier et individualiser les entités de l’atlas. Il permet également d’afficher automatiquement le libellé en haut de chaque page, facilitant ainsi la lecture et la compréhension des cartes. 

<img width="98" height="29" alt="image" src="https://github.com/user-attachments/assets/b9eeec15-ae36-4be4-83d6-1b4f5f5adfb4" />

Néanmoins, il est aussi possible de choisir le **code des EPCI** comme identifiant unique. Avec ces paramètres définis, nous disposons de toutes les informations nécessaires pour lancer l’atlas. 
## 5\. Lancement de l’atlas
L’atlas se lance à l’aide du bouton **aperçu de l’atlas,** disponible dans la barre d’outils.  <img width="31" height="24" alt="image" src="https://github.com/user-attachments/assets/a6150889-61f4-435c-bd60-d52449335552" />
Toutefois, au premier affichage, la carte peut sembler **fixe**, même si l’atlas est activé. Cela est dû au fait que l’emprise cartographique n’est pas encore contrôlée par l’atlas. 
Pour afficher correctement toutes les entités, il est nécessaire d’activer cette option dans les **propriétés de l’emprise de la carte**. Il suffit alors de cocher l’option permettant de **lier l’emprise à l’atlas.** Une fois cette étape réalisée, les cartes de l’atlas s'afficheront

<img width="141" height="21" alt="image" src="https://github.com/user-attachments/assets/9e6c1133-5285-47c4-8154-94f22f0c8bb3" />

dynamiquement, et il sera possible de naviguer entre les entités à l’aide des **boutons de défilement**. 

<img width="454" height="30" alt="image" src="https://github.com/user-attachments/assets/190c50ad-ef04-425c-81cb-98e8fa61b272" />

**Figure 9 :** Affichage des cartes générées automatiquement de l'atlas 
**\- Titre** 
Le **titre de la carte** peut être automatisé en fonction de l’atlas, à condition que cette information soit disponible dans un champ de la table de **génération de l’atlas** (voir Partie 1). 
Par exemple, si nous souhaitons faire apparaître le nom de l’EPCI dans le titre de chaque carte, nous pouvons récupérer cette information depuis la couche de l’atlas en utilisant le champ **lib**. Ainsi, le titre reste constant, mais  
le nom du territoire varie automatiquement en fonction de l’atlas actif. 

<img width="454" height="98" alt="image" src="https://github.com/user-attachments/assets/44ee3f08-52e4-4a25-9646-7431594613b7" />

**Figure 10 :** Automatisation du titre de la carte en fonction de l'atlas actif 
**\- Légende** 
L’automatisation de la **légende** semble relativement simple et ne nécessite pas d'expressions QGIS complexes. Il suffit de cocher les cases **optionnelles** pour restreindre l’apparence des éléments en fonction des besoins cartographiques. 
Il est **idéalement recommandé** de désactiver l'option **« mise à jour automatique »** pour pouvoir ajuster manuellement les éléments de la légende (par exemple, regroupement, ajout, retrait, renommage, etc.). 
De plus, il est aussi possible de restreindre l’affichage des éléments de la légende à **l’emprise de la carte**, ou encore de l'afficher uniquement pour l'**entité active** de l'atlas (figure 11).  
**Figure 11 :** Automatisation de l’affichage des légendes 
**\- Échelle** 
L’automatisation de l’**échelle** s’avère moins complexe, notamment grâce à l’option d’**ajustement automatique** en fonction de la largeur du segment. 
Cependant, il est essentiel de **contrôler la taille de la barre d’échelle** afin d’éviter qu’elle ne **dépasse sur la carte**, ce qui pourrait nuire à la lisibilité. 
La **figure 12** illustre un exemple d’**échelle dynamique**, configurée avec une 
longueur de **20 mm** et une seule **subdivision**. 

<img width="355" height="129" alt="image" src="https://github.com/user-attachments/assets/59ce1049-d5db-45b9-8f88-a3d63cf14ce6" />

**\- Date de la carte** 
Étant donné que cette carte sera mise à jour en fonction des demandes des EPCI, il est important d’automatiser l’affichage de la date de réalisation. Cela permet de gagner du temps et d’éviter d’éventuels oublis.  
**Figure 12 :** Adaptation des échelles cartographiques 
**\- Logo des EPCI** 
Afficher automatiquement le logo correspondant à l’EPCI actif sur chaque page de l’atlas dans QGIS, en fonction du nom ou du code de l’EPCI. 
️ **Données utilisées** 
● **Couche de couverture de l’atlas** : atlas\_EPCI, avec la colonne code (ou lib) correspondant aux EPCI. 
● **Fichier Excel de correspondance** : test.xlsx, contenant trois colonnes : ○ code : identifiant de l’EPCI (correspondant à la couche atlas), ○ lib : nom de l’EPCI (facultatif si on utilise le code), 
○ chemin : chemin absolu du logo image correspondant (format PNG, JPG...). 
**Principe de la méthode** 
1\. **Lier dynamiquement le logo** au paramètre actif de l’atlas (EPCI). 
2\. Utiliser une **jointure virtuelle** dans QGIS entre la couche de couverture (atlas\_EPCI) et le fichier Excel (test.xlsx) via le champ code. 
3\. Ajouter une **image dynamique** dans la mise en page de l’atlas, en utilisant une **expression QGIS** pour lire le chemin d’image stocké dans le fichier Excel. 
**Étapes de mise en œuvre** 
**1\.** **Charger le fichier Excel dans QGIS** 
● Menu : *Layer \> Add Layer \> Add Layer from Excel* (test.xlsx). ● Vérifie que les champs code, lib et chemin sont bien reconnus. 
**2\.** **Joindre le fichier Excel à la couche atlas** 
● Dans les **propriétés de la couche atlas\_EPCI**, onglet *Jointures* : ○ Couche cible : test.xlsx,  
○ Champ commun : code, 
○ Active la jointure. 
**3\.** ️ **Ajouter le logo dans la mise en page** 
**\-** Ouvre la mise en page de ton atlas. 
**\-** Insère une **image** (Ajouter une image). 
**\-** Dans l’onglet **propriétés de l’image** : 
o Coche : **"Charger l’image depuis une expression"**. 
o Mets cette expression qui correspond au nom de la colonne jointe dans la couche de couverture de l’atlas : 
"test-Feuil1\_chemin" 

<img width="202" height="216" alt="image" src="https://github.com/user-attachments/assets/ba88ea54-03ae-46eb-ac25-08f659244864" />

<img width="224" height="95" alt="image" src="https://github.com/user-attachments/assets/966be89f-e1b6-4b70-8352-a0e2e0f1e30d" />

**Figure 13 :** Affichage dynamique du logo EPCI dans l’atlas à partir d’un fichier Excel 
## 6\. Problématique liée à l’automatisation (atlas) 
Tout d'abord, il est **idéal** d’afficher les étiquettes uniquement pour les communes de l’EPCI actif **dan**s l’atlas. Pour cela, il est nécessaire de définir un **étiquetage basé sur des règles**, en appliquant le filtre suivant : ***within ($geometry, @atlas\_geometry).***  

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/b48ab832-32dc-4905-9d09-37b7325a5bb3" />

**Figure 14 :** Filtrage des étiquettes selon l'atlas actif 
Cependant, les étiquettes s'affichent souvent **dans des positions non optimales**, compromettant la lisibilité de la carte, même après ajustement classique des paramètres d’étiquetage (figure 14). 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/96768123-2423-4ca9-bbe6-a48b37ffb6e3" />

**Figure 15 :** La position des étiquettes sur la carte 
**6.1. Méthode pour un positionnement optimal des étiquettes**
Afin d’optimiser la position des étiquettes, il serait nécessaire de **créer une couche de points** associée aux entités (ici, chaque commune dans un EPCI). 
**\- Création de la couche de points** 
Cette couche de points doit contenir : 
**\-** Un **champ d’identifiant unique (insee\_com)**, permettant une **jointure attributaire** avec la couche d’étiquettes. 
**\-** Deux **champs de coordonnées** :  
o coordonnées\_X (longitude) 
o coordonnées\_Y (latitude) 
Ces valeurs sont obtenues grâce aux expressions suivantes dans la **calculatrice de champs** : 
***$x*** pour la coordonnée X 
***$y*** pour la coordonnée Y 
⚠️ **Attention** : Avant d’effectuer ces calculs, il est indispensable de **digitaliser les points**, de renseigner le champ **insee\_com** et de **positionner manuellement** chaque point à l’emplacement souhaité pour l’étiquette. 
**\- Jointure attributaire avec la couche d’étiquettes** 
Une fois la couche de points créée, une **jointure attributaire** est réalisée afin d’intégrer les champs coordonnées\_X et coordonnées\_Y dans la couche d’étiquettes. 
Grâce à ces coordonnées, les étiquettes des communes pourront être **positionnées précisément** à l’endroit des points définis. 
**\- Paramétrage de l’étiquetage** 
Sur la couche d’étiquettes, il est désormais possible de **définir le positionnement** en fonction des coordonnées des points obtenus via la jointure.  
**Astuce** : Il est important de cocher l’option **« Stocker les données dans le projet »** pour éviter des modifications non souhaitées si ces mêmes couches sont utilisées dans d’autres projets. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/160b094c-12f8-4baf-9a6c-1d9981a80e59" />

**Figure 16 :** Optimisation de la position des étiquettes sur la carte 
Ensuite, pour que l’étiquette de chaque commune se positionne correctement en fonction des coordonnées du point associé, il est nécessaire de **lier les champs de coordonnées** aux champs correspondants dans la couche d'étiquette (voir figure 15). Cela permettra d’ajuster automatiquement la position de chaque étiquette selon les points définis. 
**6.2. Méthode pour un positionnement optimal des cercles proportionnels** 
Le même processus utilisé pour le réglage des **étiquettes** s’applique également aux **cercles proportionnels**. 
Toutefois, dans ce cas, les ajustements de **positionnement** doivent être effectués directement dans les paramétrages **des diagrammes** (voir figure 16). Il est essentiel de définir correctement les coordonnées des cercles pour garantir une représentation claire et lisible sur la carte.  

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/124a5a50-00ff-4775-8655-6d884189a472" />

**Figure 17 :** Optimisation de la position des cercles proportionnels sur la carte 
## 7\. Avantages et mise à jour cartographique
Le fait que les données soient directement liées à la **base de données** permet une **mise à jour automatique** des cartes en fonction des nouvelles données disponibles. Ainsi, cette cartographie automatisée constitue un **socle dynamique et pérenne** pour l’actualisation des cartes, garantissant une cohérence et une fiabilité des informations pour toutes les entités concernées. 
Cependant, cette automatisation présente certaines **limites**, notamment pour la gestion des **étiquettes**, des **cartes graduées** et des **cercles proportionnels**, qui nécessitent parfois des ajustements manuels pour un affichage optimal.  
## 8 \- Les limites
La **pertinence cartographique** de certaines thématiques nécessite parfois de **dupliquer le projet QGIS** afin d’apporter des **modifications spécifiques**. Cela permet d’**optimiser la visualisation** tout en se concentrant sur un **territoire précis** (EPCI) parmi l’ensemble des entités cartographiées dans l’atlas. 
**\- Étiquettes** 
La gestion des **étiquettes** est particulièrement **complexe**, notamment dans le cas des **cartes avec cercles proportionnels**. Un problème récurrent est le **chevauchement des étiquettes**, surtout lorsque les entités concernées (communes, quartiers) sont de **petite taille**. 
De plus, l’utilisation d’une **couche spécifique pour positionner les étiquettes** peut s’avérer **fastidieuse**, en particulier lorsque l’atlas couvre un **grand nombre d’entités.** 
**\- Cartes à symbologie graduée** 
L’**échelle de répartition des classes** peut ne pas être adaptée à toutes les cartes de l’atlas, notamment en raison de **grands écarts entre les valeurs maximales et minimales**. Cela est souvent dû à la présence de **grandes villes**, comme **Perpignan** dans notre cas, qui influencent fortement la classification. 
Ainsi, il est **nécessaire d’ajuster les classes** en fonction du territoire étudié. Par exemple, pour l’**EPCI de Pyrénées Cerdagne**, il peut être pertinent de  
**revoir la classification** afin qu’elle soit plus représentative des données locales. 
Pour cela, il est recommandé **d’appliquer un filtre** en amont sur toutes les couches concernées. Cette méthode est **particulièrement efficace**, car elle **limite l’affichage des données** tout en **préservant l’ensemble des informations dans la même couche**. 
**\>** 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/478ed5c3-2143-45d6-869c-5f3ce9829bb9" />

**Figure 18 :** Filtrage des données selon le territoire d'intérêt 
**\- Cercles proportionnels** 
Comme mentionné précédemment, **l’échelle d’affichage des cercles proportionnels** dépend directement des **valeurs minimales et maximales** du champ représenté. Cependant, la présence de **grandes villes** peut entraîner des **valeurs extrêmes**, ce qui fausse l’échelle et réduit fortement la **taille des cercles** dans les territoires moins peuplés (population). 
Pour **corriger ce déséquilibre**, il est recommandé de **dupliquer le projet QGIS** et d’appliquer un **filtre sur le territoire d’intérêt**. Cela permet d’**ajuster les échelles de visualisation** spécifiquement en fonction des valeurs propres à ce territoire, sans être influencé par les données des autres zones couvertes par l’atlas.  
Il est également obligatoire de revoir la légende des cercles proportionnels en cas de modification des valeurs extrêmes, afin de mettre à jour leur libellé et d'assurer une représentation fidèle des données. 
## 9 \- Cas spécifique: atlas des flux pendulaire
Dans le cas des flux pendulaires, il est nécessaire de créer une nouvelle colonne à partir du champ "code" de la couche "Flux entrants". Voici les étapes à suivre dans QGIS : 
**Étapes dans QGIS** 
**Créer une nouvelle colonne `code_racine` (facultatif mais recommandé)** Dans la couche principale de ton atlas : 
○ Ouvre la calculatrice de champ. 
○ Créer un nouveau champ appelé code\_racine (type texte). ○ Utilise l'expression suivante pour extraire la partie avant le tiret du champ code : 
regexp\_substr("code", '^\[^-\]+') 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/2e13a654-6155-4967-b736-b0b5250f23c7" />

**Figure 19 :** Création de la colonne "code\_racine" pour regrouper les flux pendulaires 
**On pouvait aussi directement utiliser la colonne code\_epcilt.** �� **Activer l'atlas sur cette couche** 
Avant d'activer l'atlas, il est nécessaire de créer une couche regroupée à partir de la couche "Flux entrants" en utilisant la colonne `code_racine` afin d'éviter la répétition des occurrences. Ensuite, applique le filtre de l'atlas sur cette couche.  

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/494b225c-533a-4943-be62-c8ce3530f06b" />

**Figure 20 :** Activation de l’atlas à partir d’une couche regroupée par EPCI 
● Dans l'onglet Atlas, cocher Générer un atlas. 
● Sélectionne ta couche de couverture (couche regroupée) comme couche principale. 
● Dans Champ d’identifiant de page, choisis le champ code\_racin. 
**Filtrer les autres couches (dans les propriétés de chaque couche)** Pour appliquer un filtre basé sur code\_racine dans les autres couches (Flux\_entrants, Flux\_sortants et Flux\_internes) : 
● Va dans les Propriétés de chaque couche, dans l'onglet Filtre ou Rendu conditionnel. 
● Utilise l'expression suivante pour que chaque entité de la couche corresponde à l'atlas généré : 
regexp\_substr("code", '^\[^-\]+') \= @atlas\_pagename 
**\- Flèche du déplacement pendulaire** 
La taille des flèches est proportionnelle aux valeurs de la colonne concernée. La couche vectorielle est composée de lignes représentant les déplacements entre les points de départ (source) et d’arrivée (destination).  
**NB :** Les lignes peuvent être créées avec ***RStudio*** ou ***Python*** à partir d’une couche polygonale des communes contenant tous les champs nécessaires (flux, code\_insee, code\_insee\_destination, etc.). Dans ce cas, l’algorithme génère les lignes en reliant les centroïdes des communes, en utilisant code\_insee comme commune source et code\_insee\_destination comme commune de destination du flux. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/181cb91b-3a46-4cef-a0ba-15bf5e5fee1a" />

**Figure 21 :** Représentation des flux pendulaires par flèches proportionnelles 
Nous avons besoin d’une **couche de couverture spécifique pour l’atlas**, créée à partir d’un **regroupement par la colonne code\_epci** de la couche de lignes représentant les déplacements. Ce regroupement est nécessaire pour **éliminer les doublons** et ainsi **individualiser chaque EPCI** dans l’atlas. 
Cette couche de couverture, utilisée uniquement pour définir les territoires (EPCI), est **stockée localement** sur l’ordinateur et **n’est pas générée automatiquement**. 
En revanche, la couche contenant les **données de déplacement**, issue d’un  
fichier **SQL, Excel ou CSV**, reste **automatisée** : elle est **liée par jointure** à la couche de couverture via la colonne code\_commune. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/ed9a55bc-df81-4dc5-bf35-8991e5eacfe9" />

**Figure 22 :** Création d’une couche de couverture pour individualiser les EPCI dans l’atlas 
Comme pour les autres atlas, **un filtrage est appliqué sur cette couche pour n’afficher que l’entité active**, c’est-à-dire l’EPCI en cours de génération dans l’atlas. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/9a04af85-f0a0-44af-9954-83ac75151884" />

**Figure 23 :** Filtrage de l’entité active lors de la génération de l’atlas 
On peut également appliquer une symbologie avancée en faisant **varier la taille des symboles** grâce à un symbole gradué.  

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/eac7c2e1-4fe7-44f8-a846-8cb725810afb" />

**Figure 24 :** Application d’une symbologie avancée avec symboles gradués 
Il est possible d’attribuer une **taille de flèche** spécifique à chaque classe. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/a1275788-e438-4459-9c2a-5a80a749a23a" />

**Figure 25 :** Attribution de tailles de flèches spécifiques par classe 
N’oublie pas ensuite de basculer vers une symbologie par ensemble de règles afin d’ajuster précisément l’atlas. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/c2cb7124-ed2e-497d-9ea1-f8b1edd8c810" />

**Figure 26 :** Transition vers une symbologie par ensemble de règles pour un ajustement précis  
Le paramétrage de la taille des flèches ci-dessous ne sera plus nécessaire. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/8fc19a00-c7f3-4c0c-8f49-3a613ad8905e" />

**Figure 27 :** Suppression du paramétrage manuel de la taille des flèches 
Une fois sur la mise en page, la taille des flèches dans la légende ne correspond pas toujours à celle affichée sur la carte. Il est donc nécessaire d’ajuster manuellement la taille de chaque flèche dans la légende en personnalisant les valeurs de l’expression ci-dessous (même valeur lors de la symbolise).

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/351b9ffb-e9cd-441c-b165-a6a212a6b5d7" />

**Figure 28 :** Ajustement manuel de la taille des flèches dans la légende 
Veillez à utiliser les mêmes valeurs que celles définies dans la symbologie pour chaque flèche. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/a395ef87-03b2-42d0-9018-fa1e7ca43263" />

**Figure 29 :** Uniformisation des tailles des flèches entre symbole et légende 
**\- Flèche du déplacement pendulaire** 
La taille des flèches est proportionnelle aux valeurs de la colonne concernée. La couche vectorielle est composée de lignes représentant les déplacements entre les points de départ (source) et d’arrivée (destination).  
**NB :** Les lignes peuvent être créées avec ***RStudio*** ou ***Python*** à partir d’une couche polygonale des communes contenant tous les champs nécessaires (flux, code\_insee, code\_insee\_destination, etc.). Dans ce cas, l’algorithme génère les lignes en reliant les centroïdes des communes, en utilisant code\_insee comme commune source et code\_insee\_destination comme commune de destination du flux. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/7d95e01a-993b-4629-9343-862630c5ac8c" />

**Figure 30 :** Représentation des déplacements pendulaires par flèches proportionnelles 
Nous avons besoin d’une **couche de couverture spécifique pour l’atlas**, créée à partir d’un **regroupement par la colonne code\_epci** de la couche de lignes représentant les déplacements. Ce regroupement est nécessaire pour **éliminer les doublons** et ainsi **individualiser chaque EPCI** dans l’atlas. 
Cette couche de couverture, utilisée uniquement pour définir les territoires (EPCI), est **stockée localement** sur l’ordinateur et **n’est pas générée automatiquement**. 
En revanche, la couche contenant les **données de déplacement**, issue d’un  
fichier **SQL, Excel ou CSV**, reste **automatisée** : elle est **liée par jointure** à la couche de couverture via la colonne code\_commune. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/bd9ae216-0e6d-46a4-8867-8a2df09c159c" />

**Figure 31 :** Création et gestion d’une couche de couverture spécifique pour l’atlas des EPCI 
Comme pour les autres atlas, **un filtrage est appliqué sur cette couche pour n’afficher que l’entité active**, c’est-à-dire l’EPCI en cours de génération dans l’atlas. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/934268b6-68c0-4ed5-977b-b6eb782f4399" />

**Figure 32 :** Filtrage de la couche pour afficher l’entité active dans l’atlas 
On peut également appliquer une symbologie avancée en faisant **varier la taille des symboles** grâce à un symbole gradué.  

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/44cdc2f2-693f-4410-9a3d-b26d96f229d3" />

**Figure 33 :** Application d’une symbologie graduée pour varier la taille des symboles 
Il est possible d’attribuer une **taille de flèche** spécifique à chaque classe. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/d5ec06d3-2201-45fe-bf92-eb473c1fb9e9" />

**Figure 34 :** Attribution de tailles de flèches spécifiques par classe 
N’oublie pas ensuite de basculer vers une symbologie par ensemble de règles afin d’ajuster précisément l’atlas. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/1852fb25-3d9c-4355-91b4-8bdfb53a2dd6" />

**Figure 35 :** Passage à une symbologie par règles pour un ajustement précis de l’atlas 
Le paramétrage de la taille des flèches ci-dessous ne sera plus nécessaire. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/a246651d-9c20-40bc-9e49-86f6aad6ee20" />

**Figure 36 :** Fin du paramétrage manuel de la taille des flèches 
Une fois sur la mise en page, la taille des flèches dans la légende ne correspond pas toujours à celle affichée sur la carte. Il est donc nécessaire d’ajuster manuellement la taille de chaque flèche dans la légende en personnalisant les valeurs de l’expression ci-dessous (même valeur lors de la symbolise). 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/1af31c0a-3e26-481c-9c56-7f2517a3bd6f" />

**Figure 37 :** Ajustement manuel des tailles des flèches dans la légende  
Veillez à utiliser les mêmes valeurs que celles définies dans la symbologie pour chaque flèche. 

<img width="1" height="1" alt="image" src="https://github.com/user-attachments/assets/9e6f6c80-0270-408c-b745-b5115a511f55" />

**Figure 38 :** Correspondance des tailles des flèches entre symbole et légende 
**Conclusion** 
L’automatisation des atlas cartographiques dans QGIS permet de simplifier et d’optimiser la production de cartes en s’appuyant sur des règles de symbologie et des expressions dynamiques. Grâce à l’intégration de données directement issues d’une base de données SQL et à l’utilisation de  
filtres spatiaux et attributaires, il est possible de générer des cartes précises et adaptées à chaque entité étudiée. 
Toutefois, malgré ces avancées, certains défis persistent, notamment la gestion des étiquettes et des éléments graphiques complexes comme les cercles proportionnels. Ces aspects nécessitent encore des ajustements manuels pour garantir une lisibilité optimale des cartes produites. 
En définitive, cette méthodologie d’automatisation constitue un gain de temps considérable et améliore la cohérence des représentations cartographiques, tout en permettant une mise à jour continue des données. Cependant, une réflexion complémentaire sur l’optimisation des paramètres d’affichage reste essentielle pour perfectionner le rendu final et s’adapter aux spécificités de chaque territoire.
