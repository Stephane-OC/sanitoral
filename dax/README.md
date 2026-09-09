# Pack DAX • Sanitoral Project Performance Dashboard 

![Sanitoral banner](../assets/images/sanitoral_banner.png)

Ce document explique comment reproduire la partie DAX du projet Sanitoral dans Power BI Desktop. Il précise, pour chaque objet, son nom exact, son type, son emplacement, son format et son rôle dans le rapport.

> Les fichiers `.dax` sont des fichiers de documentation et de versionnement. Power BI ne les importe pas automatiquement. Il faut créer chaque table, colonne, mesure ou rôle dans Power BI, puis copier uniquement la formule correspondante.

## 1. État actuel du projet

La préparation Power Query et le modèle en étoile sont déjà opérationnels. Le projet contient :

- `Fact_ProjectPhase`, avec une ligne par projet et par phase ;
- `Dim_Project`, reliée à la table de faits par `Project_ID` ;
- `Dim_Date`, reliée à la table de faits par `Start_Date` ;
- une relation active `Dim_Project[Project_ID]` → `Fact_ProjectPhase[Project_ID]` ;
- une relation active `Dim_Date[Date]` → `Fact_ProjectPhase[Start_Date]` ;
- la date automatique désactivée et `Dim_Date` marquée comme table de dates.

Avancement DAX au moment de cette version :

- [x] `00_Create_Measures_Table.dax` • table `_Measures` créée ;
- [x] `01_Phase_Calculated_Columns.dax` • 10 colonnes calculées créées ;
- [x] `02_Portfolio_Measures.dax` • 11 mesures de base créées ;
- [x] `03_Performance_Variance_Measures.dax` • mesures d'écart à créer ;
- [x] `04_Alert_Measures.dax` • mesures d'alerte à créer ;
- [x] `05_Reporting_and_Storytelling_Measures.dax` • mesures de texte à créer ;
- [x] `06_RLS_Roles.dax` • rôles de démonstration à créer ;
- [x] `07_Detail_And_Country_Performance.dax` • mesures de détail projet et de performance pays à créer.

## 2. Contenu du pack

| Fichier | Type d'objet | Nombre | Utilisation |
|---|---|---:|---|
| `00_Create_Measures_Table.dax` | Table calculée | 1 | Centraliser les mesures dans `_Measures` |
| `01_Phase_Calculated_Columns.dax` | Colonnes calculées | 10 | Calculer les écarts et alertes de chaque phase |
| `02_Portfolio_Measures.dax` | Mesures | 11 | Créer les totaux du portefeuille |
| `03_Performance_Variance_Measures.dax` | Mesures | 10 | Comparer les valeurs réelles et prévisionnelles |
| `04_Alert_Measures.dax` | Mesures | 15 | Compter les phases et projets en alerte |
| `05_Reporting_and_Storytelling_Measures.dax` | Mesures | 7 | Créer les titres et textes narratifs |
| `06_RLS_Roles.dax` | Rôles RLS | 3 | Simuler les périmètres mondial, régional et pays |
| `07_Detail_And_Country_Performance.dax` | Mesures | 22 | Analyser les retards, les avances, le détail projet et la performance des pays |

Au total, le pack définit une table calculée, 10 colonnes calculées, 65 mesures et 3 rôles RLS.

## 3. Différence entre les objets DAX

| Objet | Bouton Power BI | Emplacement | Calcul |
|---|---|---|---|
| Table calculée | **Accueil ou Modélisation > Nouvelle table** | Nouvelle table du modèle | Une fois au chargement du modèle |
| Colonne calculée | Sélectionner la table, puis **Nouvelle colonne** | Dans chaque ligne de la table sélectionnée | Une valeur par ligne |
| Mesure | Sélectionner `_Measures`, puis **Nouvelle mesure** | Table principale `_Measures` | Selon les filtres du visuel |
| Rôle RLS | **Modélisation > Gérer les rôles** | Filtre appliqué à `Dim_Project` | Selon le rôle testé ou attribué |

Une mesure doit afficher l'icône de calculatrice. Une colonne calculée reste dans `Fact_ProjectPhase` et affiche une icône de colonne calculée. Si une mesure apparaît dans une autre table, sélectionner la mesure et définir **Table principale** sur `_Measures`.

## 4. Méthode de copie des formules

Pour chaque objet :

