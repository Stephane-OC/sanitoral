let
    MinimumDate = List.Min(Fact_ProjectPhase[Start_Date]),
    MaximumDate = List.Max(Fact_ProjectPhase[Actual_End_Date]),
    NumberOfDays = Duration.Days(MaximumDate - MinimumDate) + 1,
    DateList = List.Dates(MinimumDate, NumberOfDays, #duration(1, 0, 0, 0)),
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),
    ChangedType = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),
    AddedYear = Table.AddColumn(ChangedType, "Year", each Date.Year([Date]), Int64.Type),
    AddedQuarter = Table.AddColumn(AddedYear, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddedMonthNumber = Table.AddColumn(AddedQuarter, "Month_Number", each Date.Month([Date]), Int64.Type),
    AddedMonthName = Table.AddColumn(AddedMonthNumber, "Month_Name", each Date.MonthName([Date], "fr-FR"), type text),
    AddedYearMonth = Table.AddColumn(AddedMonthName, "Year_Month", each Date.ToText([Date], "yyyy-MM"), type text)
in
    AddedYearMonth