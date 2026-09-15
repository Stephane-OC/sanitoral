# DAX Sanitoral Project Performance Dashboard

![Sanitoral banner](../assets/images/sanitoral_banner.png)

Ce pack documente les formules du modèle sémantique Sanitoral : **112 mesures**, **13 colonnes calculées de phase**, **14 colonnes calculées de projet**, la table technique `_Measures` et trois rôles RLS de démonstration. Les noms correspondent aux objets du projet Power BI fourni.

Les fichiers `.dax` servent à lire, versionner et reproduire les formules. Power BI ne les importe pas automatiquement. Dans le projet `.pbip`, les définitions actives sont les fichiers `.tmdl` du dossier `SanitoralDashboard.SemanticModel/definition`.

## Modèle et grain des données

| Table | Rôle | Grain / relation |
|---|---|---|
| `Fact_ProjectPhase` | Table de faits : coûts, durées, livrables, dates et alertes | Une ligne par projet et phase, clé `Project_Phase_Key` |
| `Dim_Project` | Dimension des projets, géographie et types ; indicateurs cumulés du projet | Une ligne par `Project_ID` ; côté 1 de la relation vers `Fact_ProjectPhase[Project_ID]` |
| `Dim_Date` | Dimension calendrier | Une ligne par date ; côté 1 de la relation vers `Fact_ProjectPhase[Start_Date]` |
| `_Measures` | Conteneur technique des mesures | Sans relation, colonne `_Placeholder` masquée |

Les dimensions filtrent la table de faits. Cette organisation est un modèle en étoile avec deux dimensions ; un nombre imposé de cinq tables ne constitue pas une condition pour former une étoile. Les colonnes Région, Pays et Type décrivent ici le projet dans `Dim_Project`.

La préparation Power Query, les colonnes importées et les relations doivent exister avant la création des formules. Ce pack ne remplace pas les requêtes Power Query. La date `Actual_End_Date` provient du calcul de préparation des données : début de phase + durée réalisée. Le rapport l’intitule **Fin calculée**.

## Organisation des fichiers

| Fichier | Objets | Rôle |
|---|---:|---|
| `00_Create_Measures_Table.dax` | 1 table | Créer `_Measures` et masquer `_Placeholder` |
| `01_Phase_Calculated_Columns.dax` | 13 colonnes | Écarts, indicateurs binaires, sévérité et statuts au grain phase |
| `02_Portfolio_Measures.dax` | 11 mesures | Totaux, volumes et dates du portefeuille |
| `03_Performance_Variance_Measures.dax` | 10 mesures | Écarts entre réalisé et prévu |
| `04_Alert_Measures.dax` | 15 mesures | Comptages et taux d’alerte |
| `05_Reporting_and_Storytelling_Measures.dax` | 7 mesures | Contexte et textes explicatifs |
| `06_RLS_Roles.dax` | 3 rôles | Périmètres de démonstration : monde, région, pays |
| `07_Detail_And_Country_Performance.dax` | 22 mesures | Retards, avances, exposition et lecture pays/projet |
| `08_Project_Calculated_Columns.dax` | 14 colonnes | Cumul de toutes les phases, dates du projet et légende cartographique |
| `09_Project_Level_Measures.dax` | 21 mesures | Statuts et écarts cumulés, synthèse pays, contrôle de sélection |
| `10_Presentation_Measures.dax` | 26 mesures | Couleurs, calendrier, contexte et indicateurs de la fiche projet |

### Dossiers d’affichage « Présentation » et « Pilotage »

Toutes les mesures restent dans **la même table `_Measures`**. Deux dossiers d’affichage organisent les mesures : **Présentation** contient 28 mesures de synthèse, statuts et contexte ; **Pilotage** contient 26 mesures de détail, planning et couleurs. Les 58 autres mesures restent à la racine de `_Measures`. Le dossier `Pilotage` regroupe les mesures du fichier `10_Presentation_Measures.dax` ; le nom du fichier indique leur fonction et ne fixe pas leur dossier dans Power BI. Ces dossiers ne créent ni table de données supplémentaire ni relation.

