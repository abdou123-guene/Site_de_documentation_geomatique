

   

**Table des matières**

**[I \- Présentation du projet	4](#i---présentation-du-projet)**

[a) Commande	4](#commande)

[b) Périmètre de travail	4](#périmètre-de-travail)

[c) Analyse des besoins	5](#analyse-des-besoins)

[c.1) Besoins en données	5](#c.1\)-besoins-en-données)

[c.2) Besoins organisationnels	6](#c.2\)-besoins-organisationnels)

[c.3) Besoin logiciels	6](#c.3\)-besoin-logiciels)

[d) Déroulement des travaux	6](#d\)-déroulement-des-travaux)

[e) Cadre législatif des données d’accessibilité	7](#e\)-cadre-législatif-des-données-d’accessibilité)

[e.1) La Loi d’Orientation des Mobilités (LOM)	7](#e.1\)-la-loi-d’orientation-des-mobilités-\(lom\))

[e.2) Le Cadre Juridique de la Voirie et des Espaces Publics	8](#e.2\)-le-cadre-juridique-de-la-voirie-et-des-espaces-publics)

[e.3) Interopérabilité : L’Arrêté du 28 Mai 2024	8](#e.3\)-interopérabilité-:-l’arrêté-du-28-mai-2024)

[f) Perspectives d’évolution	8](#f\)-perspectives-d’évolution)

[**II \- Etude des sources de données et analyse critique	9**](#ii---etude-des-sources-de-données-et-analyse-critique)

[a) Données GTFS (General Transit Feed Specification)	9](#données-gtfs-\(general-transit-feed-specification\))

[b) Standard CNIG “Accessibilité”	10](#standard-cnig-“accessibilité”)

[c) Analyse critique des modèles comparatives (MCD Travaux)	13](#analyse-critique-des-modèles-comparatives-\(mcd-travaux\))

[c.1) Le Modèle de la Ville de Paris	13](#c.1\)-le-modèle-de-la-ville-de-paris)

[c.2) Analyse du modèle “Rennes Métropole en accès libre” de  Rennes Métropole	13](#c.2\)-analyse-du-modèle-“rennes-métropole-en-accès-libre”-de-rennes-métropole)

[c.3) Analyse du modèle “Data Hub Métropole de Bordeaux” de Bordeaux Métropole	14](#c.3\)-analyse-du-modèle-“data-hub-métropole-de-bordeaux”)

[c.4) Analyse du modèle "Chantiers (ORION)" \- Toulouse Métropole	14](#c.4\)-analyse-du-modèle-"chantiers-\(orion\)"---toulouse-métropole)

[**III \- Contenu de la base de données	15**](#iii---contenu-de-la-base-de-données)

[a) Description des exigences générales	15](#description-des-exigences-générales)

[b) Modèles conceptuels de données	15](#modèles-conceptuels-de-données)

[b.1) Modèle de données général	15](#b.1\)-modèle-de-données-général)

[b.2) Modèle de données “Transport”	16](#b.2\)-modèle-de-données-“transport”)

[b.3) Modèle de donnée “Accessibilité”	19](#b.3\)-modèle-de-donnée-“accessibilité”)

[b.4) Modèle de donnée “travaux”	22](#b.4\)-modèle-de-donnée-“travaux”)

[c) Contrôle et qualité des données	23](#c\)-contrôle-et-qualité-des-données)

[c.1) Critères d’analyse de la qualité (norme ISO 19157\)	24](#c.1\)-critères-d’analyse-de-la-qualité-\(norme-iso-19157\))

[a) Contrôles de conformité au Modèle (MCD)	24](#contrôles-de-conformité-au-modèle-\(mcd\))

[b) Contrôle d’exhaustivité	24](#contrôle-d’exhaustivité)

[c) Qualité temporelle	25](#qualité-temporelle)

[c.2) Les contrôles spécifiques au calcul d'itinéraire	26](#c.2\)-les-contrôles-spécifiques-au-calcul-d'itinéraire)

[a) contrôles de cohérence topologique	26](#contrôles-de-cohérence-topologique)

[b) Précision de position (Altitudes et Pentes)	26](#précision-de-position-\(altitudes-et-pentes\))

[c.3) Outils de validation externe	27](#c.3\)-outils-de-validation-externe)

[**IV \- Structure des données	27**](#iv---structure-des-données) **Il**

[a) Choix d’implémentation	27](#choix-d’implémentation)

[b) Livraison informatique	28](#livraison-informatique)

[c) Implémentation physique	28](#implémentation-physique)

[c.1) Organisation en schémas	28](#c.1\)-organisation-en-schémas)

[c.2) Contraintes structurelles	28](#c.2\)-contraintes-structurelles)

[c.3) Contraintes de domaine et qualité des données	29](#c.3\)-contraintes-de-domaine-et-qualité-des-données)

[d) Représentation graphique	29](#représentation-graphique)

[e) Métadonnées	31](#e\)-métadonnées)

[e.1) Choix d’un outil ou plugin pour la gestion des métadonnées	31](#e.1\)-choix-d’un-outil-ou-plugin-pour-la-gestion-des-métadonnées)

[e.2) Outil utilisé pour les métadonnées	33](#e.2\)-outil-utilisé-pour-les-métadonnées)

[e.3) Contenu des métadonnées	33](#e.3\)-contenu-des-métadonnées)

[**V \- Administration et cycle de vie des données	34**](#v---administration-et-cycle-de-vie-des-données)

[a) Administration de la base de données	34](#administration-de-la-base-de-données)

[a.1)  Rôles et responsabilités	34](#a.1\)-rôles-et-responsabilités)

[a.2) Gestion des accès et privilèges	34](#a.2\)-gestion-des-accès-et-privilèges)

[a.3)  Intégration, mise à jour, sécurité	35](#a.3\)-intégration,-mise-à-jour,-sécurité)

[b) Sauvegardes et versionnement	35](#sauvegardes-et-versionnement)

[b.1) Sauvegardes quotidiennes	35](#b.1\)-sauvegardes-quotidiennes)

[b.2) Sauvegardes hebdomadaires : sauvegardes disque	36](#b.2\)-sauvegardes-hebdomadaires-:-sauvegardes-disque)

[b.3) Sauvegardes mensuelles : archivage longue durée	37](#b.3\)-sauvegardes-mensuelles-:-archivage-longue-durée)

[b.4) Versionnement	37](#b.4\)-versionnement)

[c) Cycle de vie des données	38](#c\)-cycle-de-vie-des-données)

[c.1) Planification	38](#c.1\)-planification)

[c.2) Acquisition	38](#c.2\)-acquisition)

[c.3) Vérification	38](#c.3\)-vérification)

[c.4) Validation	39](#c.4\)-validation)

[c.5) Intégration et réutilisation	39](#c.5\)-intégration-et-réutilisation)

[c.6) Archivage	39](#c.6\)-archivage)

[c.7) Retour à la planification	39](#c.7\)-retour-à-la-planification)

[Annexe n°1 : Convention de mise à disposition des données	40](#annexe-n°1-:-convention-de-mise-à-disposition-des-données)

[Annexe n°2 : Script SQL de création de la base de donnée	45](#annexe-n°2-:-script-sql-de-création-de-la-base-de-donnée)

# I \- Présentation du projet {#i---présentation-du-projet}

1) ## Commande {#commande}

L’agglomération de Losse-en-Gelaisse, en tant qu’Autorité Organisatrice de la Mobilité dans le cadre de la Loi d'Orientation des Mobilités (LOM[^1]), souhaite se doter d’un dispositif complet permettant de mieux exploiter et piloter ses données d’accessibilité de la voirie (données « outdoor »).

La collectivité souhaite développer un outil web destiné à :

* analyser les problématiques d’accessibilité du territoire ;  
* croiser les données d’accessibilité avec l’offre de transport et la densité de population;  
* identifier et hiérarchiser les zones prioritaires d’intervention ;  
* produire des cartographies thématiques adaptées aux besoins internes (services techniques, SIG, voirie) ;  
* proposer un mode de consultation simplifié pour des présentations à destination des associations de personnes à mobilité réduite.

L’outil devra être responsive (web et mobile), partiellement conforme au RGAA (niveau supérieur à 85 %) et conçu pour être réutilisable par d’autres territoires.

La collectivité souhaite également intégrer dans la solution web un module dédié au suivi des travaux sur la voirie, permettant notamment :

* la visualisation des zones de travaux sur la voirie ;  
* l’intégration d’une dimension temporelle (date de début, date de fin, état d’avancement) ;  
* la visualisation cartographique des impacts sur l’accessibilité ;  
* l’analyse croisée entre accessibilité existante et perturbations temporaires.

La collectivité demande également au prestataire d’être force de proposition pour la rédaction d’une convention encadrant la mise à disposition des données d’accessibilité.

2) ## Périmètre de travail {#périmètre-de-travail}

Le projet couvre des aspects techniques, méthodologiques et organisationnels liés à la mise en place et à l’exploitation d’une base de données géographiques dédiée à l’accessibilité.  
Le périmètre comprend notamment :

* l’analyse du MCD du standard CNIG Accessibilité afin d’évaluer son adéquation avec les besoins de l’outil web ;  
* la définition d’un MCD pour les zones de travaux, accompagnée d’une étude comparative des modèles utilisés par d’autres collectivités ;  
* la collecte, la structuration et l’intégration des données d’accessibilité dans une base PostgreSQL conforme au modèle CNIG ;  
* le développement d’un outil web open source dédié à l’exploration, à l’analyse et à la visualisation des données d’accessibilité, intégrant une interface responsive et conforme au RGAA ;  
* la mise en place d’une méthodologie de contrôle qualité des données, incluant des outils de vérification (conformité au modèle, cohérence spatiale, calculs de pente, détection d’anomalies) ;  
* la proposition d’enrichissements de la base de données par l’intégration de données complémentaires (démographie, réseau de transport, équipements publics) ;  
* la conception du cycle de vie des données ainsi que des mécanismes d’administration et de gestion des métadonnées afin de garantir la traçabilité et la pérennité de la base.

3) ## Analyse des besoins {#analyse-des-besoins}

L’analyse des besoins vise à identifier les ressources nécessaires à la mise en œuvre du projet, tant en termes de données que d’outils et d’organisation.

### 		c.1) Besoins en données {#c.1)-besoins-en-données}

La réalisation du projet nécessite l’accès à différents jeux de données permettant d’analyser l’accessibilité du territoire et d’alimenter la base de données géographiques.

Tout d’abord, un accès complet à la base de données PostgreSQL/PostGIS existante de la collectivité est indispensable. Cette base contient les données d’accessibilité déjà collectées et structurées selon le modèle du standard CNIG Accessibilité. L’accès aux modèles conceptuels de données (MCD) utilisés par la collectivité est également nécessaire afin de comprendre la structure actuelle de la base et de garantir la cohérence avec les futurs développements.

Des données complémentaires devront également être mobilisées afin d’enrichir l’analyse et de permettre les croisements de données demandés par la collectivité. Parmi celles-ci figurent notamment :

* des données LiDAR ou des Modèles Numériques de Terrain (MNT) permettant d’analyser les pentes et dévers de la voirie ;  
* des données satellitaires ou issues de télédétection pouvant servir à identifier certains éléments de la voirie, tels que les passages piétons ;  
* des données relatives au réseau de transport (arrêts, lignes, desserte) afin d’analyser l’accessibilité en lien avec l’offre de mobilité ;  
* des données démographiques, utiles pour croiser l’accessibilité avec la densité de population et identifier les zones prioritaires d’intervention ;  
* les données produites par les prestataires chargés de la collecte des données d’accessibilité, qui devront être intégrées et contrôlées dans la base de données.

  ### c.2) Besoins organisationnels {#c.2)-besoins-organisationnels}

Afin de garantir une bonne coordination entre les différents acteurs du projet, il est nécessaire de désigner un référent technique au sein de la collectivité ainsi qu’un référent au sein de l’entreprise prestataire en charge de la collecte des données. Ces interlocuteurs auront pour rôle de faciliter les échanges, de valider les choix techniques et d’assurer le suivi de la production et de la qualité des données.

Cette organisation permettra d’assurer une communication efficace entre les différentes parties prenantes et de sécuriser les différentes étapes du projet.

### 		c.3) Besoin logiciels {#c.3)-besoin-logiciels}

La mise en œuvre du projet nécessite l’utilisation de plusieurs outils spécialisés dans la gestion et le traitement des données géographiques. QGIS sera utilisé pour la visualisation et l’analyse des données. La base de données reposera sur PostgreSQL avec l’extension PostGIS, permettant le stockage et le traitement des données spatiales. Enfin, la modélisation des données sera réalisée avec Looping afin de concevoir les modèles conceptuels de données (MCD) nécessaires à la structuration de la base.

## d) Déroulement des travaux {#d)-déroulement-des-travaux}

Le déroulement de la mission s’articule en plusieurs phases successives :

- **Phase 1 : Cadrage du projet**  
* analyse du modèle CNIG Accessibilité ;  
* rédaction d’une convention de mise à disposition des données d’accessibilité.

-  **Phase 2 : Structuration et adaptation du modèle**  
* mise en place d’une base de données de travail sous PostgreSQL/PostGIS ;  
* analyse et éventuelle adaptation du modèle de données pour répondre aux besoins de l’outil web.

-  **Phase 3 : Définition de la méthodologie de contrôle qualité**  
* conception de règles de contrôle portant sur la conformité au modèle, la complétude et la cohérence spatiale des données ;  
* proposition d’outils d’analyse.

- **Phase 4 : Développement de l’outil web**  
* conception du back-office, du module de génération de cartographies et des interfaces de consultation ;  
* intégration des visualisations thématiques (accessibilité, zones de travaux) ;  
* réalisation de tests utilisateurs et ajustements.

-  **Phase 5 : Documentation et accompagnement**  
* rédaction de la documentation technique et fonctionnelle ;  
* formation des agents SIG et Voirie à l’administration de la base de données et à l’utilisation de l’outil web.

  ## e) Cadre législatif des données d’accessibilité {#e)-cadre-législatif-des-données-d’accessibilité}

La mise en place et la gestion des données d’accessibilité s’inscrivent dans un cadre réglementaire national visant à améliorer l’accessibilité des transports et de l’espace public, notamment pour les personnes à mobilité réduite.  
Plusieurs textes législatifs et réglementaires encadrent la collecte, la structuration et la diffusion de ces données afin de garantir leur interopérabilité et leur exploitation à l’échelle nationale.

Les principaux dispositifs juridiques applicables au projet sont présentés ci-dessous.

### e.1) La Loi d’Orientation des Mobilités (LOM) {#e.1)-la-loi-d’orientation-des-mobilités-(lom)}

La Loi d’Orientation des Mobilités (LOM), ou loi n°2019-1428 du 24 décembre 2019, constitue un texte structurant pour la politique nationale des transports. Elle vise notamment à améliorer l’accessibilité des mobilités et à favoriser le développement de solutions de transport plus durables et inclusives.  
Cette loi repose sur trois grands objectifs :

1. Investir plus et mieux dans les transports du quotidien, en priorisant l'entretien des réseaux et le désenclavement.  
2. Faciliter le déploiement de nouvelles solutions (covoiturage, navettes autonomes, transport à la demande) pour couvrir l'intégralité du territoire.  
3. Accélérer la révolution numérique et la transition écologique, afin de promouvoir une mobilité plus propre et connectée.

Dans ce cadre, la LOM impose également une meilleure structuration et diffusion des données de transport et d’accessibilité, afin de garantir leur interopérabilité et leur réutilisation dans différents services numériques.

Pour assurer cette cohérence à l’échelle nationale, plusieurs standards sont utilisés et encadrés par des groupes de travail spécialisés, notamment le GT7 de l’AFNOR dédié à l’information voyageurs. Parmi les principaux standards utilisés figurent :

* Norme NeTEx (CEN/TS 16614\) : Format d'échange européen de référence pour les données de transport.  
* Profil NeTEx Accessibilité France : Déclinaison nationale harmonisée permettant de décrire de manière harmonisée les informations des points d'arrêt, les véhicules et les services de transport.

  ### e.2) Le Cadre Juridique de la Voirie et des Espaces Publics {#e.2)-le-cadre-juridique-de-la-voirie-et-des-espaces-publics}

Le « premier et dernier kilomètre » constitue souvent la partie la plus critique du déplacement pour les personnes à mobilité réduite (PMR). Afin de garantir une continuité de l’accessibilité entre les transports et l’espace public, la réglementation impose également la prise en compte de la voirie dans la collecte des données d’accessibilité.  
L’article L.141-13[^2] du Code de la voirie routière étend ainsi l’obligation de collecte de données à l’environnement proche des points d’arrêt de transport. Selon l’article, les gestionnaires de voirie doivent décrire les itinéraires principaux situés dans un rayon de 200 mètres à vol d’oiseau autour des points d’arrêt prioritaires.  
Cet itinéraire est mesuré à partir de la surface au sol délimitant l’arrêt, ou depuis chaque porte d’accès dans le cas des gares ferroviaires et routières.

### e.3) Interopérabilité : L’Arrêté du 28 Mai 2024 {#e.3)-interopérabilité-:-l’arrêté-du-28-mai-2024}

L’arrêté du 28 mai 2024 vise à harmoniser les formats d’échange des données d’accessibilité et de transport à l’échelle nationale. Il consacre le standard NeTEx comme format de référence pour l’échange de ces données.

Dans ce cadre, les données d’accessibilité collectées sur la voirie selon le standard CNIG Accessibilité doivent pouvoir être converties vers le format NeTEx afin d’être exploitées par différents services numériques, notamment les calculateurs d’itinéraires. Cette conversion repose sur des passerelles permettant d’assurer l’interopérabilité entre les différents standards de données.

## f) Perspectives d’évolution {#f)-perspectives-d’évolution}

Plusieurs pistes d’évolution peuvent être envisagées afin d’améliorer et de faire évoluer la solution mise en place :

* interopérabilité avec les plateformes open data et les solutions régionales ;  
* intégration de flux de données en temps réel, tels que les informations relatives aux travaux en cours ou aux incidents impactant l’accessibilité ;  
* mise en place d’une API publique permettant la réutilisation des données et le développement d’applications par des acteurs tiers ;  
* contribution à l’évolution du standard national CNIG Accessibilité, notamment par des retours d’expérience et des propositions d’amélioration du modèle.

# II \- Etude des sources de données et analyse critique {#ii---etude-des-sources-de-données-et-analyse-critique}

1) ## Données GTFS (General Transit Feed Specification) {#données-gtfs-(general-transit-feed-specification)}

Le GTFS est une norme ouverte pour diffuser des données sur les systèmes de transport en commun. Cette norme comprend deux formats différents : le GTFS Schedule et le GTFS Realtime. Les données de transport de Losse-en-Gelaisse étant exportées en format GTFS Schedule, le modèle de données “Transport” a été conçu sur la base de ce format.

Le GTFS Schedule est un format commun pour les informations statiques sur les transports publics. Il est composé d’un ensemble de fichiers texte (.txt) contenu dans un seul fichier zippé (.zip). Les sept fichiers de base du format GTFS Schedule sont les suivants : `agency.txt`, `routes.txt`, `trips.txt`, `stops.txt`, `stop_times.txt`, `calendar.txt` et `calendar_dates.txt.` Des fichiers supplémentaires facultatifs peuvent également être ajoutés pour fournir par exemple des informations sur les tarifs ou les traductions.

La référence officielle GTFS [^3] a permis d’identifier le rôle de chacun de ces fichiers (Fig 1): 

* agency.txt regroupe les informations sur le service de transport (compagnies de transport, nom du réseau) ;  
* calendar.txt et calendar\_dates.txt qui contiennent le calendrier de circulation ;  
* routes.txt présente le nom et la direction des routes (terme anglais pour *lignes*, au sens d'une origine-destination) ;  
* stops.txt liste tous les points d'arrêt et propose d'éventuelles informations ;  
* trips.txt détaille les courses, sous la forme d'une table de liaison entre les services (agency), les routes et les régimes de circulation (calendar.txt et calendar\_dates.txt) ;  
* stops\_times.txt présente les horaires des courses aux points d'arrêt ;  
* transfers.txt présente les correspondances entre plusieurs points d'arrêt ;  
* shapes.txt permet le tracé d'une route sur une carte ;  
* frequencies.txt indique le temps entre deux courses d'une ligne (pour celles qui n'ont pas d'horaires fixes aux points d'arrêts) ;

Dans le cadre de ce projet, il a été convenu de considérer uniquement les fichiers du GTFS dont la présence est “Requise” et qui sont listés dans le tableau ci-dessous, issu de la documentation officielle du format.

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## Figure 1 : Definitions des champs ; General Transit Feed Specification 

2) ## Standard CNIG “Accessibilité”[^4] {#standard-cnig-“accessibilité”}

La base de données d’accessibilité fournie par la collectivité est structurée selon le standard CNIG Accessibilité et stockée dans une base PostgreSQL/PostGIS. Ce modèle constitue le socle de travail du projet. Le Conseil National de l’Information Géolocalisée (CNIG) propose des standards de structuration des données géographiques destinés à harmoniser les pratiques des collectivités et à faciliter l’échange de données. Le standard CNIG Accessibilité vise ainsi à décrire de manière homogène les éléments de voirie impactant l’accessibilité, tels que les cheminements piétons, les obstacles, les pentes ou les équipements urbains (Fig 2 et fig 3).  
Ce standard s’inscrit également dans le cadre plus large des politiques européennes d’interopérabilité des données géographiques, notamment la directive INSPIRE[^5], qui vise à faciliter le partage et la diffusion des données géographiques au sein de l’Union européenne.

## Figure 2 : MCD accessibilité VOIRIE (partie 1\) ; CNIG

## Figure 3 : MCD accessibilité VOIRIE (partie 2\) ; CNIG

Le choix de conserver ce modèle sans modification présente plusieurs avantages :

- **Conformité réglementaire**

L’utilisation du standard CNIG garantit l’alignement avec les recommandations nationales en matière de structuration des données d’accessibilité.

- **Interopérabilité des données**

 L’usage d’un modèle normalisé facilite :

* la réutilisation des données par d’autres collectivités ;  
* l’intégration dans des outils SIG couramment utilisés ;  
* l’échange de données avec différents prestataires.

Dans le contexte du projet, la collectivité souhaite que l’outil développé puisse être réutilisé par d’autres territoires. Le respect du standard CNIG constitue donc un levier essentiel d’interopérabilité.

- **Mutualisation et pérennité**

Le MCD du CNIG repose sur une structure stable et partagée, permettant de limiter les divergences de modélisation et de faciliter la maintenance de la base de données dans le temps.

Ainsi, ce modèle constitue une base fiable et pérenne pour la structuration et l’exploitation des données d’accessibilité dans le cadre du projet.

3) ## Analyse critique des modèles comparatives (MCD Travaux) {#analyse-critique-des-modèles-comparatives-(mcd-travaux)}

