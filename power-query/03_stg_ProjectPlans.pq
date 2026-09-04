// ============================================================================
// REQUÊTE : 03 - stg_ProjectPlans
// OBJECTIF : Nettoyer le planning prévisionnel de chaque phase de projet
// GRAIN    : Une ligne par projet et par phase
// DÉPENDANCES : src_SanitoralWorkbook, fxNormalizeProjectId
// SORTIE   : Planning standardisé avec clé unique et date de fin prévisionnelle
// CHARGEMENT : Désactivé car cette table prépare la table de faits finale
// ============================================================================

let
    // 1. Sélectionne la feuille contenant le planning prévisionnel
    RawSheet = src_SanitoralWorkbook{[Item = "Projects_plans", Kind = "Sheet"]}[Data],

    // 2. Supprime les deux lignes d'introduction placées avant les en-têtes.
    SkippedIntroRows = Table.Skip(RawSheet, 2),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),

    // 3. Harmonise les noms de colonnes utilisés dans le modèle.
    RenamedColumns = Table.RenameColumns(
        PromotedHeaders,
        {
            {"Project ID", "Project_ID"},
            {"Start Date", "Start_Date"},
            {"Planned_Delivrable", "Planned_Deliverables"}
        }
    ),

    // 4. Conserve uniquement les champs utiles à l'analyse des phases
    SelectedColumns = Table.SelectColumns(
        RenamedColumns,
        {"Project_ID", "Phase", "Start_Date", "Planned_Duration", "Planned_Cost", "Planned_Deliverables"}
    ),

    // 5. Écarte les lignes sans projet ou sans phase.
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Project_ID] <> null and [Phase] <> null
    ),

    // 6. Nettoie les caractères invisibles et les espaces dans le nom des phases
    CleanedPhase = Table.TransformColumns(
        RemovedBlankRows,
        {{"Phase", each Text.Clean(Text.Trim(Text.From(_))), type text}}
    ),

    // 7. Applique le même format d'identifiant à toutes les sources
    NormalizedProjectId = Table.TransformColumns(
        CleanedPhase,
        {{"Project_ID", each fxNormalizeProjectId(_), type text}}
    ),

    // 8. Définit explicitement les types nécessaires aux calculs et aux relations
    ChangedTypes = Table.TransformColumnTypes(
        NormalizedProjectId,
        {
            {"Start_Date", type date},
            {"Planned_Duration", Int64.Type},
            {"Planned_Cost", Int64.Type},
            {"Planned_Deliverables", Int64.Type}
        },
        "en-US"
    ),

    // 9. Concatène le projet et la phase afin d'obtenir une clé métier unique
    AddedProjectPhaseKey = Table.AddColumn(
        ChangedTypes,
        "Project_Phase_Key",
        each [Project_ID] & "|" & [Phase],
        type text
    ),

    // 10. Calcule la date de fin prévue à partir du début et de la durée planifiée
    AddedPlannedEndDate = Table.AddColumn(
        AddedProjectPhaseKey,
        "Planned_End_Date",
        each Date.AddDays([Start_Date], [Planned_Duration]),
        type date
    ),

    // 11. Garantit une seule ligne par clé projet-phase
    RemovedDuplicateKeys = Table.Distinct(AddedPlannedEndDate, {"Project_Phase_Key"})
in
    RemovedDuplicateKeys