- `Phase … Color`, `Phase Severity Color` et `Portfolio Cost Color` renvoient une couleur utilisable par la mise en forme conditionnelle.
- `Project Start`, `Project Planned Finish`, `Project Calculated Finish` et `Project Finish Variance Days` présentent les dates et le décalage du projet sélectionné.
- `Planning First Start` et `Planning Last Finish` affichent les bornes du planning dans le périmètre filtré.
- Les mesures `Detail Planned …`, `Detail Actual …`, `Detail Late Phases` et `Detail Duration Alert Phases` conditionnent l’affichage des cartes à la sélection d’un seul projet ; elles réutilisent les mesures de base.
- `Detail Country Rank` calcule un classement du pays sur le périmètre mondial accessible, indépendamment du filtre du projet sélectionné.
- Les mesures de contexte et de synthèse produisent des textes adaptés à la sélection : `Detail Project Context`, `Detail Deadline Summary`, `Detail Deliverables Summary`, `Detail Summary`, `Alert Page Summary` et `Planning Summary`.

Les libellés français d’une vignette ou d’une colonne peuvent différer du nom technique de la mesure. Par exemple, « Projets suivis » affiche `Total Projects`. Modifier ce libellé dans un visuel ne renomme pas la mesure dans le modèle.

## Règles de calcul et interprétation

### Phases et projets

Les colonnes de `Fact_ProjectPhase` évaluent chaque phase. Les colonnes calculées de `Dim_Project` agrègent toutes les phases d’un projet au chargement du modèle. Les pourcentages cumulés sont calculés à partir des sommes ; ce ne sont pas des moyennes des pourcentages de phase.

- Durée / coût : `(réalisé − prévu) / prévu`. Alerte dès **+15 %**.
- Livrables : `(réalisé − prévu) / prévu`. Alerte dès **−15 %**.
- `Projects in Alert` compte les projets en **alerte de durée cumulée** ; `Alert Project Rate` rapporte ce nombre aux projets évaluables en durée : `[Total Projects] − [Duration Unknown Projects]`.
- `Overall Alert Projects` compte les projets présentant au moins un critère cumulé en alerte (durée, coût ou livrables).
- `Projects on Track` correspond au statut de durée « Hors alerte ». `Duration Unknown Projects` conserve les cas non évaluables ; ils ne sont pas automatiquement considérés conformes.
- `Late Phases` compte les phases dont la fin calculée dépasse la fin prévue de plus de zéro jour ; `Duration Alert Phases` applique le seuil relatif de +15 %. Ces indicateurs répondent à des questions différentes.
- `Alert_Count` vaut 0, 1, 2 ou 3 selon le nombre de critères de phase en alerte. `Alert_Severity` donne Conforme, À surveiller, Élevée ou Critique. Une phase peut cumuler plusieurs types d’alerte : les comptages par type ne doivent pas être additionnés pour obtenir un nombre de phases distinctes.

« Hors alerte » signifie que le seuil n’est pas atteint ; cela peut inclure un petit dépassement. Les contrôles de valeurs absentes et de dénominateurs non positifs sont définis dans les formules. Les comptages explicitement entourés de `COALESCE` affichent zéro lorsque leur résultat est vide ; les indicateurs non évaluables peuvent rester vides.

### Planning et filtres

La barre du Gantt projet va du premier début à la dernière fin prévue. Cette étendue calendaire diffère de la somme des durées lorsque les phases se chevauchent. La dernière fin calculée n’est pas une date de clôture saisie. Aucun taux d’avancement temporel n’est déduit arbitrairement de ces données.

Le filtre de date de **Vue d’ensemble** et **Planning et Gantt** porte sur le début des projets. Celui d’**Analyse des alertes** porte sur le début des phases. Les statuts cumulés des projets restent évalués sur leur cycle complet. L’évolution mensuelle regroupe les phases par mois de début ; elle ne constitue pas un historique de leurs statuts successifs.