Pour construire notre MCD pour les zones de travaux , nous avons effectué une étude comparative des modèles existants : Open data Paris et Toulouse métropole.

### c.1) Le Modèle de la Ville de Paris[^6]  {#c.1)-le-modèle-de-la-ville-de-paris}

Paris utilise un modèle très granulaire qui sépare strictement l'entité administrative de l'entité géographique qui se présente comme suit : 

* **structure :** Utilisation d'un identifiant unique de "chantier" lié à plusieurs "emprises" géométriques.  
* **points Forts :** Permet une gestion temporelle extrêmement précise (date de début/fin par emprise) et une classification par maître d'ouvrage (Ville, concessionnaires de réseaux, tiers).  
* **critique :** Modèle complexe qui nécessite une interface de saisie robuste pour ne pas décourager les agents de terrain.

### c.2) Analyse du modèle “Rennes Métropole en accès libre” de  Rennes Métropole[^7] {#c.2)-analyse-du-modèle-“rennes-métropole-en-accès-libre”-de-rennes-métropole}

La métropole de Rennes a développé un outil de suivi des chantiers sur son territoire qui  se présente comme suit : 

* **Structure des données :** Le modèle est plus "léger" et se concentre sur l'information utile au citoyen (Qui fait quoi ? Jusqu'à quand ?).  
* **Géométrie :** Principalement linéaire  ce qui simplifie la lecture sur smartphone mais perd en précision sur l'emprise réelle du chantier au sol.  
* **Point fort :** Une interopérabilité maximale. Les données sont conçues pour être "aspirées" par des services tiers (Waze, Google, …).  
* **Point faible :** Moins de précision sur l'impact spécifique aux PMR.

### c.3) Analyse du modèle “Data Hub Métropole de Bordeaux”[^8] {#c.3)-analyse-du-modèle-“data-hub-métropole-de-bordeaux”}

Bordeaux s'appuie sur le logiciel *Litteralis*, qui transforme automatiquement les arrêtés de circulation signés par les élus en données géographiques.

* **Structure des données :** Le modèle est découpé en "Mesures" (ce que l'on impose : rue barrée, alternat, déviation).  
* **Géométrie :** C'est l'un des rares modèles à proposer une **triple géométrie native** (Point, Ligne, Polygone), ce qui valide exactement la structure de votre MCD.  
* **Point fort :** Une fiabilité juridique totale. Si un chantier est sur la carte, c'est qu'un arrêté officiel existe.  
* **Point faible :** Les données sont parfois "froides" et très administratives, moins orientées vers le ressenti de l'usager piéton.

### c.4) Analyse du modèle "Chantiers (ORION)" \- Toulouse Métropole[^9] {#c.4)-analyse-du-modèle-"chantiers-(orion)"---toulouse-métropole}

Le modèle toulousain se structure autour d'une fiche chantier synthétique avec une forte composante géographique.

* **Structure des données :**  
- **Identification :** **`numero`** (n° de demande), **`declarant`** (structure demandeuse), **`entreprise`** (réalisateur).  
- **Temporalité :** **`datedebut`**, **`datefin`** et surtout un champ **`duree`** (durée maximale de l'autorisation en jours).  
- **Description métier :** Un champ **`libelle`** très riche qui agrège la nature des travaux (ex: "Éclairage", "Voirie", "Aménagement de sécurité").  
* **Points forts**   
- **Richesse du champ `circulation` :** Précise les impacts réels (Alternat, occupation piste cyclable, occupation du trottoir).  
- **Mixité géométrique :** La présence de **`geo_shape`** permet de décrire aussi bien une tranchée linéaire qu'un périmètre de chantier ou un chantier ponctuel.  
- **Fréquence de mise à jour :** Actualisation quotidienne, essentielle pour un outil web performant.  
* **Point faibles** :   
- **Données textuelles :** Les impacts sur le trottoir sont dans un champ texte libre, ce qui rend l'analyse automatisée difficile.  
- **Manque de lien CNIG :** Il n'y a pas de lien direct avec les données d'accessibilité PMR.  
- **Pas de spécialisation :** Pas de distinction stricte entre point, ligne et surface dans la structure de la table.

# III \- Contenu de la base de données {#iii---contenu-de-la-base-de-données}

1) ## Description des exigences générales  {#description-des-exigences-générales}

Le cahier des charges identifie clairement plusieurs besoins supplémentaires : 

* représenter les zones de travaux ;  
* intégrer la dimension temporelle (début, fin, état d’avancement) ;  
* croiser accessibilité et transports ;  
* analyser les zones prioritaires en lien avec la densité de population.   

Le MCD du CNIG ne prévoit naturellement aucune structure pour modéliser :   

* les travaux ;  
* les lignes ou arrêts GTFS ;  
* les perturbations temporaires ;  
* les impacts sur la mobilité. 

C’est pourquoi deux schémas complémentaires ont été créés.

2) ## Modèles conceptuels de données  {#modèles-conceptuels-de-données}

   ### b.1) Modèle de données général {#b.1)-modèle-de-données-général}

