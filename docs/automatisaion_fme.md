# Automatisation du traitement FME avec un script Batch et planification
---

## 1. Création du script Batch (.bat)

Afin d’automatiser l’exécution du traitement FME, un script Batch a été créé.  
Ce script permet de lancer directement le workspace FME sans intervention manuelle.

Le script utilise deux variables :

- une variable pour définir le chemin de l’exécutable FME (`fme.exe`)  
- une variable pour définir le chemin du workspace (`.fmw`)  

***Contenu du fichier `arbre_stats.bat`***

```bat
@echo off

REM Définition des variables
set FME_EXE="C:\Program Files\FME\fme.exe"
set WORKSPACE="C:\Users\aguene\Downloads\FME_projet\EXERCICES\exo_arbre\work\arbres.fmw"

REM Exécution du traitement FME
%FME_EXE% %WORKSPACE%

pause
```

Ce script a été enregistré dans le dossier de travail du projet :
C:\Users\aguene\Downloads\FME_projet\EXERCICES\exo_arbre\work

Son exécution permet de lancer automatiquement le traitement FME et de générer les fichiers de sortie attendus.

## 2. Planification automatique avec le Planificateur de tâches Windows

Afin d’automatiser complètement le traitement, le script Batch a été planifié avec le Planificateur de tâches Windows.

### Paramètres de la tâche :

***Nom de la tâche :*** FME_arbre_hebdo

***Fréquence :*** Hebdomadaire

***Jour :*** (au choix, par exemple lundi)

***Heure :*** 13h00

***Action :*** Lancer un programme

***Programme exécuté :*** arbre_stats.bat


### Fonctionnement
Chaque semaine à 13h00 :

le script .bat est exécuté automatiquement
le logiciel FME est lancé
le workspace arbres.fmw est exécuté
les résultats sont générés sans intervention utilisateur


### Points importants
Pour que l’automatisation fonctionne correctement, il faut vérifier :

que le chemin vers fme.exe est correct
que le fichier .fmw existe au bon emplacement
que le PC est allumé à l’heure prévue
que la tâche est autorisée à s’exécuter même en arrière-plan


### Conclusion
Cette mise en place permet :

✅ d’automatiser complètement le traitement FME

✅ de garantir une exécution régulière sans intervention manuelle

✅ de simuler un cas réel utilisé en bureau d’étude ou en entreprise

Cette solution correspond à une pratique professionnelle courante en géomatique et en gestion de données automatisées.
