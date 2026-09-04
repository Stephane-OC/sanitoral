// ============================================================================
// REQUÊTE : 11 - Dim_Project
// OBJECTIF : Rassembler les attributs descriptifs nécessaires pour filtrer les projets
// GRAIN    : Une ligne par projet
// DÉPENDANCES : stg_ProjectType, stg_ProjectLocations, stg_CountryProfiles
// SORTIE   : Dimension projet contenant type, pays, région et type d'entité
// CHARGEMENT : Activé
// ============================================================================

let
    // 1. Utilise la liste des types de projet comme base de la dimension
    Source = stg_ProjectType,

    // 2. Ajoute le pays de chaque projet avec une jointure externe gauche
    MergedLocations = Table.NestedJoin(
        Source,
        {"Project_ID"},
        stg_ProjectLocations,
        {"Project_ID"},
        "Location",
        JoinKind.LeftOuter
    ),
    ExpandedLocation = Table.ExpandTableColumn(MergedLocations, "Location", {"Country"}, {"Country"}),

    // 3. Ajoute la région et le type d'entité correspondant au pays
    MergedCountryProfiles = Table.NestedJoin(
        ExpandedLocation,
        {"Country"},
        stg_CountryProfiles,
        {"Country"},
        "CountryProfile",
        JoinKind.LeftOuter
    ),
    ExpandedCountryProfile = Table.ExpandTableColumn(
        MergedCountryProfiles,
        "CountryProfile",
        {"Region", "Entity_Type"},
        {"Region", "Entity_Type"}
    ),

    // 4. Crée un libellé de projet lisible pour les futurs visuels
    AddedProjectLabel = Table.AddColumn(
        ExpandedCountryProfile,
        "Project_Label",
        each "PRJ-" & [Project_ID],
        type text
    ),

    // 5. Garantit l'unicité de Project_ID du côté « 1 » de la relation
    RemovedDuplicateIds = Table.Distinct(AddedProjectLabel, {"Project_ID"})
in
    RemovedDuplicateIds