Le modèle conceptuel de données (MCD) retenu pour ce projet est composé de trois volets (Fig 4\) :

* le MCD du standard CNIG Accessibilité, déjà mis en œuvre par la collectivité ;  
* le MCD Travaux, modélisant les chantiers et leurs impacts ;  
* le MCD Transports, dérivé des données GTFS.

Cette architecture modulaire répond directement aux besoins exprimés par Losse‑en‑Gelaisse dans le cadre du développement d’un outil web dédié à l’analyse de l’accessibilité, de la mobilité et de la population.

## Figure 4 : MCD général 

### b.2) Modèle de données “Transport” {#b.2)-modèle-de-données-“transport”}

Les données concernant le réseau de transport public sont essentielles en complément des données d’accessibilité car elle permettent de mettre en place les fonctionnalités suivantes :

* mesurer l’accessibilité aux arrêts (rayon de 200 m),  
* analyser la desserte par ligne,  
* évaluer l’impact des travaux sur les arrêts et les itinéraires,  
* produire des cartes thématiques adaptées aux besoins internes.

Le MCD Transport complète donc le CNIG en apportant une véritable dimension mobilité.

Le MCD présenté synthétise l’organisation des services de transport en commun, sur la base du format GTFS Schedule. Il repose sur cinq entités principales liées par des relations de service, de temps et de hiérarchie spatiale. Nous avons choisi d’indiquer les noms des entités et de leurs attributs en anglais pour garder une cohérence avec la nomenclature internationale du GTFS (Fig 5).

![][image1]

## Figure 5 : MCD “Transport”

## Ce modèle de données comporte les entités suivantes :

* ## **AGENCY (Agence) :** Elle identifie l'autorité organisatrice ou l'entreprise de transport. Elle contient les données administratives comme le nom, l'URL et le fuseau horaire de référence.

* ## **ROUTE (Ligne) :** Elle correspond à une ligne de transport (ex: "Ligne 1" ou "Métro B"). Elle regroupe les caractéristiques génériques de la ligne, notamment son nom et son mode de transport.

* ## **TRIP (Trajet) :** C'est l'unité centrale de l'offre de transport. Un trajet représente un passage spécifique d'un véhicule sur une ligne, identifié par une direction et une destination.

* ## **CALENDAR (Calendrier) :** Cette entité gère la temporalité de l'offre. Elle définit les jours de circulation (du lundi au dimanche) ainsi que la période de validité globale (dates de début et de

* ##  fin).

* ## **STOP (Arrêt) :** C'est l'entité géographique. Elle stocke la localisation précise (latitude et longitude) et le nom de chaque point d'arrêt ou station du réseau.

## Les associations suivantes dictent comment les entités interagissent entre-elles dans le modèle conceptuel de données :

* ## **Gérer (AGENCY \- ROUTE) :** Une agence peut gérer plusieurs lignes (**1,n**), mais une ligne peut théoriquement être partagée ou dépendre de plusieurs agences (**0,n**).

* ## **Composer (ROUTE \- TRIP) :** Une ligne est composée de plusieurs trajets étalés sur la journée (**1,n**). À l'inverse, un trajet est obligatoirement rattaché à une seule et unique ligne (**1,1**).

* ## **Planifier (CALENDAR \- TRIP) :** Cette relation associe chaque trajet à son calendrier d'exploitation. Un calendrier peut s'appliquer à une multitude de trajets (**1,n**), tandis qu'un trajet suit un planning unique (**1,1**).

* ## **Desservir (TRIP \- STOP) :** Il s'agit d'une **association porteuse de données**. Elle fait le lien entre le mouvement (le trajet) et l'espace (l'arrêt). Cette association correspond au fichier **`stop_times.txt` dans le format GTFS**.

  * *Attributs spécifiques :* Elle un identifiant (**`stop_sequence`**) qui correpspond à la combinaison de l’identifiant de TRIP et de l’identifiant de STOP. Les attributs contiennent également les horaires précis (**`arrival_time`**, **`departure_time`**). Un trajet dessert plusieurs arrêts (**1,n**) et un arrêt est desservi par plusieurs trajets (**1,n**).  
* **Etre\_parent\_de (STOP \- STOP) :** C'est une **relation réflexive** (un arrêt lié à un autre arrêt).  
  * *Utilité :* Elle permet de créer une hiérarchie spatiale. Un arrêt "enfant" (par exemple un quai) peut être rattaché à un arrêt "parent" (une station ou une gare globale). Un arrêt enfant n'a qu'un seul arrêt parent (**0,1**), mais un arrêt parent peut avoir plusieurs arrêts enfants (**0,n**).

  ### b.3) Modèle de donnée “Accessibilité”  {#b.3)-modèle-de-donnée-“accessibilité”}

Le présent modèle a été élaboré sur la base du standard CNIG relatif à l’accessibilité. Il a été complété et enrichi par l’intégration d’une table « Carroyage », spécifiquement ajoutée afin de répondre aux besoins méthodologiques de cette étude (Fig 6).

L’objectif principal est d’analyser le niveau d’accessibilité ainsi que les différentes formes qu’elle revêt sur le territoire de la commune de Losse-en-Gelaisses. Cette démarche vise également à identifier et localiser les secteurs où ces dispositifs d’accessibilité sont présents, avec une attention particulière portée aux quartiers prioritaires.

## 

## Figure 6 : MCD “Accessibilité”

## Ce modèle de données comporte les entités suivantes :

* **CHEMINEMENT (Cheminement) :** Cette entité représente un itinéraire entre deux points ou un parcours piéton structuré au sein du territoire étudié. Elle constitue une unité logique regroupant plusieurs tronçons successifs formant un parcours continu.  
* **TRONCON\_CHEMINEMENT (Tronçon de cheminement)** : Il s’agit de l’unité linéaire élémentaire composant un cheminement. Chaque tronçon est défini par ses caractéristiques géométriques (longueur, géométrie) et physiques (type, pente, dévers, statut de voie, accessibilité globale). Il est délimité par un nœud initial et un nœud final.  
* **NOEUD (Nœud)** : Cette entité correspond à un point géographique structurant du réseau (intersection, extrémité de tronçon, point d’accès). Elle stocke des informations altimétriques et fonctionnelles liées à l’accessibilité (abaissés de trottoir, bandes d’éveil, dispositifs de perception, etc.).  
* **OBSTACLE (Obstacle)** : Cette entité recense les éléments ponctuels susceptibles d’entraver la circulation (mobilier urbain, poteaux, etc.). Elle précise leurs dimensions, leur position et leur niveau de repérabilité visuelle.  
* **CIRCULATION (Zone de circulation)** : Cette entité décrit les espaces dédiés au déplacement sur une surface régulière (trottoirs, voies partagées, etc.). Elle contient des informations sur le revêtement, la largeur utile, l’éclairage, la transition ou encore le type de passage.  
* **TRAVERSEE (Traversée piétonne)** : Elle modélise les dispositifs permettant de franchir une voie (passage piéton). Les attributs décrivent l’état du revêtement, la signalisation, la présence de dispositifs sonores ou lumineux et la visibilité.  
* **RAMPE (Rampe d’accès)** : Cette entité caractérise les plans inclinés facilitant le franchissement d’un dénivelé. Elle intègre des informations sur la largeur, les dispositifs de sécurité (chasse-roue, palier de repos), la main courante et le poids supporté.  
* **ESCALIER (Escalier fixe)** : Elle décrit les escaliers classiques. Les attributs précisent le nombre de marches, la hauteur et le giron, la présence de mains courantes, les contrastes visuels et les dispositifs de vigilance.  
* **ESCALATOR (Escalier mécanique)** : Cette entité correspond aux escaliers mécaniques. Elle renseigne le sens de fonctionnement, la largeur utile, les dispositifs de détection et de supervision.  
* **TAPIS\_ROULANT (Tapis roulant)** : Elle modélise les dispositifs mécaniques horizontaux facilitant le déplacement. Les caractéristiques portent sur le sens, la largeur et les dispositifs de sécurité.  
* **QUAI (Quai)** : Cette entité représente un équipement d'un mode de transport permettant un accès au véhicule. Elle précise la hauteur, la largeur de passage, la signalisation et les espaces de manœuvre.  
* **ENTREE (Entrée d’établissement ou de bâtiment)** : Elle décrit les points d’accès aux bâtiments. Les attributs détaillent les équipements d’accessibilité (rampe, ascenseur, poignée, largeur de porte, signalétique, contrôle d’accès, etc.).  
* **PASSAGE\_SELECTIF (Passage sélectif)** : Cette entité représente le dispositif permettant le passage des piétons, mais dissuadant celui des cycles et des engins motorisés . Elle précise les dimensions, la profondeur et le repérage visuel.  
* **ELEVATEUR (Élévateur PMR)** : Elle modélise le système de franchissement d'une dénivellation muni d'une plate-forme ou d'une nacelle. Les attributs décrivent les dimensions, la charge maximale, les dispositifs de sécurité et l’autonomie d’utilisation.  
* **ASCENSEUR (Ascenseur)** : Cette entité décrit les ascenseurs classiques. Elle comprend les dimensions de cabine, les équipements (miroir, boutons en relief, annonces sonores, éclairage) et les dispositifs d’assistance.  
* **STATIONNEMENT\_PMR (Stationnement réservé PMR)** : Elle recense les places de stationnement adaptées aux personnes à mobilité réduite. Les attributs précisent les dimensions, la pente, la signalisation et le marquage au sol.  
* **CARROYAGE (Carroyage)** : Cette entité, issue des données de l’INSEE, représente une grille de 200 mètres de côté couvrant l’ensemble du territoire français. Chaque carreau renseigne le nombre d’individus qu’il contient, ainsi qu’une répartition par tranche d’âge. Ce carroyage permet d’analyser l’accessibilité du territoire et d’identifier les zones prioritaires.

Chaque cheminement est composé de un ou plusieurs tronçons (1,n), ce qui signifie qu’un cheminement n’existe que s’il comporte au moins un tronçon, et qu’un tronçon appartient à un et un seul cheminement (1,1). De même, chaque tronçon possède un nœud initial et un nœud final (1,1), tandis qu’un même nœud peut être partagé par plusieurs tronçons (0,n), ce qui permet de modéliser un réseau. 

Les cardinalités décrivent aussi la relation entre les tronçons et les éléments d’accessibilité. Un tronçon peut comporter zéro, un ou plusieurs obstacles, circulations ou équipements (rampe, escalier, escalator, tapis roulant, quai, etc.) (0,n), tandis qu’un obstacle ou un équipement est toujours rattaché à un seul tronçon (1,1) . Cela signifie qu’on peut représenter un tronçon sans obstacle, mais qu’un obstacle isolé sans tronçon n’a pas de sens dans le modèle. 

Les entités liées aux entrées, ascenseurs, élévateurs ou stationnements PMR sont connectées à des nœuds avec des cardinalités du type (0,n) côté nœud et (1,1) côté équipement : un nœud peut donner accès à plusieurs dispositifs, mais chaque dispositif est localisé sur un nœud unique. Ces cardinalités garantissent la cohérence spatiale du modèle en imposant qu’un équipement d’accessibilité soit toujours positionné sur un point du réseau.

Enfin, l’entité CARROYAGE permet d’associer au réseau des informations de population, utiles pour les futures analyses de densité et l’identification des quartiers prioritaires. Un carreau de carroyage est relié à l’entité NOEUD par une cardinalité (0,n), ce qui signifie qu’un carreau peut contenir zéro, un ou plusieurs nœuds. Réciproquement, chaque nœud est associé à un unique carreau par une cardinalité (1,1), indiquant qu’un nœud ne peut appartenir qu’à un seul carreau. 

### b.4) Modèle de donnée “travaux” {#b.4)-modèle-de-donnée-“travaux”}

Le modèle conceptuel de données (MCD) dédié aux zones de travaux a pour objectif de décrire les chantiers impactant la voirie et susceptibles d’affecter l’accessibilité des cheminements piétons. Il permet de structurer les informations relatives aux travaux afin de faciliter leur intégration dans la base de données et leur exploitation dans l’outil web.  
Dans ce modèle, les chantiers sont représentés sous forme de géométries surfaciques (polygones) permettant de localiser précisément les zones concernées. Le MCD intègre également une dimension temporelle, à travers des attributs décrivant les dates de début et de fin des travaux, les différentes phases du chantier ainsi que leur état d’avancement.  
Chaque chantier à un organisme responsable, ce qui permet d’identifier l’acteur en charge des travaux et de faciliter le suivi administratif. Le modèle prévoit également la description des impacts potentiels sur l’accessibilité, notamment pour les personnes à mobilité réduite.

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## Figure 7 : MCD “Travaux”

