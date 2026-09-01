let
    RawSheet = src_SanitoralWorkbook{[Item = "Projects_Locations", Kind = "Sheet"]}[Data],
    SkippedIntroRows = Table.Skip(RawSheet, 1),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"Project ID", "Project_ID"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Project_ID", "Country"}),
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Project_ID] <> null and [Country] <> null
    ),
    CleanedCountry = Table.TransformColumns(
        RemovedBlankRows,
        {{"Country", each Text.Clean(Text.Trim(Text.From(_))), type text}}
    ),
    NormalizedProjectId = Table.TransformColumns(
        CleanedCountry,
        {{"Project_ID", each fxNormalizeProjectId(_), type text}}
    ),
    RemovedDuplicateIds = Table.Distinct(NormalizedProjectId, {"Project_ID"})
in
    RemovedDuplicateIds