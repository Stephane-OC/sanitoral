// ============================================================================
// REQUÊTE : 05 - stg_ActualDuration
// OBJECTIF : Préparer la durée réellement constatée pour chaque phase
// GRAIN    : Une ligne par projet et par phase
// DÉPENDANCES : src_SanitoralWorkbook, fxNormalizeProjectId
// SORTIE   : Durées réelles standardisées avec une clé projet-phase unique
// CHARGEMENT : Désactivé car cette table alimente Fact_ProjectPhase
// ============================================================================

let
    // 1. Sélectionne la feuille contenant les durées réelles
    RawSheet = src_SanitoralWorkbook{[Item = "Actual_Duration", Kind = "Sheet"]}[Data],

    // 2. Supprime les lignes d'introduction et utilise la ligne suivante comme en-têtes
    SkippedIntroRows = Table.Skip(RawSheet, 5),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),

    // 3. Harmonise le nom de l'identifiant et conserve les colonnes utiles
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"Project", "Project_ID"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Project_ID", "Phase", "Actual_Duration"}),

    // 4. Supprime les lignes inexploitables puis nettoie le libellé de phase
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Project_ID] <> null and [Phase] <> null
    ),
    CleanedPhase = Table.TransformColumns(
        RemovedBlankRows,
        {{"Phase", each Text.Clean(Text.Trim(Text.From(_))), type text}}
    ),

    // 5. Normalise les identifiants et convertit la durée réelle en nombre entier
    NormalizedProjectId = Table.TransformColumns(
        CleanedPhase,
        {{"Project_ID", each fxNormalizeProjectId(_), type text}}
    ),
    ChangedTypes = Table.TransformColumnTypes(NormalizedProjectId, {{"Actual_Duration", Int64.Type}}, "en-US"),

    // 6. Crée la clé de rapprochement utilisée par la table de faits
    AddedProjectPhaseKey = Table.AddColumn(
        ChangedTypes,
        "Project_Phase_Key",
        each [Project_ID] & "|" & [Phase],
        type text
    ),

    // 7. Garantit une seule durée réelle par projet et par phase
    RemovedDuplicateKeys = Table.Distinct(AddedProjectPhaseKey, {"Project_Phase_Key"})
in
    RemovedDuplicateKeys