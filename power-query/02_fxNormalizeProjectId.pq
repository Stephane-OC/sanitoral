// ============================================================================
// FONCTION : 02 - fxNormalizeProjectId
// OBJECTIF : Uniformiser les identifiants de projet utilisés dans les jointures
// ENTRÉE   : Identifiant de type quelconque éventuellement nul
// SORTIE   : Texte sur trois caractères (exemple : 7 devient 007) ou null
// CHARGEMENT : Désactivé car cet élément est une fonction réutilisable
// ============================================================================

(projectId as any) as nullable text =>
let
    // Convertit la valeur en texte et supprime les espaces inutiles
    // Le test préalable conserve les valeurs nulles sans provoquer d'erreur
    AsText = if projectId = null then null else Text.Trim(Text.From(projectId, "en-US")),

    // Ignore les identifiants vides et complète les autres avec des zéros à gauche
    Normalized = if AsText = null or AsText = "" then null else Text.PadStart(AsText, 3, "0")
in
    Normalized