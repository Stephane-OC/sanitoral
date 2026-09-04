// ============================================================================
// REQUÊTE : 07 - stg_ProjectType
// OBJECTIF : Associer chaque projet à son type, notamment IT ou Marketing
// GRAIN    : Une ligne par projet
// DÉPENDANCES : src_SanitoralWorkbook, fxNormalizeProjectId
// SORTIE   : Référentiel standardisé des types de projet
// CHARGEMENT : Désactivé car cette table alimente Dim_Project
// ============================================================================

let
    // 1. Sélectionne la feuille contenant les types de projet
    RawSheet = src_SanitoralWorkbook{[Item = "Project type", Kind = "Sheet"]}[Data],

    // 2. Supprime les lignes d'introduction et utilise la ligne suivante comme en-têtes
    SkippedIntroRows = Table.Skip(RawSheet, 3),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),

    // 3. Harmonise les noms de colonnes et conserve uniquement les champs utiles
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"Project ID", "Project_ID"}, {"Project Type", "Project_Type"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Project_ID", "Project_Type"}),

    // 4. Écarte les lignes incomplètes et nettoie le libellé du type de projet
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Project_ID] <> null and [Project_Type] <> null
    ),
    CleanedProjectType = Table.TransformColumns(
        RemovedBlankRows,
        {{"Project_Type", each Text.Clean(Text.Trim(Text.From(_))), type text}}
    ),

    // 5. Normalise l'identifiant afin de permettre les relations entre les tables
    NormalizedProjectId = Table.TransformColumns(
        CleanedProjectType,
        {{"Project_ID", each fxNormalizeProjectId(_), type text}}
    ),

    // 6. Garantit une seule ligne descriptive par projet
    RemovedDuplicateIds = Table.Distinct(NormalizedProjectId, {"Project_ID"})
in
    RemovedDuplicateIds