// ============================================================================
// REQUÊTE : 10 - Fact_ProjectPhase
// OBJECTIF : Regrouper les indicateurs prévisionnels et réels de chaque phase
// GRAIN    : Une ligne par projet et par phase
// DÉPENDANCES : stg_ProjectPlans, stg_ActualCosts, stg_ActualDuration,
//               stg_ActualDeliverables
// SORTIE   : Table de faits centrale utilisée pour les mesures et les visuels
// CHARGEMENT : Activé
// ============================================================================

let
    // 1. Utilise le planning prévisionnel comme table de référence
    Source = stg_ProjectPlans,

    // 2. Ajoute le coût réel avec une jointure externe gauche sur la clé projet-phase
    // Cette jointure conserve toutes les phases planifiées, même sans coût réel
    MergedCosts = Table.NestedJoin(
        Source,
        {"Project_Phase_Key"},
        stg_ActualCosts,
        {"Project_Phase_Key"},
        "ActualCosts",
        JoinKind.LeftOuter
    ),
    ExpandedCosts = Table.ExpandTableColumn(MergedCosts, "ActualCosts", {"Actual_Cost"}, {"Actual_Cost"}),

    // 3. Ajoute de la même manière la durée réellement constatée
    MergedDuration = Table.NestedJoin(
        ExpandedCosts,
        {"Project_Phase_Key"},
        stg_ActualDuration,
        {"Project_Phase_Key"},
        "ActualDuration",
        JoinKind.LeftOuter
    ),
    ExpandedDuration = Table.ExpandTableColumn(
        MergedDuration,
        "ActualDuration",
        {"Actual_Duration"},
        {"Actual_Duration"}
    ),

    // 4. Ajoute le nombre de livrables réellement produits
    MergedDeliverables = Table.NestedJoin(
        ExpandedDuration,
        {"Project_Phase_Key"},
        stg_ActualDeliverables,
        {"Project_Phase_Key"},
        "ActualDeliverables",
        JoinKind.LeftOuter
    ),
    ExpandedDeliverables = Table.ExpandTableColumn(
        MergedDeliverables,
        "ActualDeliverables",
        {"Actual_Deliverables"},
        {"Actual_Deliverables"}
    ),

    // 5. Calcule la date de fin réelle à partir du début et de la durée constatée
    AddedActualEndDate = Table.AddColumn(
        ExpandedDeliverables,
        "Actual_End_Date",
        each Date.AddDays([Start_Date], [Actual_Duration]),
        type date
    ),

    // 6. Organise les colonnes pour rapprocher chaque valeur prévue de sa valeur réelle
    ReorderedColumns = Table.ReorderColumns(
        AddedActualEndDate,
        {
            "Project_Phase_Key",
            "Project_ID",
            "Phase",
            "Start_Date",
            "Planned_End_Date",
            "Actual_End_Date",
            "Planned_Duration",
            "Actual_Duration",
            "Planned_Cost",
            "Actual_Cost",
            "Planned_Deliverables",
            "Actual_Deliverables"
        }
    )
in
    ReorderedColumns