L’extraction vers **Détail projet** transmet le projet et conserve l’accès à toutes ses phases. Les indicateurs du détail sont protégés par la sélection d’un seul projet. Les mesures de rang mondial retirent les filtres analytiques prévus par leur formule ; elles ne contournent pas la sécurité RLS.

### Couleurs

Les Gantt, la carte et les statuts de durée utilisent rose/rouge pour l’alerte, vert sous le seuil et gris pour un statut non évaluable. Le texte de statut et la légende complètent la couleur. Dans les graphiques qui comparent les **types** d’alerte, cyan = coût, violet = durée et rose = livrables : ces couleurs identifient les catégories.

## Utilisation du pack

Si le projet fourni est déjà ouvert, il contient les mesures : il n’est pas nécessaire de les recréer. Pour consulter une formule, sélectionner sa mesure dans `_Measures`.

Pour une reconstruction manuelle :

1. Préparer les trois tables métier et les deux relations.
2. Créer `_Measures` avec le fichier `00`, puis masquer `_Placeholder`.
3. Créer les colonnes du fichier `01` dans `Fact_ProjectPhase`, puis celles du fichier `08` dans `Dim_Project`, dans l’ordre de chaque fichier.
4. Créer les mesures dans `_Measures`, en suivant l’ordre de dépendances donné en fin de document. Les fichiers sont regroupés par fonction, pas par ordre strict de création.
5. Copier un seul bloc `Nom = formule` dans **Nouvelle mesure** ou **Nouvelle colonne**. Les commentaires et définitions suivantes ne font pas partie de ce bloc.
6. Appliquer le format indiqué dans le catalogue. Affecter les dossiers d’affichage indiqués dans le catalogue ci-dessous. Les fichiers thématiques et les dossiers d’affichage sont deux organisations complémentaires.
7. Créer les rôles du fichier `06` et les tester avec **Voir comme**. Les rôles France et Western Europe sont des exemples statiques.

Les mesures contenant `REMOVEFILTERS`, `CALCULATE`, `HASONEVALUE` ou `SELECTEDVALUE` doivent conserver leur formule complète pour préserver le contexte de calcul.

## Contrôles de cohérence

Les formules de ce pack correspondent aux définitions TMDL du projet fourni, sans renommage des mesures existantes. La vérification des fichiers ne remplace pas l’exécution dans Power BI Desktop.

Avec les données et captures de référence, sans filtre, les repères sont **104 projets**, **8 alertes de durée cumulée**, environ **7,7 %** de projets en alerte de durée et **159 phases en alerte de durée**. Ces nombres servent à vérifier le rapport ; ils ne sont pas écrits dans les formules des indicateurs.

Tester également un pays avec plusieurs projets, l’extraction d’un seul projet, les phases hors alerte, les cas non évaluables et les rôles RLS.

## Catalogue des mesures

Le format est celui enregistré dans le modèle ; « Général / texte » signifie qu’aucun format explicite n’est défini. Les noms ci-dessous sont les noms techniques exacts.

### 02_Portfolio_Measures.dax

| Mesure | Format | Dossier d’affichage |
|---|---|---|
| `Total Projects` | `0` | Présentation |
| `Total Phases` | `0` | Présentation |
| `Planned Cost` | `#,0` | Racine de `_Measures` |
| `Actual Cost` | `#,0` | Racine de `_Measures` |
| `Planned Duration` | `0` | Racine de `_Measures` |
| `Actual Duration` | `0` | Racine de `_Measures` |
| `Planned Deliverables` | `0` | Racine de `_Measures` |
| `Actual Deliverables` | `0` | Racine de `_Measures` |
| `First Project Start Date` | `General Date` | Racine de `_Measures` |
| `Last Planned End Date` | `General Date` | Racine de `_Measures` |
| `Last Actual End Date` | `General Date` | Racine de `_Measures` |

### 03_Performance_Variance_Measures.dax