1. ouvrir le fichier `.dax` concerné ;
2. repérer le nom exact de l'objet ;
3. dans Power BI, cliquer sur le bouton indiqué dans ce README ;
4. copier uniquement le bloc commençant par `Nom de l'objet =` et se terminant à la fin de sa formule ;
5. valider avec **Entrée** ou la coche ;
6. régler les propriétés de format indiquées ci-dessous ;
7. passer à l'objet suivant.

Ne pas coller un fichier contenant plusieurs définitions dans une seule colonne ou une seule mesure.

## 5. Fichier 00 • Table technique `_Measures`

### Création

1. Ouvrir la vue **Modèle**.
2. Cliquer sur **Accueil > Nouvelle table** ou **Modélisation > Nouvelle table**.
3. Copier la formule de `00_Create_Measures_Table.dax`.
4. Valider la formule.
5. Masquer la colonne `_Placeholder` dans la vue Rapport.

| Nom | Type d'objet | Type de données | Format | Décimales | Résumer par | Utilisation |
|---|---|---|---|---:|---|---|
| `_Measures` | Table calculée | — | — | — | — | Contenir toutes les mesures du rapport |
| `_Placeholder` | Colonne technique | Nombre entier | Général | 0 | Aucun | Permettre l'existence de la table ; à masquer |

## 6. Fichier 01 • Colonnes calculées de `Fact_ProjectPhase`

### Création

Pour chaque ligne du tableau ci-dessous :

1. sélectionner `Fact_ProjectPhase` ;
2. cliquer sur **Nouvelle colonne** ;
3. copier la formule portant le même nom depuis `01_Phase_Calculated_Columns.dax` ;
4. valider ;
5. appliquer les propriétés indiquées ;
6. respecter strictement l'ordre de création.

| Ordre | Nom exact | Type | Format | Décimales | Résumer par | Interprétation |
|---:|---|---|---|---:|---|---|
| 1 | `Cost_Variance_Pct_Phase` | Nombre décimal | Pourcentage | 1 | Aucun | Écart relatif coût ; positif = dépassement |
| 2 | `Duration_Variance_Pct_Phase` | Nombre décimal | Pourcentage | 1 | Aucun | Écart relatif durée ; positif = retard |
| 3 | `Deliverable_Variance_Pct_Phase` | Nombre décimal | Pourcentage | 1 | Aucun | Écart relatif livrables ; négatif = manque |
| 4 | `Deadline_Variance_Days_Phase` | Nombre entier | Nombre entier | 0 | Aucun | Jours entre fin prévue et fin réelle ; positif = retard |
| 5 | `Cost_Alert_Flag` | Nombre entier | Nombre entier | 0 | Aucun | `1` si le dépassement de coût atteint 15 %, sinon `0` |
| 6 | `Duration_Alert_Flag` | Nombre entier | Nombre entier | 0 | Aucun | `1` si le dépassement de durée atteint 15 %, sinon `0` |
| 7 | `Deliverable_Alert_Flag` | Nombre entier | Nombre entier | 0 | Aucun | `1` si le manque de livrables atteint 15 %, sinon `0` |
| 8 | `Alert_Count` | Nombre entier | Nombre entier | 0 | Aucun | Nombre de critères en alerte, de 0 à 3 |
| 9 | `Alert_Flag` | Nombre entier | Nombre entier | 0 | Aucun | `1` si au moins un critère est en alerte |
| 10 | `Alert_Severity` | Texte | Général | — | Aucun | `Conforme`, `À surveiller`, `Élevée` ou `Critique` |

### Règle métier appliquée

Le seuil est évalué au grain **projet-phase**. Une phase est en alerte dès qu'au moins un de ces cas est vrai :

- coût réel supérieur d'au moins 15 % au coût prévu ;
- durée réelle supérieure d'au moins 15 % à la durée prévue ;
- nombre de livrables réels inférieur d'au moins 15 % au nombre prévu.

Un projet peut donc avoir certaines phases en alerte et d'autres conformes.

### Important concernant `Phase_Order`

Ne pas créer de colonne DAX `Phase_Order`, puis demander à Power BI de trier `Phase` par cette colonne. Comme `Phase_Order` serait calculée à partir de `Phase`, ce tri peut provoquer une dépendance circulaire. Les libellés de phase actuels sont conservés tels quels.

## 7. Fichier 02 • Mesures de base du portefeuille

### Création