Pour rendre les données exploitable , nous les avons organisées en quatre blocs (Fig 7\) : 

* le bloc administratif ( table **projet\_travaux**): elle renseigne sur l’identité du chantier , le prestataire et sur la personne à contacter en cas d’urgence, le contact ici peut être un numéro de téléphone ou un mail.

* le bloc temporel ( table **zone** ): c’est la table centrale du modèle qui permet le suivi. Pour chaque chantier , nous enregistrons la date de début et de fin , ce qui permettra aux élus d’avoir une carte de  l'état de l'agglomération à n'importe quelle date. Le champ statut sera constitué d’une liste déroulante ( prévu, en cours, terminé) qui permettra d’avoir un idée sur l'état d’avancement de chaque chantier.

* le bloc géographique ( tables **travaux**): nous dessinerons les travaux dans des tables géométriques en fonction de leurs natures. Ces dessins seront le plus précis possible pour ne pas bloquer inutilement des itinéraires de bus ou des trottoirs.

* le bloc accessibilité ( table **impact**): le modèle propose une table dédiée aux personnes à mobilité réduites , nous ne nous contenterons pas de dire seulement s’il y a des travaux ,  nous renseignerons également les impacts de ses travaux sur le déplacement des PMR et s’il y a des recommandations de déviation qui ont été mis en place.

Ce MCD pourra être facilement relié aux données GTFS via des requêtes spatiales qui seront utiles dans notre web-sig. On pourra par exemple informer les utilisateurs grâce à des alertes : *"Votre arrêt de bus est déplacé de 50m car une zone de travaux bloque le passage piéton".* 

## c) Contrôle et qualité des données  {#c)-contrôle-et-qualité-des-données}

Les principaux objectifs liés à la qualité des informations géographiques nécessaires à l’accessibilité de la chaîne de déplacement reposent sur plusieurs dimensions essentielles. Il s’agit tout d’abord de garantir la précision géométrique des données, afin d’assurer une représentation fidèle des éléments du réseau. La qualité topologique constitue également un enjeu majeur, dans la mesure où elle permet d’assurer la cohérence des relations spatiales entre les objets et de rendre possible le calcul d’itinéraires fiables et pertinents.

Par ailleurs, une attention particulière doit être portée à la qualité descriptive des informations, qui permet de caractériser avec précision l’accessibilité de la chaîne de déplacement. Enfin, les données doivent respecter le modèle de données et le catalogue d’objets définis le standard CNIG , garantissant ainsi leur cohérence et leur interopérabilité.

Nous proposons divers contrôles qui ont pour but de vérifier la fiabilité des données intégrées par les prestataires lors des phases de collecte. Ces vérifications reposent sur deux principaux critères : d’une part, les critères d’analyse de la qualité définis par la norme ISO 19157 d’autre part, des contrôles spécifiques liés au calcul d’itinéraires, permettant de garantir la cohérence et l’exploitabilité des données dans les outils de calcul d’itinéraire.

### 		c.1) Critères d’analyse de la qualité (norme ISO 19157\) {#c.1)-critères-d’analyse-de-la-qualité-(norme-iso-19157)}

#### Contrôles de conformité au Modèle (MCD) {#contrôles-de-conformité-au-modèle-(mcd)}

Ce contrôle relève de la qualité interne. Il s'agit de mesurer l'écart entre la donnée livrée par le prestataire et le standard **CNIG Accessibilité** .

* **Cohérence de format :** Vérifier que les tables possèdent les bons noms de colonnes, types (Integer, Varchar….) et encodages (UTF-8).

- outil : une inspection minutieuse du schéma postgreSQL ou une Commande ogrinfo nous permettront de déceler d'éventuelles anomalies.

* **Cohérence au domaine de valeur :** Les champs dont nous avons établies des listes prédéfinies doivent être respectés car une  analyse thématique peut être basée sur ces champs dans notre outil. Si ces champs sont remplis par des données hors liste, notre analyse thématique sera fausse.

- outil : Mettre en place des requêtes SQL pour identifier les valeurs hors liste (valeurs aberrantes).

- indicateur : **taux de non-conformité au domaine de valeur**.

- exemple métier : si un prestataire saisit "trotoir" au lieu de "trottoir", l'outil web ne pourra pas filtrer correctement les données.

* **Précision Sémantique :** Contrôle de l'invariance des identifiants . Il est important de veiller à ce que les identifiants des objets communs à plusieurs tables (tels que les tronçons de cheminement , les nœuds,etc...) restent constants pour l' ensemble des données afin d' assurer la bonne calculabilité des itinéraires de cheminement.

#### Contrôle d’exhaustivité {#contrôle-d’exhaustivité}

Le contrôle d’exhaustivité nous permettra de détecter s’il y a des omissions ou des excédents dans les données intégrées par les prestataires. Ce contrôle nous permettra de valider les données si elles sont dans le seuil de la LAQ ou de les rejeter si elles en sont hors. Un exemple de contrôle d’exhaustivité .

Ce contrôle mesure l'adéquation entre la couche “passages\_piétons” livrée par le prestataire (le **Lot à contrôler**) et la couche extraite par télédétection (le **Référentiel de contrôle**).

On distingue deux types d'erreurs : 

* **L'omission :** un passage piéton détecté sur l'image mais absent de la base du prestataire. (Risque : itinéraire impossible pour l'usager).   
* **L'Excédent :** un passage piéton saisi par le prestataire mais non détecté sur l’image (peut être une erreur de saisie ou un marquage effacé).

- outil : pour comparer ces deux sources, on utilise une méthode de croisement géographique (sous QGIS ou PostGIS). On crée une zone de tolérance (Buffer), on applique un tampon de 2 à 3 mètres autour des géométries du référentiel (télédétection) pour absorber les légers écarts de saisie. Ensuite on effectue une jointure spatiale pour avoir des données conformes, omises ou excédentaires.

- indicateur : on calcul alors le taux d’exhaustivité en appliquant la formule suivante[^10]: T \= 1 \- Nb Omissions \+ Nb Excédents /Nb Passages détectés par télédétection.

- analyse et seuil d'acceptation (LAQ) : Nous exigeons pour le calcul des itinéraires des PMR un seuil d’acceptation à 98% , un taux d’exhaustivité supérieur à 2 % rend la donnée non conforme. Le prestataire devra donc corriger sa saisie. 

#### Qualité temporelle {#qualité-temporelle}

Ce critère assure que la donnée est "fraîche" et cohérente chronologiquement, surtout pour la gestion des zones de travaux.

* **Exactitude de la mesure temporelle :** Vérifier que les dates de relevés terrain sont cohérentes (ne peuvent pas être postérieures à la date de livraison).

* **Cohérence temporelle :** Pour les arrêtés de travaux qui bloquent l'accessibilité :

- contrôle de la règle : Date\_Debut \< Date\_Fin.

- vérifier que les dates sont au format ISO (AAAA-MM-JJ) pour être traitées par l'outil web.

* **Validité temporelle :** S'assurer que les données historiques (anciens aménagements avant travaux) sont bien archivées ou marquées comme obsolètes pour ne pas fausser le calcul d'itinéraire actuel.

  ### c.2) Les contrôles spécifiques au calcul d'itinéraire {#c.2)-les-contrôles-spécifiques-au-calcul-d'itinéraire}

#### contrôles de cohérence topologique {#contrôles-de-cohérence-topologique}

Les contrôles de cohérence topologique représentent une étape essentielle pour garantir le bon fonctionnement du modèle de calcul d’itinéraires. En effet, une donnée peut sembler correcte d’un point de vue visuel tout en étant techniquement exploitable si les segments du réseau ne sont pas correctement connectés.

* **Connectivité :** Vérifier que tous les segments de voirie (trottoirs, passages piétons) sont parfaitement accrochés. Une erreur de quelques centimètres empêche l'algorithme de trouver un chemin.  
  \- outil : nombre de nœuds isolés ou de connexions manquantes.  
* **Absence de chevauchements et d'auto-intersections :** Deux surfaces (ex: deux zones de trottoirs) ne doivent pas se superposer.  
  \- outil : **vérificateur de topologie QGIS** (Règles :  "ne doit pas se chevaucher").  
* **Indice de compacité et d'épaisseur:**

On utilisera le coefficient d'épaisseur E \= 2 (Surface) / (Périmètre) pour détecter les "résidus" de numérisation ou les polygones trop étroits (\< 0.5m) qui ne correspondent pas à une réalité physique de cheminement PMR.

#### Précision de position (Altitudes et Pentes) {#précision-de-position-(altitudes-et-pentes)}

Dans le cadre de l'accessibilité, la précision Z (altitude) est plus critique que la précision XY. Une erreur de 5% de pente change radicalement l'accessibilité d'un tronçon surtout pour les fauteuils roulants.

* Contrôle Altimétrique via LiDAR / MNT :

Nous allons comparer les données collectées avec les  données issus du  LiDAR ou MNT. On échantillonne des tronçons. Pour chaque tronçon, on compare la pente saisie par le prestataire avec la pente calculée mathématiquement à partir du MNT (Modèle Numérique de Terrain). En suivant le standard du CNIG, nous imposons un un écart admissible de 3% , au-delà de ce seuil, la donnée est considérée comme fausse.

* Précision de position absolue :

On mesurera  l'écart (en mètres) entre des objets fixes saisis (ex: potelets, bordures) et le PCRS (Plan Corps de Rue Simplifié) si l'agglomération en dispose.

### 		c.3) Outils de validation externe {#c.3)-outils-de-validation-externe}

Afin de garantir la qualité, la cohérence et l’interopérabilité des données produites, plusieurs outils de validation externe sont mobilisés. Ces outils permettent de vérifier la conformité des données de transport et de s’assurer qu’elles respectent les standards d’échange notamment le GTFS largement utilisé pour la diffusion et l’exploitation des données de mobilité.

* **Données de transport (GTFS)** : Les données relatives aux transports sont validées à l’aide d’outils de contrôle dédiés au format GTFS. Ces validateurs permettent de vérifier la conformité de la structure des fichiers, la cohérence des identifiants ainsi que l’intégrité des informations relatives aux arrêts, aux lignes et aux horaires. L’objectif est de garantir la qualité des données et leur compatibilité avec les plateformes de diffusion de données de transport.

* **Interopérabilité GTFS** : Une attention particulière est portée à la cohérence des identifiants et à la structure des données afin de faciliter leur intégration dans les différents outils de calcul d’itinéraires et applications de mobilité. L’utilisation du standard GTFS permet ainsi d’assurer 

# [I](#iii---contenu-de-la-base-de-données)V \- Structure des données {#iv---structure-des-données}

1) ## Choix d’implémentation {#choix-d’implémentation}

Pour répondre aux exigences de la commande, le choix s’est porté sur le couple **PostgreSQL**, pour la gestion de la base de données relationnelle, et son extension spatiale **PostGIS**. Ce choix est stratégique pour plusieurs raisons :

* **Interopérabilité :** Les données d'accessibilité déjà collectées par la collectivité sont actuellement stockées sous PostgreSQL selon un modèle conforme au standard CNIG Accessibilité. L'utilisation de ce même SGBD garantit une transition fluide.

* **Capacités de traitement spatial :** Le projet nécessite des analyses complexes, telles que l'identification de zones d'intervention prioritaires. L'extension PostGIS offre les fonctions géométriques et topologiques nécessaires pour ces calculs.

* **Open Source :** L'agglomération exige que l'outil web et les outils de contrôle soient entièrement **open source** afin d'être mutualisables avec d'autres territoires. PostgreSQL étant le leader des SGBD libres, il est parfaitement adapté pour répondre aux besoin de ce projet.

2) ## Livraison informatique {#livraison-informatique}

Le cœur de la livraison repose sur la fourniture d’un script SQL à l’agglomération de Losse-en-Gelaisse pour garantir le déploiement opérationnel de la solution. 

Ce script assure :

* **la création des schémas :** l'isolation des données en trois domaines distincts : **`accessibilite`**, **`transport`** et **`travaux`** ;

* **la structuration des tables :** La création de l'ensemble des tables nécessaires (ex: **`transport.STOP`**, **`accessibilite.Troncon_Cheminement`**, **`travaux.zone`**) avec un typage de données strict ;

* **l'implémentation des contraintes :** La mise en place des clés primaires, des clés étrangères pour la cohérence relationnelle et des contraintes d'unicité (ex: lien unique entre un nœud et une entrée d'ERP).

Le script SQL complet est consultable en annexe (annexe n°2).

3) ## Implémentation physique {#implémentation-physique}

### c.1) Organisation en schémas {#c.1)-organisation-en-schémas}

Pour assurer une gestion structurée et sécurisée des accès multi-utilisateurs, la base de données est organisée en **trois schémas distincts**, correspondant aux domaines thématiques du projet :

* **accessibilité :** contient l'intégralité du socle conforme au standard CNIG (tronçons, nœuds, obstacles, cheminements) ;

* **transport :** contient les données de l'offre de transport au format GTFS (arrêts, lignes, calendriers) ;

* **travaux :** gère le suivi temporel et géographique des chantiers impactant la voirie.

### c.2) Contraintes structurelles {#c.2)-contraintes-structurelles}

* **clés primaires (PRIMARY KEY) :** Chaque table dispose d'un identifiant unique (ex: **`idTroncon`**, **`stop_id, Id_zone`**) garantissant l'unicité de chaque objet.

