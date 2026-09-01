let
    Source = stg_ProjectPlans,
    MergedCosts = Table.NestedJoin(
        Source,
        {"Project_Phase_Key"},
        stg_ActualCosts,
        {"Project_Phase_Key"},
        "ActualCosts",
        JoinKind.LeftOuter
    ),
    ExpandedCosts = Table.ExpandTableColumn(MergedCosts, "ActualCosts", {"Actual_Cost"}, {"Actual_Cost"}),
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
    AddedActualEndDate = Table.AddColumn(
        ExpandedDeliverables,
        "Actual_End_Date",
        each Date.AddDays([Start_Date], [Actual_Duration]),
        type date
    ),
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