Pour chaque mesure : sélectionner `_Measures`, cliquer sur **Nouvelle mesure**, copier une seule formule depuis `02_Portfolio_Measures.dax`, puis appliquer son format.

| Ordre | Nom exact | Type de données | Format | Décimales | Table principale | Utilisation |
|---:|---|---|---|---:|---|---|
| 1 | `Total Projects` | Nombre entier | Nombre entier | 0 | `_Measures` | Nombre distinct de projets |
| 2 | `Total Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Nombre distinct de clés projet-phase |
| 3 | `Planned Cost` | Nombre entier | Nombre entier avec séparateur de milliers | 0 | `_Measures` | Coût total prévu |
| 4 | `Actual Cost` | Nombre entier | Nombre entier avec séparateur de milliers | 0 | `_Measures` | Coût total réel |
| 5 | `Planned Duration` | Nombre entier | Nombre entier | 0 | `_Measures` | Durée totale prévue |
| 6 | `Actual Duration` | Nombre entier | Nombre entier | 0 | `_Measures` | Durée totale réelle |
| 7 | `Planned Deliverables` | Nombre entier | Nombre entier | 0 | `_Measures` | Nombre total de livrables prévus |
| 8 | `Actual Deliverables` | Nombre entier | Nombre entier | 0 | `_Measures` | Nombre total de livrables réels |
| 9 | `First Project Start Date` | Date | `dd/MM/yyyy` | — | `_Measures` | Première date de début du périmètre filtré |
| 10 | `Last Planned End Date` | Date | `dd/MM/yyyy` | — | `_Measures` | Dernière date de fin planifiée |
| 11 | `Last Actual End Date` | Date | `dd/MM/yyyy` | — | `_Measures` | Dernière date de fin réelle |

Le fichier source ne précise pas de devise. Les coûts sont donc volontairement affichés comme des nombres avec séparateur de milliers, sans symbole monétaire inventé.

## 8. Fichier 03 • Mesures d'écart de performance

Créer chaque objet avec **Nouvelle mesure** dans `_Measures`, dans l'ordre du fichier.

| Ordre | Nom exact | Type de données | Format | Décimales | Table principale | Interprétation |
|---:|---|---|---|---:|---|---|
| 1 | `Cost Variance` | Nombre entier | Nombre entier avec séparateur de milliers | 0 | `_Measures` | Coût réel moins coût prévu |
| 2 | `Cost Variance %` | Nombre décimal | Pourcentage | 1 | `_Measures` | Écart coût relatif |
| 3 | `Cost Performance Status` | Texte | Général | — | `_Measures` | Statut coût selon le seuil de 15 % |
| 4 | `Duration Variance` | Nombre entier | Nombre entier | 0 | `_Measures` | Durée réelle moins durée prévue |
| 5 | `Duration Variance %` | Nombre décimal | Pourcentage | 1 | `_Measures` | Écart durée relatif |
| 6 | `Duration Performance Status` | Texte | Général | — | `_Measures` | Statut durée selon le seuil de 15 % |
| 7 | `Deliverable Variance` | Nombre entier | Nombre entier | 0 | `_Measures` | Livrables réels moins livrables prévus |
| 8 | `Deliverable Variance %` | Nombre décimal | Pourcentage | 1 | `_Measures` | Écart livrables relatif |
| 9 | `Deliverable Completion Rate` | Nombre décimal | Pourcentage | 1 | `_Measures` | Livrables réels divisés par les livrables prévus |
| 10 | `Deliverable Performance Status` | Texte | Général | — | `_Measures` | Statut livrables selon le seuil de 15 % |

Ces mesures changent selon le contexte du visuel : monde, région, pays, projet ou phase. Elles décrivent une performance agrégée ; les alertes officielles restent déterminées ligne par ligne par les colonnes du fichier 01.

## 9. Fichier 04 • Mesures d'alerte

Créer chaque objet avec **Nouvelle mesure** dans `_Measures`, dans l'ordre du fichier.

| Ordre | Nom exact | Type de données | Format | Décimales | Table principale | Utilisation |
|---:|---|---|---|---:|---|---|
| 1 | `Cost Alert Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases ayant une alerte coût |
| 2 | `Duration Alert Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases ayant une alerte durée |
| 3 | `Deliverable Alert Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases ayant une alerte livrables |
| 4 | `Alert Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases ayant au moins une alerte |
| 5 | `On Track Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases sans alerte |
| 6 | `Projects in Alert` | Nombre entier | Nombre entier | 0 | `_Measures` | Projets distincts ayant au moins une phase en alerte |
| 7 | `Projects on Track` | Nombre entier | Nombre entier | 0 | `_Measures` | Projets sans phase en alerte |
| 8 | `Alert Project Rate` | Nombre décimal | Pourcentage | 1 | `_Measures` | Part des projets ayant au moins une alerte |
| 9 | `Projects with Cost Alert` | Nombre entier | Nombre entier | 0 | `_Measures` | Projets distincts avec alerte coût |
| 10 | `Projects with Duration Alert` | Nombre entier | Nombre entier | 0 | `_Measures` | Projets distincts avec alerte durée |
| 11 | `Projects with Deliverable Alert` | Nombre entier | Nombre entier | 0 | `_Measures` | Projets distincts avec alerte livrables |
| 12 | `Critical Alert Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases avec trois critères en alerte |
| 13 | `High Alert Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases avec deux critères en alerte |
| 14 | `Watch Alert Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases avec un critère en alerte |
| 15 | `Alert Color` | Texte | Général | — | `_Measures` | Code hexadécimal pour la mise en forme conditionnelle |

Couleurs renvoyées par `Alert Color` :

| Niveau prioritaire du contexte | Couleur | Code |
|---|---|---|
| Critique | Rose/rouge | `#FB7185` |
| Élevée | Ambre | `#FBBF24` |
| À surveiller | Violet | `#A78BFA` |
| Conforme | Vert | `#34D399` |