* **clés étrangères (FOREIGN KEY) :** Elles assurent la **cohérence relationnelle** entre les tables. Par exemple, un **`Noeud`** d'accessibilité ne peut exister que s'il est rattaché à un **`Troncon_Cheminement`** valide via une clé étrangère. De même, la table de liaison **`donner_acces_a`** assure le pont technique entre le monde du transport (**`stop_id`**) et celui de l'accessibilité (**`idNoeud`**).

* **contraintes d'unicité (UNIQUE) :** Pour les relations de type 1:1, comme entre un nœud et une entrée d'ERP, une contrainte **`UNIQUE`** est appliquée sur la clé étrangère pour empêcher qu'une même entrée ne soit rattachée à plusieurs nœuds.

* **contraintes de non-nullité (NOT NULL) :** Les champs critiques, notamment les géométries (**`geom`**) et les identifiants de liaison, sont paramétrés en **`NOT NULL`** pour éviter les données inexploitables d’un point de vue spatial.

### c.3) Contraintes de domaine et qualité des données {#c.3)-contraintes-de-domaine-et-qualité-des-données}

Pour garantir que les données saisies sont conformes aux attentes métiers (standard CNIG), des **contraintes de domaine** sont définies :

* **typage de données strict :** Utilisation de types adaptés comme **`DOUBLE PRECISION`** ou **`REAL`** pour les mesures physiques (pentes, largeurs), **`BOOLEAN`** pour les équipements (présence d'ascenseur) et **`DATE`** pour la gestion temporelle des travaux.

* **standardisation des listes de valeurs :** L'utilisation de types énumérés (ex: **`geostandard.enum5`**) pour des champs comme l'état du revêtement ou la présence de dispositifs de vigilance permet de forcer la saisie de valeurs prédéfinies, empêchant ainsi les erreurs de saisie manuelle.

* **intégrité spatiale :** Les géométries sont contraintes par des types spécifiques (ex: **`POLYGON`** pour les zones de travaux) et associées au système de référence spatial **SRID 2154** (Lambert 93).

4) ## Représentation graphique {#représentation-graphique}

A partir des modèles conceptuels de données et des différentes contraintes déjà présentés, un schéma relationnel de base de donnée a été réalisé, montrant l'organisation physique des tables et assurant que la base soit opérationnelle et exploitable. Les tables, colonnes, clés primaires et relations qui composent la base sont exposées ci-dessous (Fig 8, 9 et 10).

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

##                           Figure 8 : Modèle relationnel du schéma “Travaux”

##    Figure 9 : Modèle relationnel du schéma “Transport”

## Figure 10 : Modèle relationnel du schéma “Accessibilité”

## e) Métadonnées {#e)-métadonnées}

Les métadonnées jouent un rôle fondamental dans la gestion de l’information au sein du projet Losse‑en‑Gelaisse. Elles garantissent la traçabilité, l’interopérabilité, la pérennité et la bonne compréhension des jeux de données utilisés dans l’outil web d’accessibilité.  
Conformément au cahier des charges, leur production doit respecter :

* les standards CNIG Accessibilité ;  
* les normes **ISO 19115** (contenu des métadonnées) ;  
* et **ISO 19139** (schéma XML d’encodage).

  ### e.1) Choix d’un outil ou plugin pour la gestion des métadonnées {#e.1)-choix-d’un-outil-ou-plugin-pour-la-gestion-des-métadonnées}

Afin d’assurer une gestion homogène et conforme des métadonnées, il est nécessaire d’utiliser un outil permettant leur création, leur modification, leur exportation et leur documentation selon des standards reconnus. Dans l’environnement QGIS, deux plugins se distinguent particulièrement et méritent une comparaison : PLUME et Geocat Bridge.

* **PLUME (plugin QGIS pour postgreSQL)**

PLUME est une extension développée par le ministère de la Transition écologique. Elle permet de saisir et de consulter les métadonnées directement au sein d’une base PostgreSQL/PostGIS, ce qui facilite la documentation des jeux de données stockés dans la base. Les métadonnées sont enregistrées sous forme de JSON-LD, basé sur le profil européen GeoDCAT-AP, ce qui favorise l’interopérabilité avec les catalogues de données ouverts.

L’outil présente plusieurs avantages. Il est particulièrement adapté aux bases de données PostgreSQL/PostGIS et s’intègre directement dans l’environnement QGIS, ce qui simplifie la manipulation des métadonnées. Son utilisation du vocabulaire DCAT / GeoDCAT-AP facilite également la publication dans des portails open data.

Cependant, PLUME présente certaines limites dans le cadre de ce projet. Il ne repose pas nativement sur les standards ISO 19115 / ISO 19139, qui sont les normes généralement utilisées pour la production de métadonnées institutionnelles. De plus, l’encodage en RDF / JSON-LD diffère des formats attendus dans les référentiels CNIG ou dans les échanges institutionnels. L’outil est donc davantage adapté à une documentation interne des données qu’à la production de métadonnées normées destinées à être diffusées.

* **Geocat Bridge (plugin orienté normes ISO)**

Geocat Bridge est un plugin QGIS spécifiquement conçu pour faciliter la création de métadonnées conformes aux standards ISO 19115 et ISO 19139\. Il permet notamment de générer des métadonnées structurées et de produire directement un fichier XML au format ISO 19139, largement utilisé dans les catalogues de données géographiques.

L’un des principaux avantages de Geocat Bridge est sa conformité avec les normes ISO attendues dans de nombreux projets institutionnels. L’export en XML ISO 19139 constitue également un atout majeur pour répondre aux exigences du CNIG et faciliter le partage des métadonnées entre différents organismes. Le plugin s’intègre par ailleurs relativement simple dans la chaîne de travail basée sur QGIS.

En revanche, Geocat Bridge est moins orienté vers la documentation directe des bases PostgreSQL et vers les logiques de catalogage basées sur DCAT. Il se concentre principalement sur la production de métadonnées normalisées destinées à être diffusées ou échangées.

### 		e.2) Outil utilisé pour les métadonnées {#e.2)-outil-utilisé-pour-les-métadonnées}

Malgré les qualités de PLUME, notamment pour la gestion interne des métadonnées dans PostgreSQL, son encodage ne répond pas totalement aux besoins du projet qui exige la production de métadonnées **ISO 19115/19139**.

Au regard des attentes du cahier des charges et de la nécessité d’assurer une interopérabilité institutionnelle (CNIG, collectivités, OpenData), le choix le plus adapté est donc l’utilisation de **Geocat Bridge** comme plugin principal dans QGIS pour la production de métadonnées conformes aux standards ISO.

La gestion des métadonnées reposera ainsi sur plusieurs composants complémentaires :

* **QGIS**, avec **Geocat Bridge** comme plugin principal pour la création et l’édition des métadonnées ;

* **PostgreSQL / PostGIS**, permettant de stocker certains attributs clés (dates de mise à jour, provenance des données, identifiants uniques) ;

* **un catalogue interne**, organisé sous forme d’un dossier structuré regroupant les fichiers XML exportés (ISO 19139), les notices explicatives ainsi que l’historique des versions.

Dans ce dispositif, **PLUME** pourra être utilisé comme outil complémentaire pour la gestion interne des informations dans PostgreSQL, sans constituer la solution principale. Cette organisation garantit que les métadonnées accompagnent les données tout au long de leur cycle de vie, conformément aux exigences définies dans le cahier des charges.

### 		e.3) Contenu des métadonnées {#e.3)-contenu-des-métadonnées}

Chaque jeu de données (CNIG Accessibilité, Travaux, GTFS, Population etc.) doit comporter a minima :

* identifiant,  
* langue,  
* titre,  
* liens,  
* contact,  
* licence.

Ces éléments contribuent à assurer une compréhension immédiate des données, à faciliter leur réutilisation par des tiers, à garantir leur conformité avec le standard CNIG « Accessibilité » et à anticiper leur diffusion future via une API ou une plateforme OpenData.

# V \- Administration et cycle de vie des données {#v---administration-et-cycle-de-vie-des-données}

La gestion des données d’accessibilité de Losse‑en‑Gelaisse repose sur deux piliers indissociables :

* un cycle de vie des données garantissant leur qualité, leur actualité et leur cohérence ;  
* une administration rigoureuse de la base PostgreSQL/PostGIS assurant sécurité, maintenance et gouvernance.

Ces deux dimensions forment un système continu et structuré permettant d’alimenter durablement l’outil web d’accessibilité.

1) ## Administration de la base de données {#administration-de-la-base-de-données}

L’administration garantit que la base PostgreSQL/PostGIS est stable, sécurisée, performante et exploitable par les utilisateurs internes et les outils.

### a.1)  Rôles et responsabilités {#a.1)-rôles-et-responsabilités}

| Responsabilités | Rôles |
| ----- | ----- |
| Administrateur BDD (SIG) | Création schémas, gestion droits, maintenance, sauvegardes. |
| Référent Accessibilité | Mise à jour CNIG, contrôle qualité PMR. |
| Référent transport (GTFS) | Import régulier GTFS, validation arrêts/lignes. |
| Référent travaux | Intégration des chantiers et gestion de la temporalité. |
| Référent population | Mise à jour population INSEE / Quartiers (carreaux). |
| Consultation | Accès en lecture via QGIS ou l’outil web. |

### a.2) Gestion des accès et privilèges {#a.2)-gestion-des-accès-et-privilèges}

Utilisateurs nécessitant un accès à la base de données: Service SIG, Service Voirie, Développeurs de l’outil web, Prestataires. Les types de droits prévus sont les suivants :

* **lecture seule** : outil web, agents non-éditeurs ;  
* **écriture** : référents par thématique (CNIG, Travaux, GTFS, Population) ;  
* **administration** : service SIG

Chaque schéma de la base est associé à des droits spécifiques :

* *accessibilité* \> édition par Référent Accessibilité  
* *travaux* \> édition par Référent Travaux  
* *transport* \> édition par Référent Transport

### a.3)  Intégration, mise à jour, sécurité {#a.3)-intégration,-mise-à-jour,-sécurité}

L’intégration et la mise à jour des données sont réalisées de manière contrôlée, notamment via des scripts SQL ou à l’aidGIS. L’accès au système est sécurisé grâce à des mécanismes d’authentification, à l’utilisation de mots de passe et, le cas échéant, à des restrictions d’accès par IP ou via VPN. Une surveillance régulière des logs PostgreSQL est également mise en place afin de détecter d’éventuelles anomalies ou tentatives d’accès non autorisées. Par ailleurs, les logiciels PostgreSQL et PostGIe des outils proposés par QS font l’objet de mises à jour régulières pour garantir la sécurité et la stabilité de l’infrastructure. 

2) ##  Sauvegardes et versionnement {#sauvegardes-et-versionnement}

### b.1) Sauvegardes quotidiennes {#b.1)-sauvegardes-quotidiennes}

La mise en place d’une stratégie de sauvegarde est indispensable pour garantir la pérennité, la sécurité et la récupération des données en cas d’incident. Dans le cadre du projet Losse‑en‑Gelaisse, trois niveaux de sauvegardes sont recommandés : quotidiennes, hebdomadaires et mensuelles.

Les sauvegardes quotidiennes, lorsque cela est nécessaire, doivent reposer sur l’outil natif de PostgreSQL, *pg\_dump*, qui permet d’extraire la structure et le contenu d’une base de données sous forme de script SQL ou d’archive. Ce fichier contient les commandes nécessaires à la reconstruction de la base dans l’état exact du moment du dump. 

*pg\_dump* produit une **sauvegarde logique**, incluant les tables, les index, les données et les contraintes. Pour exécuter un dump, l’utilisateur doit disposer d’un accès en lecture sur toutes les tables concernées ainsi que du droit *USAGE* sur les schémas correspondants. Ces permissions sont suffisantes, sauf pour certains objets particuliers (exemple: subscriptions), réservés au superutilisateur. 

Avant de restaurer un dump SQL, les rôles et utilisateurs référencés dans ce fichier doivent déjà exister sur l’instance de destination. C’est un prérequis normal des restaurations basées sur un script SQL.

Ci-dessous des exemples de commandes usuelles :

* **Sauvegarde complète d’une base**

*pg\_dump dbname \> sauvegarde.sql*

* **Sauvegarde ciblée** (un schéma ou quelques tables)

*pg\_dump \-n schema\_name \-t table\_name dbname \> sauvegarde\_partielle.sql*  
La commande *pg\_dump* présente néanmoins les limites suivantes :

* *pg\_dump* ne sauvegarde qu’une seule base de données à la fois ;  
* la commande n’inclut pas les objets globaux du cluster PostgreSQL : rôles, utilisateurs, tablespaces.

C’est pourquoi l’outil pg\_dumpall doit être utilisé pour les sauvegardes complètes mensuelles ou globales du cluster.

### b.2) Sauvegardes hebdomadaires : sauvegardes disque  {#b.2)-sauvegardes-hebdomadaires-:-sauvegardes-disque}

Les sauvegardes hebdomadaires doivent porter sur les **fichiers physiques** du serveur PostgreSQL. Elles consistent à copier :

* le répertoire de données PostgreSQL (PGDATA) ;  
* les fichiers de configuration (*postgresql.conf*, *pg\_hba.conf*, *pg\_ident.conf*) ;  
* les répertoires contenant les journaux de transactions (WAL logs, si l’archivage ou la réplication est activé).

Ce type de sauvegarde est important car au niveau du disque il permet de restaurer **tout le serveur PostgreSQL**, et pas seulement une base spécifique. Cela garantit une protection en cas :

