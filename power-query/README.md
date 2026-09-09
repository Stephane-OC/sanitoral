# Sanitoral Project Performance Dashboard

![Sanitoral banner](../assets/images/sanitoral_banner.png)

# Préparation des données avec Power Query

Ce dossier contient les scripts de préparation des données du projet **Sanitoral**. Ils sont écrits en **langage M**, le langage de formules utilisé par Power Query dans Power BI.

Les commentaires suivent une logique proche de celle utilisée dans les projets SQL : objectif, grain, dépendances, résultat produit et explication des transformations importantes.

## Organisation des requêtes

| Ordre | Requête | Rôle | Chargement dans le modèle |
|---:|---|---|---|
| 00 | `pDataFilePath` | Centralise le chemin du classeur source | Non — paramètre texte |
| 01 | `src_SanitoralWorkbook` | Ouvre le classeur Excel une seule fois | Désactivé |
| 02 | `fxNormalizeProjectId` | Uniformise les identifiants de projet | Non — fonction |
| 03 | `stg_ProjectPlans` | Prépare le planning prévisionnel | Désactivé |
| 04 | `stg_ActualCosts` | Prépare les coûts réels | Désactivé |
| 05 | `stg_ActualDuration` | Prépare les durées réelles | Désactivé |
| 06 | `stg_ActualDeliverables` | Prépare les livrables réels | Désactivé |
| 07 | `stg_ProjectType` | Prépare les types de projet | Désactivé |
| 08 | `stg_ProjectLocations` | Prépare les pays des projets | Désactivé |
| 09 | `stg_CountryProfiles` | Prépare les régions et types d'entité | Désactivé |
| 10 | `Fact_ProjectPhase` | Centralise les indicateurs prévus et réels | Activé |
| 11 | `Dim_Project` | Contient les attributs descriptifs des projets | Activé |
| 12 | `Dim_Date` | Fournit un calendrier continu | Activé |

Power Query évalue automatiquement les dépendances entre les requêtes. La numérotation sert surtout à documenter clairement le cheminement de la préparation des données.

## Logique générale

1. Le chemin du fichier est défini une seule fois dans `pDataFilePath`.
2. Le classeur est ouvert par `src_SanitoralWorkbook`.
3. Les requêtes `stg_` nettoient et standardisent chaque feuille source.
4. `Project_ID` est converti en texte sur trois caractères par `fxNormalizeProjectId`.
5. La clé `Project_Phase_Key` associe un projet à une phase de manière unique.
6. Les données réelles sont jointes au planning dans `Fact_ProjectPhase`.
7. `Dim_Project` et `Dim_Date` fournissent les axes de filtrage du modèle en étoile.

## Contrôles à présenter

- Les requêtes s'actualisent sans erreur.
- Les lignes vides et les doublons de clé sont supprimés.
- `Project_Phase_Key` est unique dans les requêtes intermédiaires concernées.
- `Project_ID` est unique dans `Dim_Project`.
- `Date` est unique et continue dans `Dim_Date`.
- Seules `Fact_ProjectPhase`, `Dim_Project` et `Dim_Date` sont chargées dans le modèle.
- Les relations sont de type un-à-plusieurs depuis les dimensions vers la table de faits.
- `Dim_Date` est marquée comme table de dates et la date/heure automatique est désactivée.

## Sources officielles Microsoft

### Langage M et commentaires

- [Référence du langage de formules Power Query M](https://learn.microsoft.com/en-us/powerquery-m/)
- [Spécification du langage M • structure lexicale et commentaires](https://learn.microsoft.com/en-us/powerquery-m/m-spec-lexical-structure)

La spécification indique que M accepte les commentaires sur une ligne avec `//` et les commentaires délimités avec `/* ... */`.

### Connexion au classeur Excel

- [`File.Contents`](https://learn.microsoft.com/en-us/powerquery-m/file-contents)
- [`Excel.Workbook`](https://learn.microsoft.com/en-us/powerquery-m/excel-workbook)

### Nettoyage et transformation des tables

- [`Table.Skip`](https://learn.microsoft.com/en-us/powerquery-m/table-skip)
- [`Table.PromoteHeaders`](https://learn.microsoft.com/en-us/powerquery-m/table-promoteheaders)
- [`Table.SelectRows`](https://learn.microsoft.com/en-us/powerquery-m/table-selectrows)
- [`Table.TransformColumns`](https://learn.microsoft.com/en-us/powerquery-m/table-transformcolumns)
- [`Table.TransformColumnTypes`](https://learn.microsoft.com/en-us/powerquery-m/table-transformcolumntypes)
- [`Table.AddColumn`](https://learn.microsoft.com/en-us/powerquery-m/table-addcolumn)
- [`Table.Distinct`](https://learn.microsoft.com/en-us/powerquery-m/table-distinct)

### Jointures et développement des colonnes

- [`Table.NestedJoin`](https://learn.microsoft.com/en-us/powerquery-m/table-nestedjoin)
- [`Table.ExpandTableColumn`](https://learn.microsoft.com/en-us/powerquery-m/table-expandtablecolumn)
- [`JoinKind.Type`](https://learn.microsoft.com/en-us/powerquery-m/joinkind-type)

### Calendrier et calculs de dates

- [`List.Dates`](https://learn.microsoft.com/en-us/powerquery-m/list-dates)
- [`Date.AddDays`](https://learn.microsoft.com/en-us/powerquery-m/date-adddays)
- [`Date.Year`](https://learn.microsoft.com/en-us/powerquery-m/date-year)
- [`Date.Month`](https://learn.microsoft.com/en-us/powerquery-m/date-month)
- [`Date.MonthName`](https://learn.microsoft.com/en-us/powerquery-m/date-monthname)


## Mise à jour du chemin source

Lors de l'ouverture du projet, uniquement modifier la valeur du paramètre `pDataFilePath` pour indiquer l'emplacement local de `sanitoral_project_data.xlsx`. Les autres requêtes utilisent automatiquement ce paramètre.