Les mesures au niveau projet utilisent un nombre distinct de `Project_ID`. Un projet ayant trois phases en alerte est donc compté une seule fois.

## 10. Fichier 05 • Mesures de contexte et de storytelling

Créer chaque objet avec **Nouvelle mesure** dans `_Measures`, dans l'ordre du fichier.

| Ordre | Nom exact | Type de données | Format | Décimales | Table principale | Utilisation |
|---:|---|---|---|---:|---|---|
| 1 | `Selected Scope` | Texte | Général | — | `_Measures` | Afficher le pays, la région ou le monde sélectionné |
| 2 | `Visible Scope Level` | Texte | Général | — | `_Measures` | Indiquer s'il s'agit d'une vue pays, régionale ou mondiale |
| 3 | `Selected Project` | Texte | Général | — | `_Measures` | Afficher le projet sélectionné ou « Tous les projets » |
| 4 | `Data Period` | Texte | Général | — | `_Measures` | Présenter la période couverte sous forme de texte |
| 5 | `Executive Narrative` | Texte | Général | — | `_Measures` | Résumer le nombre et le taux de projets en alerte |
| 6 | `Performance Narrative` | Texte | Général | — | `_Measures` | Résumer les écarts de coût, durée et livrables |
| 7 | `Selected Project Alert Summary` | Texte | Général | — | `_Measures` | Résumer les alertes du projet sélectionné |

Ces mesures sont destinées aux titres dynamiques, cartes de texte, info-bulles et encadrés de synthèse. Même `Data Period` est de type texte, car la mesure concatène deux dates dans une phrase.

## 11. Fichier 06 • Rôles RLS de démonstration

Ces expressions ne sont ni des colonnes ni des mesures.

1. Ouvrir **Modélisation > Gérer les rôles**.
2. Créer un nouveau rôle.
3. Lui donner exactement le nom indiqué ci-dessous.
4. Sélectionner `Dim_Project`.
5. Copier uniquement l'expression correspondant au rôle.
6. Enregistrer, puis tester avec **Modélisation > Voir comme**.

| Ordre | Nom du rôle | Table filtrée | Expression | Périmètre de démonstration |
|---:|---|---|---|---|
| 1 | `Director_Global` | `Dim_Project` | `TRUE()` | Tous les projets, régions et pays |
| 2 | `Director_Regional` | `Dim_Project` | `Dim_Project[Region] = "Western Europe"` | Région Western Europe et ses pays |
| 3 | `Director_Country` | `Dim_Project` | `Dim_Project[Country] = "France"` | France uniquement |

Aucun compte utilisateur n'est nécessaire pour tester ces rôles dans Power BI Desktop. Après publication, l'attribution de personnes réelles se fait dans le service Power BI.

Le RLS filtre les lignes accessibles, mais ne masque pas les onglets du rapport. Les différentes pages mondiale, régionale et pays peuvent donc être conservées pour la démonstration ; les visuels afficheront uniquement les données autorisées par le rôle.

