let
    Source = stg_ProjectType,
    MergedLocations = Table.NestedJoin(
        Source,
        {"Project_ID"},
        stg_ProjectLocations,
        {"Project_ID"},
        "Location",
        JoinKind.LeftOuter
    ),
    ExpandedLocation = Table.ExpandTableColumn(MergedLocations, "Location", {"Country"}, {"Country"}),
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
    AddedProjectLabel = Table.AddColumn(
        ExpandedCountryProfile,
        "Project_Label",
        each "PRJ-" & [Project_ID],
        type text
    ),
    RemovedDuplicateIds = Table.Distinct(AddedProjectLabel, {"Project_ID"})
in
    RemovedDuplicateIds