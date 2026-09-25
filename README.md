# Sanitoral Project Performance Dashboard

![Sanitoral banner](assets/images/sanitoral_banner.png)

![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811)
![Power Query](https://img.shields.io/badge/Power%20Query-M-2E7D32)
![DAX](https://img.shields.io/badge/DAX-114%20measures-7B61FF)
![Project format](https://img.shields.io/badge/Project-PBIP-31C4D6)

An interactive Power BI report for monitoring Sanitoral's international project portfolio. It compares planned and actual costs, durations, and deliverables, identifies alerts, and connects portfolio-level indicators to the phases that explain each project's results.

The report serves three management levels: global, regional, and country directors. Its business interface is in French; technical table and measure names are in English.

**Open the project:** [SanitoralDashboard.pbip](power-bi/project/SanitoralDashboard.pbip)  
**Technical guides:** [Power Query](power-query/README.md) · [DAX](dax/README.md)

## Project scope

The functional scope includes five analytical pages, three documentation pages, project drillthrough, mobile layouts for the analytical pages, and three demonstration security roles. Remaining refinements concern visual presentation and layout.

The dashboard supports four decisions:

- Identify projects whose costs, durations, or deliverable quantities reach the agreed alert thresholds.
- Compare results across regions, countries, project types, and entity types.
- Investigate individual projects and the phases responsible for their variances.
- Review consolidated portfolio results after a repeatable Excel refresh.

The proposed strategic direction is to prioritize projects in cost alert by their absolute cost overrun, examine the contributing phases and deliverables, assign corrective actions, and review results weekly. The report identifies where to investigate; the underlying business causes require discussion with project owners.

## Report pages

| Page | Purpose |
|---|---|
| **Vue d'ensemble** | Portfolio KPIs, geographic duration alerts, priority projects, and a project comparison table. |
| **Analyse des alertes** | Phase alerts by criterion and severity, regional and country drilldown, and trends by phase start month. |
| **Planning et Gantt** | Planned project timelines and comparison of planned versus calculated finish dates. |
| **Détail projet** | One project's cumulative indicators, phase timelines, variance diagnostics, and country delay ranking. |
| **Synthèse portefeuille** | Consolidated costs and performance variances, regional comparisons, the most expensive projects, and financial details. |
| **Mise à jour** | Product Strategy Canvas as an embedded image, user needs, and the proposed strategic direction. |
| **Préparation des données** | Source configuration, Power Query preparation, refresh procedure, and data quality checks. |
| **Modèle des données** | Table grain, relationships, measure folders, and demonstration security roles. |

The documentation pages are accessible through the **Mise à jour** navigation area. An additional **Capture du modèle Power BI** page contains the model screenshot; it is hidden from normal reading-mode tabs and opened through the documentation navigation.

The documentation panels are static explanatory content. Analytical visuals calculate their results from the semantic model and respond to the configured filters.

### Using the report

Start with the overview or portfolio summary, select a region or country, and inspect the projects in that scope. Select a single project and use **Voir le détail du projet** to open its phase diagnostics. The project detail page also provides a project selector.

The portfolio summary does not require a project selection. With no restrictive filters, it displays all projects accessible to the reader. Country and project selections narrow the same indicators to the selected scope.

Each of the five analytical pages has a mobile layout. The three documentation pages use the desktop canvas. Wide tables retain scrolling, and the Gantt charts support inspection of longer timelines.

## Data model

The model contains one fact table, two dimensions, and a disconnected measures table.

| Table | Grain and purpose |
|---|---|
| `Fact_ProjectPhase` | One row per project and phase, identified by `Project_Phase_Key`; planned and actual values, dates, and 13 calculated diagnostic columns. |
| `Dim_Project` | One row per `Project_ID`; geography, project and entity types, and 14 calculated project-level columns. |
| `Dim_Date` | One row per date; the dedicated calendar for phase start-date filtering. |
| `_Measures` | 114 DAX measures and a hidden `_Placeholder` column; no model relationships. |

Two active one-to-many relationships filter the fact table in a single direction:

- `Dim_Project[Project_ID]` → `Fact_ProjectPhase[Project_ID]`.
- `Dim_Date[Date]` → `Fact_ProjectPhase[Start_Date]`.

Automatic date/time is disabled. Geographic and organizational attributes are stored in the project dimension.

### Power Query preparation

The source is an Excel workbook containing seven business worksheets. A shared workbook query feeds staging queries that clean text, normalize project identifiers, set data types, remove unusable keys, and deduplicate records. The project-phase key links planned and actual values.

Left joins retain the planned phases when actual values are unavailable. `Fact_ProjectPhase`, `Dim_Project`, and `Dim_Date` are loaded into the model; staging queries support their preparation. Missing actuals and contradictory duplicates require source checks: removing a duplicate does not establish which record is correct.

See the [Power Query README](power-query/README.md) for query names, dependencies, and implementation details.

### DAX organization

All measures belong to `_Measures`. Their display folders organize the field list without creating extra tables or relationships.

| Display location | Measure count |
|---|---:|
| Root of `_Measures` | 58 |
| `Présentation` | 28 |
| `Pilotage` | 28 |
| **Total** | **114** |

The numbered `.dax` files document measures, calculated columns, the measures table, and RLS expressions. They are reference scripts, not files automatically imported by Power BI. The active model definitions are stored in `power-bi/project/SanitoralDashboard.SemanticModel/definition/`.

The [DAX README](dax/README.md) contains the complete catalog, formats, display folders, thresholds, and creation order. It includes `11_Portfolio_Summary_Measures.dax`, which defines the duration and deliverable color helpers used by the portfolio summary.

## Indicator interpretation

| Criterion | Relative variance | Alert threshold |
|---|---|---|
| Cost | `(actual cost − planned cost) / planned cost` | ≥ +15% |
| Duration | `(actual duration − planned duration) / planned duration` | ≥ +15% |
| Deliverables | `(actual quantity − planned quantity) / planned quantity` | ≤ −15% |

Project and portfolio percentages are calculated from summed values, not by averaging phase or project percentages. Favorable and unfavorable results can offset each other in a consolidated figure; phase diagnostics remain necessary.

`Projects in Alert` counts cumulative **duration** alerts. `Overall Alert Projects` counts projects with at least one cumulative alert across all three criteria. These indicators answer different questions.

Phase severity reflects the number of triggered criteria: **Conforme** = 0, **À surveiller** = 1, **Élevée** = 2, and **Critique** = 3. A phase can appear in several alert-type counts. A deliverable alert represents a shortfall in quantity; it does not by itself prove late delivery.

`Hors alerte` means the threshold has not been reached, even if a small overrun exists. Non-evaluable cases are handled separately by the relevant formulas.

### Dates and display settings

The project Gantt extends from the earliest phase start to the latest planned phase finish. This calendar span differs from the sum of phase durations when phases overlap.

**Fin calculée** is derived from phase start dates and actual durations. It is not a recorded project closure date. A phase can finish later than planned without reaching the +15% duration alert threshold.

The date slicers on **Vue d'ensemble** and **Planning et Gantt** filter project start dates. **Analyse des alertes** uses phase start dates; its monthly trend is not a history of when alerts were triggered.

Portfolio cost cards display full euro amounts. Their display units are set to **None / Aucune** so that different values are not rounded to the same whole-million label. Percentage calculations continue to use the underlying numeric measures.

## Getting started

1. Download or clone the repository, keeping its folder structure.
2. Open [SanitoralDashboard.pbip](power-bi/project/SanitoralDashboard.pbip) with a compatible Power BI Desktop version.
3. Keep the `.Report` and `.SemanticModel` directories beside the `.pbip` file.
4. Open **Transformer les données → Gérer les paramètres** and set `pDataFilePath` to the absolute local path of [sanitoral_project_data.xlsx](data/raw/sanitoral_project_data.xlsx).
5. Select **Fermer et appliquer**, then **Actualiser**, and wait for completion.
6. Clear analytical filters and compare the main indicators with the reference checks below.

The source path is local to each machine. The report uses Azure Maps and an installed Gantt custom visual; their rendering also depends on the relevant Power BI settings and service availability.

### Weekly refresh

Use the new Excel workbook with the same worksheet names, headers, and expected column structure. Replace the source at the configured location or update `pDataFilePath`, then refresh. Power Query replays the preparation steps; manual cleaning of the source workbook is not part of the process.

Check query errors, project-phase key uniqueness, project geography, missing actual values, and cost totals. Compare at least one known project before sharing the refreshed report. A changed workbook structure may require adapting the affected query steps.

The repository also includes a [U.S. test workbook](data/raw/sanitoral_project_data_US_test.xlsx) for refresh testing. Restore the original source path after the test when returning to the reference analysis. Weekly refresh is an operating procedure; it does not imply that a Power BI Service refresh schedule has been configured.

## Access roles

Three static demonstration RLS roles filter `Dim_Project`:

| Role | Configured scope |
|---|---|
| `Director_Global` | All projects: `TRUE ()`. |
| `Director_Regional` | `Region = "Western Europe"`. |
| `Director_Country` | `Country = "France"`. |

Test each role separately through **Modeling → View as / Modélisation → Afficher en tant que**. The scopes are explicit examples, not a dynamic mapping from the signed-in user's identity. User assignment to roles after publication is a separate step.

Slicers support exploration; RLS restricts accessible data across report pages. Measures that remove analytical filters do not remove RLS restrictions, so country rankings remain limited to the reader's authorized data.

## Repository structure

| Location | Contents |
|---|---|
| `power-bi/project/` | PBIP report and semantic model used for development and Git versioning. |
| `power-bi/releases/` | Location for exported PBIX delivery versions. |
| `power-bi/templates/` | Location for optional PBIT templates. |
| `power-bi/themes/` | Report theme resources. |
| `power-query/` | Numbered M scripts and the Power Query README. |
| `dax/` | Numbered DAX scripts and the DAX README. |
| `data/raw/` | Source workbook, refresh-test workbook, and data dictionary. |
| `assets/images/` | Sanitoral branding assets. |
| `docs/product-strategy-canvas/` | Product Strategy Canvas document. |

## Reference checks

With the original workbook and no restrictive filters or RLS role applied, the supplied reference report shows:

| Indicator | Reference value |
|---|---:|
| Projects | 104 |
| Projects in cumulative duration alert | 8 |
| Duration-alert project rate | Approximately 7.7% |
| Projects with any cumulative alert | 41 |
| Phases with at least one alert | 349 |
| Phases in duration alert | 159 |

For the Egyptian project **PRJ-004**, planned cost is **€750,000** and actual cost is **€953,100**: a **€203,100** overrun, approximately **+27.1%**. The portfolio cards and project table should agree when filtered to this project.

These values are reference checks, not fixed targets or hard-coded measures. They can change when the source or filter context changes.

Before distributing a new version, verify refresh, country and project filtering, drillthrough, cost-card precision, the Gantt legend, mobile navigation, and each demonstration role in Power BI. File-level checks do not replace application testing.

## Delivery formats

- **PBIX:** the complete report file required for the assessment, including the imported data. Save the final report in this format and place it in the submission ZIP using the required naming convention.
- **PBIP:** the editable project structure maintained in this repository. Keep its report and semantic-model folders together.
- **PBIT:** an optional reusable template containing report and model definitions, without the imported data. It requires a data connection when opened and does not replace the requested PBIX deliverable.

`releases/` and `templates/` are repository folders, not additional Power BI file formats. See Microsoft's documentation on [Power BI projects](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview) and [report templates](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-templates).

## Documentation

- [DAX README](dax/README.md): measure and calculated-column catalog, dependencies, display folders, formats, and interpretation.
- [Power Query README](power-query/README.md): source configuration, staging queries, transformations, and model preparation.
- [Product Strategy Canvas](docs/product-strategy-canvas/Product_Strategy_Canvas_Sanitoral.docx): business needs and management perspectives.
- [Data dictionary](data/raw/sanitoral_data_dictionary.xlsx): source field definitions.