## 12. Fichier 07 • Détail projet et performance pays

Toutes les formules de ce fichier sont des **mesures**. Elles doivent être créées dans `_Measures` avec **Nouvelle mesure**, dans l'ordre du fichier.

Prérequis : les fichiers 01 à 05 doivent déjà être en place. Ces nouvelles mesures utilisent notamment `Deadline_Variance_Days_Phase`, `Total Phases`, `Selected Project`, les écarts de performance et le taux de réalisation des livrables.

| Ordre | Nom exact | Type de données | Format | Décimales | Table principale | Utilisation |
|---:|---|---|---|---:|---|---|
| 1 | `Late Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Compter les phases dont l'écart de délai est strictement positif |
| 2 | `Early Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Compter les phases terminées en avance |
| 3 | `On Time Deadline Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Compter les phases terminées exactement à la date prévue |
| 4 | `Late Phase Rate` | Nombre décimal | Pourcentage | 1 | `_Measures` | Part des phases en retard dans le périmètre courant |
| 5 | `Average Delay Days` | Nombre décimal | Nombre décimal | 1 | `_Measures` | Retard moyen calculé uniquement sur les phases en retard |
| 6 | `Average Advance Days` | Nombre décimal | Nombre décimal | 1 | `_Measures` | Avance moyenne absolue calculée uniquement sur les phases en avance |
| 7 | `Delay Exposure Days` | Nombre décimal | Nombre décimal | 1 | `_Measures` | Somme des jours de retard positifs divisée par toutes les phases |
| 8 | `Advance Exposure Days` | Nombre décimal | Nombre décimal | 1 | `_Measures` | Somme absolue des jours d'avance divisée par toutes les phases |
| 9 | `Country Late Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases en retard du pays, indépendamment du projet sélectionné |
| 10 | `Country Early Phases` | Nombre entier | Nombre entier | 0 | `_Measures` | Phases en avance du pays, indépendamment du projet sélectionné |
| 11 | `Country Late Phase Rate` | Nombre décimal | Pourcentage | 1 | `_Measures` | Taux de phases en retard du pays |
| 12 | `Country Average Delay Days` | Nombre décimal | Nombre décimal | 1 | `_Measures` | Retard moyen des phases en retard du pays |
| 13 | `Country Average Advance Days` | Nombre décimal | Nombre décimal | 1 | `_Measures` | Avance moyenne des phases en avance du pays |
| 14 | `Country Delay Exposure Days` | Nombre décimal | Nombre décimal | 1 | `_Measures` | Exposition au retard du pays sans compensation par les avances |
| 15 | `Country Advance Exposure Days` | Nombre décimal | Nombre décimal | 1 | `_Measures` | Exposition à l'avance du pays sans compensation par les retards |
| 16 | `Countries Analyzed` | Nombre entier | Nombre entier | 0 | `_Measures` | Nombre de pays visibles dans le périmètre autorisé |
| 17 | `Most Delayed Country` | Texte | Général | — | `_Measures` | Pays ayant la plus forte exposition au retard et valeur associée |
| 18 | `Most Advanced Country` | Texte | Général | — | `_Measures` | Pays ayant la plus forte exposition à l'avance et valeur associée |
| 19 | `Selected Project Context` | Texte | Général | — | `_Measures` | Projet, pays, région et type de projet sélectionnés |
| 20 | `Selected Project Detail Narrative` | Texte | Général | — | `_Measures` | Diagnostic textuel du projet sélectionné |
| 21 | `Selected Country Delay Rank` | Nombre entier | Nombre entier | 0 | `_Measures` | Rang du pays selon son exposition au retard |
| 22 | `Selected Country Rank Label` | Texte | Général | — | `_Measures` | Libellé combinant le pays, son rang et le nombre de pays comparés |

### Règles d'interprétation

- `Deadline_Variance_Days_Phase > 0` signifie **retard**, `< 0` signifie **avance** et `= 0` signifie **à l'heure**.
- `Average Delay Days` et `Average Advance Days` calculent leur moyenne uniquement sur les phases concernées.
- Les scores d'exposition répartissent séparément les jours de retard et les jours d'avance sur toutes les phases. Une forte avance ne peut donc pas masquer un retard important.
- Les mesures préfixées par `Country` retirent seulement les filtres `Project_ID` et `Project_Label`. Elles conservent les filtres de région, de pays, de date et de type de projet, ainsi que le RLS.
- Le classement pays utilise `Country Delay Exposure Days`, puis un classement dense décroissant : le pays le plus exposé au retard obtient le rang 1.
- Les mesures textuelles servent aux cartes, titres dynamiques, diagnostics et info-bulles des pages **Détail projet** et **Performance pays**.