| Mesure | Format | Dossier d’affichage |
|---|---|---|
| `Cost Variance` | `#,0` | Racine de `_Measures` |
| `Cost Variance %` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Cost Performance Status` | `Général / texte` | Racine de `_Measures` |
| `Duration Variance` | `0` | Racine de `_Measures` |
| `Duration Variance %` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Duration Performance Status` | `Général / texte` | Racine de `_Measures` |
| `Deliverable Variance` | `0` | Racine de `_Measures` |
| `Deliverable Variance %` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Deliverable Completion Rate` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Deliverable Performance Status` | `Général / texte` | Racine de `_Measures` |

### 04_Alert_Measures.dax

| Mesure | Format | Dossier d’affichage |
|---|---|---|
| `Cost Alert Phases` | `0` | Racine de `_Measures` |
| `Duration Alert Phases` | `0` | Racine de `_Measures` |
| `Deliverable Alert Phases` | `0` | Racine de `_Measures` |
| `Alert Phases` | `0` | Racine de `_Measures` |
| `On Track Phases` | `0` | Racine de `_Measures` |
| `Projects in Alert` | `0` | Présentation |
| `Projects on Track` | `0` | Présentation |
| `Alert Project Rate` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Projects with Cost Alert` | `0` | Présentation |
| `Projects with Duration Alert` | `0` | Présentation |
| `Projects with Deliverable Alert` | `0` | Présentation |
| `Critical Alert Phases` | `0` | Racine de `_Measures` |
| `High Alert Phases` | `0` | Racine de `_Measures` |
| `Watch Alert Phases` | `0` | Présentation |
| `Alert Color` | `Général / texte` | Racine de `_Measures` |

### 05_Reporting_and_Storytelling_Measures.dax

| Mesure | Format | Dossier d’affichage |
|---|---|---|
| `Selected Scope` | `Général / texte` | Présentation |
| `Visible Scope Level` | `Général / texte` | Présentation |
| `Selected Project` | `Général / texte` | Présentation |
| `Data Period` | `Général / texte` | Racine de `_Measures` |
| `Executive Narrative` | `Général / texte` | Racine de `_Measures` |
| `Performance Narrative` | `Général / texte` | Racine de `_Measures` |
| `Selected Project Alert Summary` | `Général / texte` | Présentation |

### 07_Detail_And_Country_Performance.dax

| Mesure | Format | Dossier d’affichage |
|---|---|---|
| `Late Phases` | `0` | Racine de `_Measures` |
| `Early Phases` | `0` | Racine de `_Measures` |
| `On Time Deadline Phases` | `0` | Racine de `_Measures` |
| `Late Phase Rate` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Average Delay Days` | `0.0` | Racine de `_Measures` |
| `Average Advance Days` | `0.0` | Racine de `_Measures` |
| `Delay Exposure Days` | `0.0` | Racine de `_Measures` |
| `Advance Exposure Days` | `0.0` | Racine de `_Measures` |
| `Country Late Phases` | `0` | Racine de `_Measures` |
| `Country Early Phases` | `0` | Racine de `_Measures` |
| `Country Late Phase Rate` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Country Average Delay Days` | `0.0` | Racine de `_Measures` |
| `Country Average Advance Days` | `0.0` | Racine de `_Measures` |
| `Country Delay Exposure Days` | `0.0` | Racine de `_Measures` |
| `Country Advance Exposure Days` | `0.0` | Racine de `_Measures` |
| `Countries Analyzed` | `0` | Racine de `_Measures` |
| `Most Delayed Country` | `Général / texte` | Racine de `_Measures` |
| `Most Advanced Country` | `Général / texte` | Racine de `_Measures` |
| `Selected Project Context` | `Général / texte` | Présentation |
| `Selected Project Detail Narrative` | `Général / texte` | Présentation |
| `Selected Country Delay Rank` | `0` | Présentation |
| `Selected Country Rank Label` | `Général / texte` | Présentation |

### 09_Project_Level_Measures.dax

| Mesure | Format | Dossier d’affichage |
|---|---|---|
| `Duration Unknown Projects` | `0` | Racine de `_Measures` |
| `Overall Alert Projects` | `0` | Racine de `_Measures` |
| `Overall On Track Projects` | `0` | Racine de `_Measures` |
| `Overall Unknown Projects` | `0` | Racine de `_Measures` |
| `Overall Alert Project Rate` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Project Duration Variance %` | `0.0\ %;-0.0\ %;0.0\ %` | Présentation |
| `Project Cost Variance %` | `0.0\ %;-0.0\ %;0.0\ %` | Présentation |
| `Project Deliverable Variance %` | `0.0\ %;-0.0\ %;0.0\ %` | Présentation |
| `Project Duration Status` | `Général / texte` | Présentation |
| `Project Cost Status` | `Général / texte` | Présentation |
| `Project Deliverable Status` | `Général / texte` | Présentation |
| `Project Overall Status` | `Général / texte` | Présentation |
| `Project Duration Color` | `Général / texte` | Présentation |
| `Project Cost Color` | `Général / texte` | Présentation |
| `Project Deliverable Color` | `Général / texte` | Présentation |
| `Country Duration Status` | `Général / texte` | Racine de `_Measures` |
| `Country Duration Color` | `Général / texte` | Racine de `_Measures` |
| `Portfolio Countries` | `0` | Racine de `_Measures` |
| `Max Project Duration Variance %` | `0.0\ %;-0.0\ %;0.0\ %` | Racine de `_Measures` |
| `Project Detail Available` | `0` | Présentation |
| `Project Detail Instruction` | `Général / texte` | Présentation |

