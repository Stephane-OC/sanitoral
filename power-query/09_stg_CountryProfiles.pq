let
    RawSheet = src_SanitoralWorkbook{[Item = "Country_Profiles", Kind = "Sheet"]}[Data],
    SkippedIntroRows = Table.Skip(RawSheet, 1),
    PromotedHeaders = Table.PromoteHeaders(SkippedIntroRows, [PromoteAllScalars = true]),
    RenamedColumns = Table.RenameColumns(PromotedHeaders, {{"Type", "Entity_Type"}}),
    SelectedColumns = Table.SelectColumns(RenamedColumns, {"Country", "Region", "Entity_Type"}),
    RemovedBlankRows = Table.SelectRows(
        SelectedColumns,
        each [Country] <> null and [Region] <> null and [Entity_Type] <> null
    ),
    CleanedText = Table.TransformColumns(
        RemovedBlankRows,
        {
            {"Country", each Text.Clean(Text.Trim(Text.From(_))), type text},
            {"Region", each Text.Clean(Text.Trim(Text.From(_))), type text},
            {"Entity_Type", each Text.Clean(Text.Trim(Text.From(_))), type text}
        }
    ),
    RemovedDuplicateCountries = Table.Distinct(CleanedText, {"Country"})
in
    RemovedDuplicateCountries