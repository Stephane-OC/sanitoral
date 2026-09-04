// ============================================================================
// REQUÊTE : 12 - Dim_Date
// OBJECTIF : Créer un calendrier continu pour les analyses temporelles
// GRAIN    : Une ligne par jour
// DÉPENDANCE : Fact_ProjectPhase
// SORTIE   : Dimension de dates couvrant toute la période observée
// CHARGEMENT : Activé et table marquée comme table de dates dans le modèle
// ============================================================================

let
    // 1. Détermine les bornes du calendrier à partir des dates des phases
    MinimumDate = List.Min(Fact_ProjectPhase[Start_Date]),
    MaximumDate = List.Max(Fact_ProjectPhase[Actual_End_Date]),

    // 2. Calcule le nombre de jours en incluant les deux dates limites
    NumberOfDays = Duration.Days(MaximumDate - MinimumDate) + 1,

    // 3. Génère une liste continue avec un pas d'une journée
    DateList = List.Dates(MinimumDate, NumberOfDays, #duration(1, 0, 0, 0)),

    // 4. Convertit la liste en table et définit la colonne comme type date
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),
    ChangedType = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),

    // 5. Ajoute les attributs nécessaires aux regroupements chronologiques
    AddedYear = Table.AddColumn(ChangedType, "Year", each Date.Year([Date]), Int64.Type),
    AddedQuarter = Table.AddColumn(AddedYear, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddedMonthNumber = Table.AddColumn(AddedQuarter, "Month_Number", each Date.Month([Date]), Int64.Type),
    AddedMonthName = Table.AddColumn(AddedMonthNumber, "Month_Name", each Date.MonthName([Date], "fr-FR"), type text),

    // 6. Crée une clé année-mois au format YYYY-MM, adaptée au tri chronologique
    AddedYearMonth = Table.AddColumn(AddedMonthName, "Year_Month", each Date.ToText([Date], "yyyy-MM"), type text)
in
    AddedYearMonth