### 10_Presentation_Measures.dax

| Mesure | Format | Dossier d’affichage |
|---|---|---|
| `Detail Planned Cost` | `#,0` | Pilotage |
| `Detail Project Context` | `Général / texte` | Pilotage |
| `Detail Actual Cost` | `#,0` | Pilotage |
| `Detail Planned Duration` | `0" j"` | Pilotage |
| `Detail Actual Duration` | `0" j"` | Pilotage |
| `Detail Late Phases` | `0` | Pilotage |
| `Detail Summary` | `Général / texte` | Pilotage |
| `Detail Deadline Summary` | `Général / texte` | Pilotage |
| `Detail Country Rank` | `Général / texte` | Pilotage |
| `Detail Deliverables Summary` | `Général / texte` | Pilotage |
| `Project Start` | `dd/MM/yyyy` | Pilotage |
| `Project Planned Finish` | `dd/MM/yyyy` | Pilotage |
| `Project Finish Variance Days` | `+0;-0;0` | Pilotage |
| `Project Calculated Finish` | `dd/MM/yyyy` | Pilotage |
| `Planning Last Finish` | `dd/MM/yyyy` | Pilotage |
| `Planning First Start` | `dd/MM/yyyy` | Pilotage |
| `Planning Summary` | `Général / texte` | Pilotage |
| `Alert Page Summary` | `Général / texte` | Pilotage |
| `Detail Actual Deliverables` | `0` | Pilotage |
| `Phase Cost Color` | `Général / texte` | Pilotage |
| `Phase Deliverable Color` | `Général / texte` | Pilotage |
| `Phase Duration Color` | `Général / texte` | Pilotage |
| `Phase Severity Color` | `Général / texte` | Pilotage |
| `Portfolio Cost Color` | `Général / texte` | Pilotage |
| `Detail Duration Alert Phases` | `0` | Pilotage |
| `Detail Planned Deliverables` | `0` | Pilotage |

## Catalogue des colonnes calculées

### Fact_ProjectPhase

| Colonne | Type | Format |
|---|---|---|
| `Cost_Variance_Pct_Phase` |  | `0.0\ %;-0.0\ %;0.0\ %` |
| `Duration_Variance_Pct_Phase` |  | `0.0\ %;-0.0\ %;0.0\ %` |
| `Deliverable_Variance_Pct_Phase` |  | `0.0\ %;-0.0\ %;0.0\ %` |
| `Cost_Alert_Flag` |  | `0` |
| `Duration_Alert_Flag` |  | `0` |
| `Deliverable_Alert_Flag` |  | `0` |
| `Alert_Count` |  | `0` |
| `Alert_Flag` |  | `0` |
| `Alert_Severity` |  | `Général` |
| `Deadline_Variance_Days_Phase` |  | `0` |
| `Phase_Duration_Status` |  | `Général` |
| `Phase_Cost_Status` |  | `Général` |
| `Phase_Deliverable_Status` |  | `Général` |

