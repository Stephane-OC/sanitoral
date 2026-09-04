// ============================================================================
// REQUÊTE : 08 - stg_ProjectLocations
// OBJECTIF : Associer chaque projet au pays dans lequel il est réalisé
// GRAIN    : Une ligne par projet
// DÉPENDANCES : src_SanitoralWorkbook, fxNormalizeProjectId
// SORTIE   : Référentiel standardisé des localisations de projet
// CHARGEMENT : Désactivé car cette table alimente Dim_Project
// ============================================================================

let
    // 1. Sélectionne la feuille contenant les localisations des projets
    RawSheet = src_SanitoralWorkbook{[Item = "Projects_Locations", Kind = "Sheet"]}[Data],

    // 2. Supprime la ligne d'introduction et utilise la ligne suivante comme en-têtes
    SkippedIntroRows = Table.Skip(RawSheet, 1),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),

    // 3. Harmonise l'identifiant et conserve les colonnes nécessaires
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"Project ID", "Project_ID"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Project_ID", "Country"}),

    // 4. Écarte les lignes incomplètes et nettoie le nom du pays
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Project_ID] <> null and [Country] <> null
    ),
    CleanedCountry = Table.TransformColumns(
        RemovedBlankRows,
        {{"Country", each Text.Clean(Text.Trim(Text.From(_))), type text}}
    ),

    // 5. Normalise l'identifiant afin de permettre les relations entre les tables
    NormalizedProjectId = Table.TransformColumns(
        CleanedCountry,
        {{"Project_ID", each fxNormalizeProjectId(_), type text}}
    ),

    // 6. Garantit une seule localisation par projet
    RemovedDuplicateIds = Table.Distinct(NormalizedProjectId, {"Project_ID"})
in
    RemovedDuplicateIds