* de corruption du système de fichiers,  
* de défaillance matérielle,  
* d’erreur critique ou suppression accidentelle de données internes,  
* ou lorsqu’il faut restaurer l’ensemble du cluster PostgreSQL avec ses paramètres et identifiants.

Elle complète les sauvegardes **logiques** (pg\_dump), qui ne sauvent ni les configurations, ni les rôles, ni les paramètres serveur, ni l’état interne du cluster. Deux approches sont possibles:

* **Sauvegarde à froid** (service arrêté)

- On arrête le service PostgreSQL pour garantir la cohérence des fichiers.

- On copie l’intégralité du répertoire PGDATA via un outil adapté (rsync, robocopy, sauvegarde réseau, snapshot, etc.).  
   \>  Méthode simple et sûre, mais nécessite une interruption de service.

* **Sauvegarde à chaud** (cluster en fonctionnement)

- On active l’archivage WAL (*archive\_mode \= on*, *archive\_command \= ...*).

- On réalise une copie cohérente du répertoire PGDATA ainsi que des WAL archivés, ce qui permet une restauration correcte par *Point-In-Time Recovery (PITR)*.  
  \>  Pas d’interruption de service, mais nécessite une configuration correcte de l’archivage WAL.

La sauvegarde doit être déposée sur un serveur dédié à la sauvegarde ou dans un espace NAS / SAN sécurisé.

### b.3) Sauvegardes mensuelles : archivage longue durée {#b.3)-sauvegardes-mensuelles-:-archivage-longue-durée}

Pour garantir une conservation complète et durable du cluster PostgreSQL, il est nécessaire d’utiliser *pg\_dumpall*. Cet outil génère un fichier SQL contenant l’ensemble des bases de données du cluster, ainsi que tous les objets globaux : rôles et utilisateurs, privilèges, tablespaces, et paramètres définis au niveau du cluster.

*pg\_dumpall \> archive*

***pg\_dumpall*** permet de sauvegarder des éléments non pris en compte par la commande *pg\_dump* :

- les rôles et utilisateurs,  
- les permissions globales,  
- les tablespaces,  
- les paramètres globaux du cluster.

Les archives mensuelles doivent être :

- compressées (.zip, .gz, .7z, etc.) pour réduire la taille et vérifier l’intégrité,  
- stockées hors du serveur PostgreSQL (NAS, cloud interne, serveur de sauvegarde),  
- conservées sur plusieurs mois, voire plusieurs années selon la politique de rétention établie.

### b.4) Versionnement {#b.4)-versionnement}

Les différents schémas seront versionnés par année, par exemple *cnig\_2026* ou *gtfs\_2026*, ce qui permet de distinguer les structures de données selon leur millésime et de conserver l’historique des modèles utilisés. En complément, des tables d’archivage suffixées *\_archive* sont mises en place pour conserver les états antérieurs des données. Enfin, chaque jeu de données est accompagné de métadonnées conformes au standard **ISO 19139**, permettant de documenter précisément l’origine, la structure et les conditions d’utilisation des données.

Grâce à cette organisation, la base est :

1. opérationnelle : accessible 24/7,  
2. exploitable : connectée à QGIS et à l’outil web,  
3. sécurisée : droits contrôlés, sauvegardes en place,  
4. pérenne : traçabilité assurée,  
5. conforme : standards CNIG / ISO respectés.

Grâce à la combinaison de *pg\_dump* (sauvegarde logique), des sauvegardes disque (sauvegardes physiques) et de *pg\_dumpall* (archivage complet du cluster), la base de données PostgreSQL de Losse‑en‑Gelaisse bénéficie d’une protection complète contre les pertes de données, les erreurs humaines, les corruptions et les défaillances matérielles, tout en restant rapidement restaurable.

## c) Cycle de vie des données {#c)-cycle-de-vie-des-données}

Le cycle de vie décrit l’ensemble des actions permettant de maintenir une base fiable, conforme aux standards CNIG et exploitable dans l’outil web. Il repose sur un processus itératif comprenant plusieurs phases, depuis la planification de la collecte jusqu’à l’archivage des données.

### c.1) Planification {#c.1)-planification}

La phase de planification consiste à identifier les jeux de données nécessaires au projet et à organiser leur mise à jour. Cela concerne notamment les données issues du standard CNIG, les données de transport au format GTFS, les informations relatives aux travaux de voirie, ainsi que les données démographiques de l’INSEE ou les données altimétriques issues du LiDAR ou de modèles numériques de terrain.

Cette étape permet également de définir la fréquence d’actualisation des données (par exemple une mise à jour mensuelle pour les données GTFS ou annuelle pour certaines données CNIG), de préparer les scripts d’importation et de répartir les responsabilités entre les différents modules du système (accessibilité, transport, travaux et population).

### c.2) Acquisition {#c.2)-acquisition}

La phase d’acquisition consiste à collecter les différentes sources de données nécessaires au projet. Les données externes, telles que les jeux de données GTFS, les données de l’INSEE ou les modèles LiDAR/MNT, sont téléchargées puis intégrées dans l’environnement de travail.

La base CNIG fournie par la collectivité est également importée, tandis que les données relatives aux travaux sont récupérées auprès du service Voirie. L’ensemble de ces informations est ensuite centralisé dans la base PostgreSQL/PostGIS.

### c.3) Vérification {#c.3)-vérification}

Une fois les données intégrées, plusieurs contrôles sont réalisés afin de vérifier leur qualité. Ces vérifications portent notamment sur la validité des géométries (à l’aide d’outil topologique), le respect du système de projection utilisé par la base (RGF93 / Lambert-93 – EPSG:2154), ainsi que sur la détection d’éventuels doublons, valeurs manquantes ou incohérences attributaires.

Des contrôles de cohérence sont également réalisés entre les différentes sources de données, par exemple entre les arrêts de transport issus des données GTFS et les cheminements piétons décrits dans les données CNIG.

### c.4) Validation {#c.4)-validation}

Après la phase de vérification, les anomalies identifiées sont corrigées. Cela peut concerner la correction de géométries invalides, la normalisation des attributs ou encore l’application de contrôles topologiques. Ces contrôles permettent notamment de vérifier la continuité des cheminements accessibles aux personnes à mobilité réduite, par exemple en s’assurant qu’une rampe est correctement connectée au cheminement menant à un arrêt de transport.

Une validation finale est ensuite réalisée par les référents techniques responsables des différentes thématiques (accessibilité, transport et travaux).

### c.5) Intégration et réutilisation {#c.5)-intégration-et-réutilisation}

Une fois validées, les données sont intégrées dans la base de données finale et peuvent être utilisées pour réaliser différentes analyses spatiales. Celles-ci incluent notamment la création de zones tampons de 200 mètres autour des arrêts de transport, l’analyse des intersections entre zones de travaux et itinéraires accessibles, le croisement entre accessibilité et densité de population, ainsi que le calcul des pentes pouvant impacter l’accessibilité des cheminements.

Ces traitements permettent notamment de produire les cartographies thématiques destinées à l’outil web.

### c.6) Archivage {#c.6)-archivage}

Les données sont ensuite archivées afin de conserver un historique des versions utilisées. La fréquence d’archivage peut varier selon le type de données (mensuelle ou annuelle). Les informations relatives aux anciens travaux sont également conservées afin de permettre une analyse dans le temps.

Chaque version des données est documentée, en précisant la date, la source et les traitements réalisés.

### c.7) Retour à la planification {#c.7)-retour-à-la-planification}

Le cycle de vie des données fonctionne selon un processus continu. Chaque nouvelle mise à jour relance les différentes étapes du cycle, garantissant ainsi l’actualisation régulière et la qualité des données utilisées par la collectivité.

# 

## Annexe n°1 : Convention de mise à disposition des données {#annexe-n°1-:-convention-de-mise-à-disposition-des-données}

| Convention type de mise à disposition des données d’accessibilité entre l’Agglomération de Losse-en-Gelaisse et le prestataire |
| :---: |

**ENTRE**

L’Agglomération de **Losse-en-Gelaisse**, Autorité Organisatrice de la Mobilité au sens de la Loi d’Orientation des Mobilités, dont le siège est situé 19 rue Vallée Silicone, représentée par Bertrand GERVAIS, en qualité d’expert technique, dûment habilité à cet effet,

**ET**

La société *CALA geom*, dont le siège social est situé 1 All. Maurice Magre, sous le numéro SIRET 999 134 356 00016, représentée par Cloé BARATEAU, en qualité de Présidente Directrice Générale, dûment habilité à cet effet,

Ci-après dénommée **« le Prestataire »**,

**Ci-après désignées collectivement « les Parties »**,

Il a été convenu et arrêté ce qui suit :

**Préambule**

Afin d’améliorer l’information des usagers, de disposer d’une connaissance précise, homogène et actualisée de l’accessibilité de la voirie et des cheminements extérieurs sur son territoire, et de pouvoir cibler plus efficacement les politiques publiques conduites en matière de mobilité inclusive, l’Agglomération de Losse-en-Gelaisse, en sa qualité d’Autorité Organisatrice de la Mobilité au sens de la Loi d’Orientation des Mobilités, a engagé une démarche de collecte et de structuration des données d’accessibilité.

Ces données, conformes au modèle défini par le Conseil National de l’Information Géolocalisée (CNIG), cartographient l’accessibilité de la voirie et des espaces publics situés notamment aux abords des arrêts prioritaires de transport. Elles sont structurées au sein d’une base de données géographiques et ont vocation à être mises à jour régulièrement par les services de la collectivité ou par des prestataires mandatés.

Dans une logique d’amélioration continue, de transparence et d’ouverture des données publiques, la collectivité souhaite mettre à disposition ces données auprès du prestataire retenu afin :

* de concevoir un outil web open source d’analyse territoriale de l’accessibilité ;

* de produire des cartographies thématiques destinées aux services internes et aux associations représentant les personnes en situation de handicap ;

* de mettre en place une méthodologie et des outils de contrôle de la qualité des données collectées.

**Article 1er \- Objet de la convention**

La présente convention a pour objet de définir les conditions de mise à disposition par l’Agglomération de Losse-en-Gelaisse au Prestataire des données géographiques d’accessibilité relatives à l’accessibilité de la voirie et des cheminements extérieurs situés sur le territoire de l’Agglomération, notamment les cheminements piétons, la voirie, les abords d’arrêts de transport prioritaires ainsi que les aménagements et obstacles impactant la mobilité des personnes à mobilité réduite.

**Article 2 \- Fonctionnement de la mise à disposition des données**

Conformément aux dispositions de l’article L141-13 du Code de la voirie routière, et à la Loi n°2019-1428 du 24 décembre 2019 (LOM), l’Agglomération de Losse-en-Gelaisse collecte des données relatives à l’accessibilité des itinéraires piétons situés dans un rayon d’environ 200 mètres autour des points d’arrêt prioritaires du territoire. Ces données sont structurées selon le modèle CNIG et comprennent notamment les entités suivantes : cheminements et tronçons de cheminement, nœuds, obstacles, zones de circulation, traversées piétonnes, rampes, escaliers, escaliers mécaniques, tapis roulants, quais, entrées, passages sélectifs, élévateurs, ascenseurs, stationnements PMR et quartiers.  
Les données sont collectées par des prestataires mandatés et font l’objet d’un premier contrôle portant sur leur intégrité et leur cohérence. Elles seront ensuite mises à disposition du Prestataire.

Les traitements effectués par le Prestataire ont pour objet de compléter ces contrôles, d’identifier d’éventuelles anomalies et de produire des résultats exclusivement destinés à l’exploitation des données et à l’amélioration des services d’accessibilité. Toute utilisation des données à d’autres fins est interdite sans l’accord écrit de la collectivité.

La collectivité définit les conditions d’utilisation et de diffusion des résultats afin de garantir la fiabilité, la sécurité et la confidentialité des informations mises à disposition des services internes, des partenaires et du public.

**Article 3 \- Données mises à disposition du Prestataire**

**3-1- Terminologie**

« Données collectées » : données relatives aux cheminements, voirie, aménagements et équipements extérieurs du territoire, collectées par les services techniques de la collectivité ou par les prestataires mandatés. Il peut s’agir de données brutes ou prétraitées.  
« Données traitées » : données collectées vérifiées et enrichies par le Prestataire, incluant les contrôles de cohérence, de complétude et de conformité au modèle CNIG.  
« Résultats » : analyses, indicateurs et cartographies thématiques produits à partir des données traitées pour l’exploitation dans l’outil web ou pour la planification et le suivi des politiques d’accessibilité.

**3-2- Nature et contenu des données**

Les données mises à disposition comprennent notamment :

* **CHEMINEMENT** et **TRONCON\_CHEMINEMENT** : itinéraires piétons et tronçons élémentaires avec caractéristiques géométriques et physiques (longueur, type, pente, dévers, accessibilité) ;

* **NOEUD** : points géographiques structurants (intersections, extrémités de tronçons) avec informations altimétriques et fonctionnelles (abaissés de trottoir, bandes d’éveil, dispositifs de perception) ;

* **OBSTACLE**, **CIRCULATION**, **TRAVERSEE**, **RAMPE**, **ESCALIER**, **ESCALATOR**, **TAPIS\_ROULANT**, **QUAI**, **ENTREE**, **PASSAGE\_SELECTIF**, **ELEVATEUR**, **ASCENSEUR**, **STATIONNEMENT\_PMR**, **QUARTIER** : détails et attributs techniques correspondant aux caractéristiques d’accessibilité des espaces publics et des équipements extérieurs.

Les données sont fournies dans des formats compatibles SIG et accompagnées de métadonnées détaillant leur origine, leur précision, et leur fréquence de mise à jour.

