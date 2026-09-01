let
    RawSheet = src_SanitoralWorkbook{[Item = "Actual_Delivrable", Kind = "Sheet"]}[Data],
    SkippedIntroRows = Table.Skip(RawSheet, 3),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"ID", "Project_ID"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Project_ID", "Phase", "Actual_Deliverables"}),
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
    ChangedTypes = Table.TransformColumnTypes(NormalizedProjectId, {{"Actual_Deliverables", Int64.Type}}, "en-US"),
    AddedProjectPhaseKey = Table.AddColumn(
        ChangedTypes,
        "Project_Phase_Key",
        each [Project_ID] & "|" & [Phase],
        type text
    ),
    RemovedDuplicateKeys = Table.Distinct(AddedProjectPhaseKey, {"Project_Phase_Key"})
in
    RemovedDuplicateKeys