let
    RawSheet = src_SanitoralWorkbook{[Item = "Project type", Kind = "Sheet"]}[Data],
    SkippedIntroRows = Table.Skip(RawSheet, 3),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"Project ID", "Project_ID"}, {"Project Type", "Project_Type"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Project_ID", "Project_Type"}),
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Project_ID] <> null and [Project_Type] <> null
    ),
    CleanedProjectType = Table.TransformColumns(
        RemovedBlankRows,
        {{"Project_Type", each Text.Clean(Text.Trim(Text.From(_))), type text}}
    ),
    NormalizedProjectId = Table.TransformColumns(
        CleanedProjectType,
        {{"Project_ID", each fxNormalizeProjectId(_), type text}}
    ),
    RemovedDuplicateIds = Table.Distinct(NormalizedProjectId, {"Project_ID"})
in
    RemovedDuplicateIds