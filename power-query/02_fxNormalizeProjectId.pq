(projectId as any) as nullable text =>
let
    AsText = if projectId = null then null else Text.Trim(Text.From(projectId, "en-US")),
    Normalized = if AsText = null or AsText = "" then null else Text.PadStart(AsText, 3, "0")
in
    Normalized