**3-3- Champ couvert**

Les données mises à disposition concernent :

* les espaces publics extérieurs, les itinéraires piétons et les aménagements situés dans un rayon d’environ 200 mètres autour des points d’arrêt prioritaires au sens de l’article L141-13 du Code de la voirie routière ;  
* les éléments impactant la mobilité des personnes à mobilité réduite, tels que obstacles, traversées piétonnes, rampes, escaliers et dispositifs mécaniques ou d’accessibilité ;  
* l’ensemble des zones et équipements extérieurs pertinents pour le calcul d’itinéraires et la production de cartographies thématiques.

Ne sont pas concernés :

* les cheminements et équipements à l’intérieur des ERP (bâtiments publics, médiathèques, gares).


**Article 4 \- Engagements du Prestataire sur l’utilisation des données**

Le Prestataire s’engage à :

* exploiter les données d’accessibilité mises à disposition par l’Agglomération uniquement dans le cadre défini par la présente convention, notamment pour le développement de l’outil web, la production de cartographies thématiques et la mise en œuvre de contrôles de qualité ;  
* traiter les données collectées, vérifiées et enrichies conformément au modèle CNIG, en garantissant leur intégrité, leur cohérence et leur confidentialité ;  
* respecter la sécurité, la confidentialité et la protection des informations conformément à la réglementation applicable, et ne pas utiliser les données à d’autres fins que celles prévues dans la convention ;  
* signaler à l’Agglomération toute anomalie ou incohérence détectée dans les données et proposer des mesures correctives le cas échéant.

Le Prestataire ne peut transmettre les données ou les résultats obtenus à des tiers sans l’accord écrit préalable de l’Agglomération.

**Article 5 \-  Protection des données, confidentialité et sécurité**

Les données mises à disposition dans le cadre de la présente convention sont utilisées exclusivement aux fins définies à l’article 1er.

Lorsque les données comportent des informations susceptibles d’identifier indirectement des personnes physiques (notamment par croisement avec d’autres jeux de données), leur traitement est réalisé conformément à la réglementation en vigueur relative à la protection des données à caractère personnel, notamment la loi n°78-17 du 6 janvier 1978 modifiée relative à l’informatique, aux fichiers et aux libertés et au Règlement (UE) 2016/679 du Parlement européen et du Conseil du 27 avril 2016 (RGPD).

Le Prestataire s’engage à :

* mettre en œuvre toutes les mesures techniques et organisationnelles nécessaires pour garantir la sécurité, l’intégrité et la confidentialité des données ;  
* limiter l’accès aux données aux seules personnes dûment habilitées dans le cadre de l’exécution du marché ;  
* ne procéder à aucune diffusion, cession ou communication des données à des tiers sans l’accord écrit préalable de l’Agglomération ;  
* ne pas utiliser les données à des fins commerciales ou étrangères à l’objet de la présente convention.

**Article 6 \-  Engagements de l’Agglomération**

L’Agglomération de Losse-en-Gelaisse s’engage à :

* mettre à disposition du Prestataire, sans contrepartie financière distincte de celle prévue au marché public, les données décrites à l’article 3 pendant la durée de la présente convention ;  
* transmettre des données conformes au modèle défini par le Conseil National de l’Information Géolocalisée (CNIG), accompagnées des métadonnées nécessaires à leur exploitation ;  
* permettre l’accès aux données dans des formats compatibles avec les systèmes d’information géographique (SIG) et les outils nécessaires au développement de la solution web ;  
* informer le Prestataire de toute modification substantielle affectant la structure, le périmètre ou les modalités de mise à jour des données ;  
* autoriser le Prestataire à utiliser les données dans le strict cadre défini par la présente convention et le marché public associé.

La mise à disposition des données n’emporte aucun transfert de propriété au profit du Prestataire, lequel ne dispose que d’un droit d’usage limité aux finalités prévues par la convention.

**Article 7 \-  Durée de la convention et conditions de résiliation**

La présente convention est conclue pour une durée correspondant à celle du marché public relatif au développement, à l’hébergement et à la maintenance de l’outil web d’analyse de l’accessibilité, soit une durée prévisionnelle de trente-six mois comprenant :

* douze  mois de conception et de développement ;  
* vingt-quatre mois de maintenance et d’exploitation.

Elle prend effet à compter de la date de notification du marché.

Elle pourra être résiliée de manière anticipée dans les conditions prévues par le marché public ou en cas de manquement grave aux obligations de la présente convention, notamment en matière de confidentialité ou d’usage des données.

À l’issue de la convention ou en cas de résiliation, le Prestataire s’engage à cesser toute utilisation des données et à en restituer ou détruire les copies, sous réserve des obligations légales de conservation.

**Fait à Losse-en-Gelaisse en deux exemplaires originaux, le 12/03/2026**

**Pour l’Agglomération de Losse-en-Gelaisse**

Nom, Prénom  
Fonction du signataire   
Cachet

**Pour le Prestataire**

Nom, Prénom  
Fonction du signataire   
Cachet

## Annexe n°2 : Script SQL de création de la base de donnée {#annexe-n°2-:-script-sql-de-création-de-la-base-de-donnée}

**CREATE** **SCHEMA** **IF** **NOT** **EXISTS** travaux;  
**CREATE** **SCHEMA** **IF** **NOT** **EXISTS** transport;  
**CREATE** **SCHEMA** **IF** **NOT** **EXISTS** accessibilite;

*\-- \======================*  
*\-- GTFS TABLES (transport)*  
*\-- \======================*  
**CREATE** **TABLE** transport.AGENCY(  
   agency\_id VARCHAR(50),  
   agency\_name VARCHAR(50),  
   agency\_url VARCHAR(50),  
   agency\_timezone VARCHAR(50),  
   agency\_lang VARCHAR(50),  
   PRIMARY **KEY**(agency\_id)  
);

**CREATE** **TABLE** transport.ROUTE(  
   route\_id VARCHAR(50),  
   route\_short\_name VARCHAR(50),  
   route\_long\_name VARCHAR(50),  
   route\_type INTEGER,  
   PRIMARY **KEY**(route\_id)  
);

**CREATE** **TABLE** transport.STOP(  
   stop\_id VARCHAR(50),  
   stop\_name VARCHAR(50),  
   stop\_lat **DOUBLE** **PRECISION**,  
   stop\_lon **DOUBLE** **PRECISION**,  
   stop\_id\_parent VARCHAR(50),  
   PRIMARY **KEY**(stop\_id),  
   FOREIGN **KEY**(stop\_id\_parent) **REFERENCES** transport.STOP(stop\_id)  
);

**CREATE** **TABLE** transport.CALENDAR(  
   service\_id VARCHAR(50),  
   monday VARCHAR(50),  
   tuesday VARCHAR(50),  
   wednesday VARCHAR(50),  
   thursday VARCHAR(50),  
   friday VARCHAR(50),  
   saturday VARCHAR(50),  
   sunday VARCHAR(50),  
   start\_date DATE,  
   end\_date DATE,  
   PRIMARY **KEY**(service\_id)  
);

**CREATE** **TABLE** transport.TRIP(  
   trip\_id VARCHAR(50),  
   headsign VARCHAR(50),  
   direction\_id INTEGER,  
   service\_id VARCHAR(50) **NOT** NULL,  
   route\_id VARCHAR(50) **NOT** NULL,  
   PRIMARY **KEY**(trip\_id),  
   FOREIGN **KEY**(service\_id) **REFERENCES** transport.CALENDAR(service\_id),  
   FOREIGN **KEY**(route\_id) **REFERENCES** transport.ROUTE(route\_id)  
);

**CREATE** **TABLE** transport.Gerer(  
   agency\_id VARCHAR(50),  
   route\_id VARCHAR(50),  
   PRIMARY **KEY**(agency\_id, route\_id),  
   FOREIGN **KEY**(agency\_id) **REFERENCES** transport.AGENCY(agency\_id),  
   FOREIGN **KEY**(route\_id) **REFERENCES** transport.ROUTE(route\_id)  
);

**CREATE** **TABLE** transport.Desservir(  
   stop\_id VARCHAR(50),  
   trip\_id VARCHAR(50),  
   stop\_sequence VARCHAR(50),  
   arrival\_time VARCHAR(50),  
   departure\_time VARCHAR(50),  
   PRIMARY **KEY**(stop\_id, trip\_id),  
   FOREIGN **KEY**(stop\_id) **REFERENCES** transport.STOP(stop\_id),  
   FOREIGN **KEY**(trip\_id) **REFERENCES** transport.TRIP(trip\_id)  
);

*\-- \======================*  
*\-- ACCESSIBILITY TABLES (accessibilite)*  
*\-- \======================*

**CREATE** **TABLE** accessibilite.Cheminement(  
   idCheminement VARCHAR(255),  
   nom VARCHAR(254),  
   PRIMARY **KEY**(idCheminement)  
);

**CREATE** **TABLE** accessibilite.Obstacle(  
   idObstacle VARCHAR(255),  
   typeObstacle VARCHAR(2),  
   largeurUtile **DOUBLE** **PRECISION**,  
   positionObstacle VARCHAR(2),  
   longueurObstacle **DOUBLE** **PRECISION**,  
   rappelObstacle VARCHAR(2),  
   reperabiliteVisuelle BOOLEAN,  
   largeurObstacle **DOUBLE** **PRECISION**,  
   hauteurObsPoseSol **DOUBLE** **PRECISION**,  
   hauteurSousObs **DOUBLE** **PRECISION**,  
   geom GEOMETRY,  
   PRIMARY **KEY**(idObstacle)  
);

**CREATE** **TABLE** accessibilite.Circulation(  
   idCirculation VARCHAR(255),  
   typeSol VARCHAR(2),  
   largeurPassageUtile **DOUBLE** **PRECISION**,  
   etatRevetement VARCHAR(2),  
   eclairage VARCHAR(2),  
   transition VARCHAR(2),  
   typePassage VARCHAR(2),  
   repereLineaire VARCHAR(2),  
   couvert VARCHAR(50),  
   PRIMARY **KEY**(idCirculation)  
);

**CREATE** **TABLE** accessibilite.Ascenceur(  
   idAscenseur VARCHAR(255),  
   largeurUtile **DOUBLE** **PRECISION**,  
   diamManoeuvreFauteuil **DOUBLE** **PRECISION**,  
   largeurCabine **DOUBLE** **PRECISION**,  
   longueurCabine **DOUBLE** **PRECISION**,  
   boutonsEnRelief VARCHAR(2),  
   annonceSonore BOOLEAN,  
   signalEtage VARCHAR(2),  
   boucleInducMagnet BOOLEAN,  
   miroir BOOLEAN,  
   eclairage INTEGER,  
   voyantAlerte VARCHAR(2),  
   typeOuverture VARCHAR(2),  
   mainCourante VARCHAR(2),  
   hauteurMainCourante **DOUBLE** **PRECISION**,  
   etatRevetement VARCHAR(2),  
   supervision BOOLEAN,  
   autrePorteSortie VARCHAR(2),  
   PRIMARY **KEY**(idAscenseur)  
);

**CREATE** **TABLE** accessibilite.Elevateur(  
   idElevateur VARCHAR(255),  
   largeurUtile **DOUBLE** **PRECISION**,  
   boutonsEnRelief VARCHAR(2),  
   typeOuverture VARCHAR(2),  
   largeurPlateforme **DOUBLE** **PRECISION**,  
   longueurPlateforme VARCHAR(50),  
   utilisableAutonomie BOOLEAN,  
   etatRevetement VARCHAR(2),  
   supervision BOOLEAN,  
   autrePorteSortie VARCHAR(2),  
   chargeMaximum INTEGER,  
   accompagnateur VARCHAR(2),  
   PRIMARY **KEY**(idElevateur)  
);

**CREATE** **TABLE** accessibilite.Passage\_Selectif(  
   idPassageSelectif VARCHAR(255),  
   passageMecanique BOOLEAN,  
   largeurUtile REAL,  
   profondeur REAL,  
   contrasteVisuel BOOLEAN,  
   PRIMARY **KEY**(idPassageSelectif)  
);

**CREATE** **TABLE** accessibilite.Entree(  
   idEntree VARCHAR(255),  
   adresse TEXT,  
   **type** VARCHAR(2),  
   rampe VARCHAR(2),  
   rampeSonnette BOOLEAN **DEFAULT** false,  
   ascenseur BOOLEAN **DEFAULT** false,  
   escalierNbMarche INTEGER **DEFAULT** 0,  
   escalierMainCourante BOOLEAN **DEFAULT** false,  
   reperabilite BOOLEAN,  
   reperageEltsVitres BOOLEAN,  
   signaletique BOOLEAN,  
   largeurPassage REAL,  
   controleAcces VARCHAR(2),  
   entreeAccueilVisible BOOLEAN,  
   eclairage INTEGER,  
   typePorte VARCHAR(2),  
   typeOuverture VARCHAR(2),  
   espaceManoeuvre VARCHAR(2),  
   largManoeuvreExt REAL,  
   longManoeuvreExt REAL,  
   largManoeuvreInt REAL,  
   longManoeuvreInt REAL,  
   typePoignee VARCHAR(2),  
   effortOuverture INTEGER,  
   PRIMARY **KEY**(idEntree)  
);

**CREATE** **TABLE** accessibilite.Stationnement\_PMR(  
   idStationnement VARCHAR(255),  
   typeStationnement VARCHAR(2),  
   etatRevetement VARCHAR(2),  
   largeurStat REAL,  
   longueurStat REAL,  
   bandLatSecurite BOOLEAN,  
   surLongueur REAL,  
   signalPMR BOOLEAN,  
   marquageSol BOOLEAN,  
   pente INTEGER,  
   devers INTEGER,  
   typeSol VARCHAR(2),  
   PRIMARY **KEY**(idStationnement)  
);

