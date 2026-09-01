let
    RawSheet = src_SanitoralWorkbook{[Item = "Projects_plans", Kind = "Sheet"]}[Data],
    SkippedIntroRows = Table.Skip(RawSheet, 2),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),
    RenamedColumns = Table.RenameColumns(
        PromotedHeaders,
        {
            {"Project ID", "Project_ID"},
            {"Start Date", "Start_Date"},
            {"Planned_Delivrable", "Planned_Deliverables"}
        }
    ),
    SelectedColumns = Table.SelectColumns(
        RenamedColumns,
        {"Project_ID", "Phase", "Start_Date", "Planned_Duration", "Planned_Cost", "Planned_Deliverables"}
    ),
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Project_ID] <> null and [Phase] <> null
    ),
    CleanedPhase = Table.TransformColumns(
        RemovedBlankRows,
        {{"Phase", each Text.Clean(Text.Trim(Text.From(_))), type text}}
    ),
    NormalizedProjectId = Table.TransformColumns(
        CleanedPhase,
        {{"Project_ID", each fxNormalizeProjectId(_), type text}}
    ),
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
    AddedProjectPhaseKey = Table.AddColumn(
        ChangedTypes,
        "Project_Phase_Key",
        each [Project_ID] & "|" & [Phase],
        type text
    ),
    AddedPlannedEndDate = Table.AddColumn(
        AddedProjectPhaseKey,
        "Planned_End_Date",
        each Date.AddDays([Start_Date], [Planned_Duration]),
        type date
    ),
    RemovedDuplicateKeys = Table.Distinct(AddedPlannedEndDate, {"Project_Phase_Key"})
in
    RemovedDuplicateKeys