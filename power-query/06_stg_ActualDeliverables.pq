// ============================================================================
// REQUÊTE : 06 - stg_ActualDeliverables
// OBJECTIF : Préparer le nombre de livrables réellement produits par phase
// GRAIN    : Une ligne par projet et par phase
// DÉPENDANCES : src_SanitoralWorkbook, fxNormalizeProjectId
// SORTIE   : Livrables réels standardisés avec une clé projet-phase unique
// CHARGEMENT : Désactivé car cette table alimente Fact_ProjectPhase
// ============================================================================

let
    // 1. Sélectionne la feuille contenant les livrables réels
    RawSheet = src_SanitoralWorkbook{[Item = "Actual_Delivrable", Kind = "Sheet"]}[Data],

    // 2. Supprime les lignes d'introduction et utilise la ligne suivante comme en-têtes
    SkippedIntroRows = Table.Skip(RawSheet, 3),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),

    // 3. Harmonise le nom de l'identifiant et conserve les colonnes utiles
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"ID", "Project_ID"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Project_ID", "Phase", "Actual_Deliverables"}),

    // 4. Supprime les lignes inexploitables puis nettoie le libellé de phase
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Project_ID] <> null and [Phase] <> null
    ),
    CleanedPhase = Table.TransformColumns(
        RemovedBlankRows,
        {{"Phase", each Text.Clean(Text.Trim(Text.From(_))), type text}}
    ),

    // 5. Normalise les identifiants et convertit le nombre de livrables en entier
    NormalizedProjectId = Table.TransformColumns(
        CleanedPhase,
        {{"Project_ID", each fxNormalizeProjectId(_), type text}}
    ),
    ChangedTypes = Table.TransformColumnTypes(NormalizedProjectId, {{"Actual_Deliverables", Int64.Type}}, "en-US"),

    // 6. Crée la clé de rapprochement utilisée par la table de faits.
    AddedProjectPhaseKey = Table.AddColumn(
        ChangedTypes,
        "Project_Phase_Key",
        each [Project_ID] & "|" & [Phase],
        type text
    ),

    // 7. Garantit une seule valeur de livrables réels par projet et par phase
    RemovedDuplicateKeys = Table.Distinct(AddedProjectPhaseKey, {"Project_Phase_Key"})
in
    RemovedDuplicateKeys