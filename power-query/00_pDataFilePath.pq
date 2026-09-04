// ============================================================================
// REQUÊTE : 00 - pDataFilePath
// OBJECTIF : Centraliser le chemin du fichier Excel source dans un seul élément
// TYPE     : Paramètre texte
// SORTIE   : Chemin complet vers le classeur de données Sanitoral
// USAGE    : Modifier uniquement cette valeur lorsque le fichier source est déplacé
// ============================================================================

// Le chemin est séparé des autres requêtes afin de faciliter les mises à jour
let
    DataFilePath = "C:\CHEMIN\sanitoral-dashboard\data\raw\sanitoral_project_data.xlsx"
in
    DataFilePath