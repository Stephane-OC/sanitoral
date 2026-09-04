// ============================================================================
// REQUÊTE : 09 - stg_CountryProfiles
// OBJECTIF : Préparer les informations géographiques et organisationnelles
// GRAIN    : Une ligne par pays
// DÉPENDANCE : src_SanitoralWorkbook
// SORTIE   : Référentiel pays, région et type d'entité
// CHARGEMENT : Désactivé car cette table alimente Dim_Project
// ============================================================================

let
    // 1. Sélectionne la feuille contenant le profil des pays
    RawSheet = src_SanitoralWorkbook{[Item = "Country_Profiles", Kind = "Sheet"]}[Data],

    // 2. Supprime la ligne d'introduction et utilise la ligne suivante comme en-têtes
    SkippedIntroRows = Table.Skip(RawSheet, 1),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),

    // 3. Harmonise le nom du type d'entité et conserve les champs utiles
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"Type", "Entity_Type"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Country", "Region", "Entity_Type"}),

    // 4. Écarte les lignes dont une information descriptive est absente
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Country] <> null and [Region] <> null and [Entity_Type] <> null
    ),

    // 5. Nettoie de manière homogène toutes les colonnes textuelles
    CleanedText = Table.TransformColumns(
        RemovedBlankRows,
        {
            {"Country", each Text.Clean(Text.Trim(Text.From(_))), type text},
            {"Region", each Text.Clean(Text.Trim(Text.From(_))), type text},
            {"Entity_Type", each Text.Clean(Text.Trim(Text.From(_))), type text}
        }
    ),

    // 6. Garantit une seule ligne descriptive par pays
    RemovedDuplicateCountries = Table.Distinct(CleanedText, {"Country"})
in
    RemovedDuplicateCountries