Les colonnes calculées descriptives, de statut et de pourcentage ne doivent pas être additionnées dans les visuels. Les mesures réalisent les agrégations nécessaires.

### Dim_Project

| Colonne | Type | Format |
|---|---|---|
| `Project_Phase_Count` |  | `0` |
| `Project_Start_Date` |  | `yyyy-MM-dd` |
| `Project_Planned_End_Date` |  | `yyyy-MM-dd` |
| `Project_Actual_End_Date_Derived` |  | `yyyy-MM-dd` |
| `Project_Planned_Span_Days` |  | `0` |
| `Project_Start_Month` |  | `yyyy-MM` |
| `Project_Duration_Variance_Pct` |  | `0.0\ %;-0.0\ %;0.0\ %` |
| `Project_Cost_Variance_Pct` |  | `0.0\ %;-0.0\ %;0.0\ %` |
| `Project_Deliverable_Variance_Pct` |  | `0.0\ %;-0.0\ %;0.0\ %` |
| `Project_Duration_Status` |  | `Général` |
| `Project_Cost_Status` |  | `Général` |
| `Project_Deliverable_Status` |  | `Général` |
| `Project_Alert_Status` |  | `Général` |
| `Country_Map_Legend` |  | `Général` |

Les colonnes calculées descriptives, de statut et de pourcentage ne doivent pas être additionnées dans les visuels. Les mesures réalisent les agrégations nécessaires.

## Ordre de création des mesures

Cet ordre respecte les dépendances entre les 112 mesures. Le fichier associé permet de retrouver chaque formule.