## 13. Réglages de format

| Famille d'objet | Réglage recommandé |
|---|---|
| Colonnes `*_Pct_*` | Nombre décimal, Pourcentage, 1 décimale, Résumer par Aucun |
| Mesures dont le nom finit par `%` | Nombre décimal, Pourcentage, 1 décimale |
| `Alert Project Rate` | Nombre décimal, Pourcentage, 1 décimale |
| `Late Phase Rate` et `Country Late Phase Rate` | Nombre décimal, Pourcentage, 1 décimale |
| Mesures `Average ... Days` et `... Exposure Days` | Nombre décimal, 1 décimale |
| `Selected Country Delay Rank` et `Countries Analyzed` | Nombre entier, 0 décimale |
| Comptages, drapeaux, coûts, durées et livrables | Nombre entier, 0 décimale |
| Coûts | Séparateur de milliers, sans devise inventée |
| Dates | Date, format `dd/MM/yyyy` |
| Statuts, récits, titres et couleurs | Texte, format Général |
| Colonnes calculées | **Résumer par : Aucun** |
| Mesures | Le réglage « Résumer par » ne s'applique pas |

## 14. Contrôles attendus sans filtre

Après la création des fichiers 01 à 04, créer temporairement des cartes ou un tableau pour vérifier les résultats suivants :

| Contrôle | Résultat attendu |
|---|---:|
| `Total Projects` | 104 |
| `Total Phases` | 520 |
| `Cost Alert Phases` | 214 |
| `Duration Alert Phases` | 159 |
| `Deliverable Alert Phases` | 98 |
| `Alert Phases` | 349 |
| `On Track Phases` | 171 |
| `Projects in Alert` | 102 |
| `Projects on Track` | 2 |
| `Critical Alert Phases` | 14 |
| `High Alert Phases` | 94 |
| `Watch Alert Phases` | 241 |

Totaux complémentaires :

| Indicateur | Prévisionnel | Réel | Écart agrégé |
|---|---:|---:|---:|
| Coût | 56 108 000 | 60 200 800 | +7,3 % |
| Durée | 52 722 | 45 641 | -13,4 % |
| Livrables | 8 735 | 7 819 | -10,5 % |

Il est normal qu'un écart agrégé soit inférieur à 15 % alors que de nombreuses phases sont en alerte : le seuil est évalué séparément pour chaque projet-phase.

Contrôles complémentaires du fichier 07 :

- `Late Phases + Early Phases + On Time Deadline Phases` doit toujours être égal à `Total Phases` dans le même contexte de filtre ;
- `Late Phase Rate` doit être égal à `Late Phases / Total Phases` ;
- les mesures `Country ...` doivent rester limitées au pays ou à la région autorisés lors d'un test RLS ;
- sélectionner un seul projet doit alimenter `Selected Project Context`, `Selected Project Detail Narrative` et le rang de son pays.

## 15. Sources officielles Microsoft

- [Présentation du langage DAX](https://learn.microsoft.com/en-us/dax/dax-overview)
- [Création et utilisation des mesures dans Power BI Desktop](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-measures)
- [Fonction `DIVIDE`](https://learn.microsoft.com/en-us/dax/divide-function-dax)
- [Fonction `CALCULATE`](https://learn.microsoft.com/en-us/dax/calculate-function-dax)
- [Fonction `DISTINCTCOUNT`](https://learn.microsoft.com/en-us/dax/distinctcount-function-dax)
- [Sécurité au niveau des lignes • RLS](https://learn.microsoft.com/en-us/fabric/security/service-admin-row-level-security)

## 16. Étape suivante après le DAX

Une fois les mesures et rôles validés :

1. construire les pages Vue d'ensemble, Analyse des alertes, Planning et Gantt, Détail projet et Performance pays.
2. créer les KPI, cartes, graphiques d'écart et tableaux de phases.
3. utiliser `Alert Color` pour la mise en forme conditionnelle.
4. utiliser les mesures des fichiers 05 et 07 pour les titres, récits dynamiques et analyses par pays.
5. tester les filtres et chaque rôle avec **Voir comme**.