**CREATE** **TABLE** accessibilite.Escalier(  
   idEscalier VARCHAR(255),  
   etatRevetement geostandard.enum5,  
   mainCourante geostandard.enum5,  
   dispositifVigilance geostandard.enum5,  
   contrasteVisuel geostandard.enum5,  
   largeurUtile REAL,  
   mainCouranteContinue geostandard.enum5,  
   prolongMainCourante geostandard.enum5,  
   nbMarches INTEGER,  
   nbVoleeMarches INTEGER,  
   hauteurMarche REAL,  
   giron REAL,  
   PRIMARY **KEY**(idEscalier)  
);

**CREATE** **TABLE** accessibilite.Quai(  
   idQuai VARCHAR(255),  
   etatRevetement VARCHAR(2),  
   hauteur REAL,  
   largeurPassage REAL,  
   signalisationPorte VARCHAR(2),  
   dispositifVigilance VARCHAR(2),  
   diamZoneManoeuvre REAL,  
   PRIMARY **KEY**(idQuai)  
);

**CREATE** **TABLE** accessibilite.Rampe(  
   idRampe VARCHAR(255),  
   etatRevetement VARCHAR(2),  
   largeurUtile REAL,  
   mainCourante VARCHAR(2),  
   distPalierRepos REAL,  
   chasseRoue VARCHAR(2),  
   aireRotation VARCHAR(2),  
   poidsSupporte INTEGER,  
   PRIMARY **KEY**(idRampe)  
);

**CREATE** **TABLE** accessibilite.Tapis\_Roulant(  
   idTapis VARCHAR(255),  
   sens VARCHAR(2),  
   dispositifVigilance VARCHAR(2),  
   largeurUtile REAL,  
   detecteur BOOLEAN,  
   PRIMARY **KEY**(idTapis)  
);

**CREATE** **TABLE** accessibilite.Escalator(  
   idEscalator VARCHAR(255),  
   sens geostandard.enum4,  
   dispositifVigilance geostandard.enum5,  
   largeurUtile REAL,  
   detecteur BOOLEAN,  
   surpervision BOOLEAN,  
   PRIMARY **KEY**(idEscalator)  
);

**CREATE** **TABLE** accessibilite.Traversee(  
   idTraversee VARCHAR(255),  
   etatRevetement VARCHAR(2),  
   marquageSol VARCHAR(2),  
   eclairage VARCHAR(2),  
   feuPietons BOOLEAN,  
   aideSonore VARCHAR(2),  
   repereLineaire VARCHAR(2),  
   presenceIlot BOOLEAN,  
   chausseeBombee BOOLEAN,  
   covisibilite VARCHAR(2),  
   PRIMARY **KEY**(idTraversee)  
);

**CREATE** **TABLE** accessibilite.Carroyage(  
   idCarreau VARCHAR(50),  
   ind NUMERIC(15,2),  
   ind\_0\_3 NUMERIC(15,2),  
   ind\_4\_5 NUMERIC(15,2),  
   ind\_6\_10 NUMERIC(15,2),  
   ind\_11\_17 NUMERIC(15,2),  
   ind\_18\_24 NUMERIC(15,2),  
   ind\_25\_39 NUMERIC(15,2),  
   ind\_40\_54 NUMERIC(15,2),  
   ind\_55\_64 NUMERIC(15,2),  
   ind\_65\_79 NUMERIC(15,2),  
   ind\_80 NUMERIC(15,2),  
   PRIMARY **KEY**(idCarreau)  
);

*\-- \======================*  
*\-- TRONCONS ET NOEUDS (accessibilite)*  
*\-- \======================*

**CREATE** **TABLE** accessibilite.Troncon\_Cheminement(  
   idTroncon VARCHAR(50),  
   from\_ VARCHAR(255),  
   to\_ VARCHAR(255),  
   longueur INTEGER,  
   typeTroncon VARCHAR(2),  
   statutVoie VARCHAR(2),  
   pente INTEGER,  
   devers INTEGER,  
   accessibiliteGlobale VARCHAR(2),  
   geom GEOMETRY **NOT** NULL,  
   idTraversee VARCHAR(255),  
   idEscalator VARCHAR(255),  
   idTapis VARCHAR(255),  
   idRampe VARCHAR(255),  
   idQuai VARCHAR(255),  
   idEscalier VARCHAR(255),  
   idCirculation VARCHAR(255),  
   idObstacle VARCHAR(255),  
   PRIMARY **KEY**(idTroncon),  
   FOREIGN **KEY**(idTraversee) **REFERENCES** accessibilite.Traversee(idTraversee),  
   FOREIGN **KEY**(idEscalator) **REFERENCES** accessibilite.Escalator(idEscalator),  
   FOREIGN **KEY**(idTapis) **REFERENCES** accessibilite.Tapis\_Roulant(idTapis),  
   FOREIGN **KEY**(idRampe) **REFERENCES** accessibilite.Rampe(idRampe),  
   FOREIGN **KEY**(idQuai) **REFERENCES** accessibilite.Quai(idQuai),  
   FOREIGN **KEY**(idEscalier) **REFERENCES** accessibilite.Escalier(idEscalier),  
   FOREIGN **KEY**(idCirculation) **REFERENCES** accessibilite.Circulation(idCirculation),  
   FOREIGN **KEY**(idObstacle) **REFERENCES** accessibilite.Obstacle(idObstacle)  
);

**CREATE** **TABLE** accessibilite.Noeud(  
   idNoeud VARCHAR(50),  
   altitude **DOUBLE** **PRECISION**,  
   bandeEveilVigilance VARCHAR(2),  
   hauteurRessaut **DOUBLE** **PRECISION**,  
   abaissePente INTEGER,  
   abaisseTrottoir **DOUBLE** **PRECISION**,  
   controleBEV VARCHAR(50),  
   bandeInterception BOOLEAN,  
   geom GEOMETRY **NOT** NULL,  
   idEntree VARCHAR(255) **NOT** NULL,  
   idPassageSelectif VARCHAR(255) **NOT** NULL,  
   idElevateur VARCHAR(255) **NOT** NULL,  
   idAscenseur VARCHAR(255) **NOT** NULL,  
   idCarreau VARCHAR(50) **NOT** NULL,  
   idTroncon VARCHAR(50) **NOT** NULL,  
   PRIMARY **KEY**(idNoeud),  
   **UNIQUE**(idEntree),  
   **UNIQUE**(idPassageSelectif),  
   **UNIQUE**(idElevateur),  
   **UNIQUE**(idAscenseur),  
   FOREIGN **KEY**(idEntree) **REFERENCES** accessibilite.Entree(idEntree),  
   FOREIGN **KEY**(idPassageSelectif) **REFERENCES** accessibilite.Passage\_Selectif(idPassageSelectif),  
   FOREIGN **KEY**(idElevateur) **REFERENCES** accessibilite.Elevateur(idElevateur),  
   FOREIGN **KEY**(idAscenseur) **REFERENCES** accessibilite.Ascenceur(idAscenseur),  
   FOREIGN **KEY**(idCarreau) **REFERENCES** accessibilite.Carroyage(idCarreau),  
   FOREIGN **KEY**(idTroncon) **REFERENCES** accessibilite.Troncon\_Cheminement(idTroncon)  
);

*\-- \======================*  
*\-- RELATIONS (accessibilite)*  
*\-- \======================*

**CREATE** **TABLE** accessibilite.est\_compose\_de(  
   idTroncon VARCHAR(50),  
   idCheminement VARCHAR(255),  
   PRIMARY **KEY**(idTroncon, idCheminement),  
   FOREIGN **KEY**(idTroncon) **REFERENCES** accessibilite.Troncon\_Cheminement(idTroncon),  
   FOREIGN **KEY**(idCheminement) **REFERENCES** accessibilite.Cheminement(idCheminement)  
);

**CREATE** **TABLE** accessibilite.donne\_acces\_a(  
   idNoeud VARCHAR(50),  
   idStationnement VARCHAR(255),  
   PRIMARY **KEY**(idNoeud, idStationnement),  
   FOREIGN **KEY**(idNoeud) **REFERENCES** accessibilite.Noeud(idNoeud),  
   FOREIGN **KEY**(idStationnement) **REFERENCES** accessibilite.Stationnement\_PMR(idStationnement)  
);

*\-- \======================*  
*\-- TRAVAUX TABLES (travaux)*  
*\-- \======================*

**CREATE** **TABLE** travaux.zone(  
   Id\_zone SERIAL,  
   nom\_zone VARCHAR(255),  
   debut DATE,  
   fin DATE,  
   statut VARCHAR(255),  
   libelle VARCHAR(255),  
   geom GEOMETRY(POLYGON,2154),  
   PRIMARY **KEY**(Id\_zone)  
);

**CREATE** **TABLE** travaux.impact\_accessibilite(  
   Id\_impact\_accessibilite SERIAL,  
   description VARCHAR(255),  
   coupure\_totale BOOLEAN,  
   recommandation VARCHAR(255),  
   Id\_zone INTEGER **NOT** NULL,  
   PRIMARY **KEY**(Id\_impact\_accessibilite),  
   FOREIGN **KEY**(Id\_zone) **REFERENCES** travaux.zone(Id\_zone)  
);

**CREATE** **TABLE** travaux.projet\_travaux(  
   Id\_projet\_travaux SERIAL,  
   nom\_chantier VARCHAR(255),  
   maitrise\_ouvrage VARCHAR(255),  
   contact\_responsable REAL,  
   num\_arrete VARCHAR(255),  
   Id\_zone INTEGER **NOT** NULL,  
   PRIMARY **KEY**(Id\_projet\_travaux),  
   FOREIGN **KEY**(Id\_zone) **REFERENCES** travaux.zone(Id\_zone)  
);

*\-- Table lien entre transport.STOP et accessibilite.Noeud*  
**CREATE** **TABLE** transport.donner\_acces\_a (  
    stop\_id VARCHAR(50),  
    idNoeud VARCHAR(50),  
    PRIMARY **KEY**(stop\_id, idNoeud),  
    FOREIGN **KEY**(stop\_id) **REFERENCES** transport.STOP(stop\_id),  
    FOREIGN **KEY**(idNoeud) **REFERENCES** accessibilite.Noeud(idNoeud)  
);

## 

[^1]:  [*https://www.legifrance.gouv.fr/dossierlegislatif/JORFDOLE000037646678/*](https://www.legifrance.gouv.fr/dossierlegislatif/JORFDOLE000037646678/)

[^2]:  [*https://www.legifrance.gouv.fr/codes/article\_lc/LEGIARTI000039671150*](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000039671150)

[^3]:  [*https://gtfs.org/fr/documentation/schedule/reference/*](https://gtfs.org/fr/documentation/schedule/reference/)

[^4]:  [*https://cnig.gouv.fr/IMG/pdf/250314\_standard\_cnig\_accessibilite\_v2021-10\_rev2025-03-2.pdf*](https://cnig.gouv.fr/IMG/pdf/250314_standard_cnig_accessibilite_v2021-10_rev2025-03-2.pdf)

[^5]:  [*https://www.ecologie.gouv.fr/politiques-publiques/directive-europeenne-inspire*](https://www.ecologie.gouv.fr/politiques-publiques/directive-europeenne-inspire)

[^6]:  [*https://opendata.paris.fr/explore/dataset/chantiers-a-paris/map/?disjunctive.chantier\_categorie\&disjunctive.chantier\_synthese\&disjunctive.moa\_principal\&disjunctive.cp\_arrondissement\&disjunctive.localisation\_detail\&disjunctive.localisation\_stationnement\&basemap=jawg.dark\&location=10,48.73648,2.35142*](https://opendata.paris.fr/explore/dataset/chantiers-a-paris/map/?disjunctive.chantier_categorie&disjunctive.chantier_synthese&disjunctive.moa_principal&disjunctive.cp_arrondissement&disjunctive.localisation_detail&disjunctive.localisation_stationnement&basemap=jawg.dark&location=10,48.73648,2.35142)

[^7]:  [*https://data.rennesmetropole.fr/explore/dataset/travaux\_30\_jours/map/?location=20,48.09032,-1.659\&basemap=0a029a*](https://data.rennesmetropole.fr/explore/dataset/travaux_30_jours/map/?location=20,48.09032,-1.659&basemap=0a029a)

[^8]:  *[https://datahub.bordeaux-metropole.fr/explore/dataset/ci\_chantier/dataviz/](https://datahub.bordeaux-metropole.fr/explore/dataset/ci_chantier/dataviz/)*

[^9]:  [*https://data.toulouse-metropole.fr/explore/dataset/chantiers-en-cours/map/?location=16,43.60452,1.506\&basemap=jawg.streets*](https://data.toulouse-metropole.fr/explore/dataset/chantiers-en-cours/map/?location=16,43.60452,1.506&basemap=jawg.streets)

[^10]:  [https://doc.cerema.fr/digitalCollection/DigitalCollectionAttachmentDownloadHandler.ashx?parentDocumentId=17391\&documentId=21669\&skipWatermark=true\&skipCopyright=true](https://doc.cerema.fr/digitalCollection/DigitalCollectionAttachmentDownloadHandler.ashx?parentDocumentId=17391&documentId=21669&skipWatermark=true&skipCopyright=true)

[image1]: <data:image/png;base64,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>