| Ordre | Mesure | Fichier |
|---:|---|---|
| 1 | `Total Projects` | `02_Portfolio_Measures.dax` |
| 2 | `Total Phases` | `02_Portfolio_Measures.dax` |
| 3 | `Planned Cost` | `02_Portfolio_Measures.dax` |
| 4 | `Actual Cost` | `02_Portfolio_Measures.dax` |
| 5 | `Planned Duration` | `02_Portfolio_Measures.dax` |
| 6 | `Actual Duration` | `02_Portfolio_Measures.dax` |
| 7 | `Planned Deliverables` | `02_Portfolio_Measures.dax` |
| 8 | `Actual Deliverables` | `02_Portfolio_Measures.dax` |
| 9 | `First Project Start Date` | `02_Portfolio_Measures.dax` |
| 10 | `Last Planned End Date` | `02_Portfolio_Measures.dax` |
| 11 | `Last Actual End Date` | `02_Portfolio_Measures.dax` |
| 12 | `Selected Scope` | `05_Reporting_and_Storytelling_Measures.dax` |
| 13 | `Visible Scope Level` | `05_Reporting_and_Storytelling_Measures.dax` |
| 14 | `Selected Project` | `05_Reporting_and_Storytelling_Measures.dax` |
| 15 | `Average Delay Days` | `07_Detail_And_Country_Performance.dax` |
| 16 | `Average Advance Days` | `07_Detail_And_Country_Performance.dax` |
| 17 | `Countries Analyzed` | `07_Detail_And_Country_Performance.dax` |
| 18 | `Project Duration Variance %` | `09_Project_Level_Measures.dax` |
| 19 | `Project Cost Variance %` | `09_Project_Level_Measures.dax` |
| 20 | `Project Deliverable Variance %` | `09_Project_Level_Measures.dax` |
| 21 | `Project Duration Status` | `09_Project_Level_Measures.dax` |
| 22 | `Project Cost Status` | `09_Project_Level_Measures.dax` |
| 23 | `Project Deliverable Status` | `09_Project_Level_Measures.dax` |
| 24 | `Project Overall Status` | `09_Project_Level_Measures.dax` |
| 25 | `Project Start` | `10_Presentation_Measures.dax` |
| 26 | `Project Planned Finish` | `10_Presentation_Measures.dax` |
| 27 | `Project Calculated Finish` | `10_Presentation_Measures.dax` |
| 28 | `Planning Last Finish` | `10_Presentation_Measures.dax` |
| 29 | `Planning First Start` | `10_Presentation_Measures.dax` |
| 30 | `Phase Cost Color` | `10_Presentation_Measures.dax` |
| 31 | `Phase Deliverable Color` | `10_Presentation_Measures.dax` |
| 32 | `Phase Duration Color` | `10_Presentation_Measures.dax` |
| 33 | `Phase Severity Color` | `10_Presentation_Measures.dax` |
| 34 | `Cost Variance` | `03_Performance_Variance_Measures.dax` |
| 35 | `Duration Variance` | `03_Performance_Variance_Measures.dax` |
| 36 | `Deliverable Variance` | `03_Performance_Variance_Measures.dax` |
| 37 | `Deliverable Completion Rate` | `03_Performance_Variance_Measures.dax` |
| 38 | `Cost Alert Phases` | `04_Alert_Measures.dax` |
| 39 | `Duration Alert Phases` | `04_Alert_Measures.dax` |
| 40 | `Deliverable Alert Phases` | `04_Alert_Measures.dax` |
| 41 | `Alert Phases` | `04_Alert_Measures.dax` |
| 42 | `Projects in Alert` | `04_Alert_Measures.dax` |
| 43 | `Projects on Track` | `04_Alert_Measures.dax` |
| 44 | `Projects with Cost Alert` | `04_Alert_Measures.dax` |
| 45 | `Projects with Deliverable Alert` | `04_Alert_Measures.dax` |
| 46 | `Critical Alert Phases` | `04_Alert_Measures.dax` |
| 47 | `High Alert Phases` | `04_Alert_Measures.dax` |
| 48 | `Watch Alert Phases` | `04_Alert_Measures.dax` |
| 49 | `Data Period` | `05_Reporting_and_Storytelling_Measures.dax` |
| 50 | `Late Phases` | `07_Detail_And_Country_Performance.dax` |
| 51 | `Early Phases` | `07_Detail_And_Country_Performance.dax` |
| 52 | `On Time Deadline Phases` | `07_Detail_And_Country_Performance.dax` |
| 53 | `Delay Exposure Days` | `07_Detail_And_Country_Performance.dax` |
| 54 | `Advance Exposure Days` | `07_Detail_And_Country_Performance.dax` |
| 55 | `Country Average Delay Days` | `07_Detail_And_Country_Performance.dax` |
| 56 | `Country Average Advance Days` | `07_Detail_And_Country_Performance.dax` |
| 57 | `Selected Project Context` | `07_Detail_And_Country_Performance.dax` |
| 58 | `Duration Unknown Projects` | `09_Project_Level_Measures.dax` |
| 59 | `Overall Alert Projects` | `09_Project_Level_Measures.dax` |
| 60 | `Overall On Track Projects` | `09_Project_Level_Measures.dax` |
| 61 | `Overall Unknown Projects` | `09_Project_Level_Measures.dax` |
| 62 | `Project Duration Color` | `09_Project_Level_Measures.dax` |
| 63 | `Project Cost Color` | `09_Project_Level_Measures.dax` |
| 64 | `Project Deliverable Color` | `09_Project_Level_Measures.dax` |
| 65 | `Portfolio Countries` | `09_Project_Level_Measures.dax` |
| 66 | `Max Project Duration Variance %` | `09_Project_Level_Measures.dax` |
| 67 | `Project Detail Available` | `09_Project_Level_Measures.dax` |
| 68 | `Project Finish Variance Days` | `10_Presentation_Measures.dax` |
| 69 | `Cost Variance %` | `03_Performance_Variance_Measures.dax` |
| 70 | `Duration Variance %` | `03_Performance_Variance_Measures.dax` |
| 71 | `Deliverable Variance %` | `03_Performance_Variance_Measures.dax` |
| 72 | `On Track Phases` | `04_Alert_Measures.dax` |
| 73 | `Alert Project Rate` | `04_Alert_Measures.dax` |
| 74 | `Projects with Duration Alert` | `04_Alert_Measures.dax` |
| 75 | `Alert Color` | `04_Alert_Measures.dax` |
| 76 | `Selected Project Alert Summary` | `05_Reporting_and_Storytelling_Measures.dax` |
| 77 | `Late Phase Rate` | `07_Detail_And_Country_Performance.dax` |
| 78 | `Country Late Phases` | `07_Detail_And_Country_Performance.dax` |
| 79 | `Country Early Phases` | `07_Detail_And_Country_Performance.dax` |
| 80 | `Country Delay Exposure Days` | `07_Detail_And_Country_Performance.dax` |
| 81 | `Country Advance Exposure Days` | `07_Detail_And_Country_Performance.dax` |
| 82 | `Selected Project Detail Narrative` | `07_Detail_And_Country_Performance.dax` |
| 83 | `Overall Alert Project Rate` | `09_Project_Level_Measures.dax` |
| 84 | `Country Duration Status` | `09_Project_Level_Measures.dax` |
| 85 | `Country Duration Color` | `09_Project_Level_Measures.dax` |
| 86 | `Project Detail Instruction` | `09_Project_Level_Measures.dax` |
| 87 | `Detail Planned Cost` | `10_Presentation_Measures.dax` |
| 88 | `Detail Project Context` | `10_Presentation_Measures.dax` |
| 89 | `Detail Actual Cost` | `10_Presentation_Measures.dax` |
| 90 | `Detail Planned Duration` | `10_Presentation_Measures.dax` |
| 91 | `Detail Actual Duration` | `10_Presentation_Measures.dax` |
| 92 | `Detail Late Phases` | `10_Presentation_Measures.dax` |
| 93 | `Detail Summary` | `10_Presentation_Measures.dax` |
| 94 | `Detail Deadline Summary` | `10_Presentation_Measures.dax` |
| 95 | `Detail Country Rank` | `10_Presentation_Measures.dax` |
| 96 | `Detail Deliverables Summary` | `10_Presentation_Measures.dax` |
| 97 | `Planning Summary` | `10_Presentation_Measures.dax` |
| 98 | `Alert Page Summary` | `10_Presentation_Measures.dax` |
| 99 | `Detail Actual Deliverables` | `10_Presentation_Measures.dax` |
| 100 | `Detail Duration Alert Phases` | `10_Presentation_Measures.dax` |
| 101 | `Detail Planned Deliverables` | `10_Presentation_Measures.dax` |
| 102 | `Cost Performance Status` | `03_Performance_Variance_Measures.dax` |
| 103 | `Duration Performance Status` | `03_Performance_Variance_Measures.dax` |
| 104 | `Deliverable Performance Status` | `03_Performance_Variance_Measures.dax` |
| 105 | `Executive Narrative` | `05_Reporting_and_Storytelling_Measures.dax` |
| 106 | `Performance Narrative` | `05_Reporting_and_Storytelling_Measures.dax` |
| 107 | `Country Late Phase Rate` | `07_Detail_And_Country_Performance.dax` |
| 108 | `Most Delayed Country` | `07_Detail_And_Country_Performance.dax` |
| 109 | `Most Advanced Country` | `07_Detail_And_Country_Performance.dax` |
| 110 | `Selected Country Delay Rank` | `07_Detail_And_Country_Performance.dax` |
| 111 | `Portfolio Cost Color` | `10_Presentation_Measures.dax` |
| 112 | `Selected Country Rank Label` | `07_Detail_And_Country_Performance.dax` |

## Références

- [Modèle en étoile Power BI](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema)
- [Définition des projets Power BI](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-report)
- [Extraction vers le détail projet](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-drillthrough)
