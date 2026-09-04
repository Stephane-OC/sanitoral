// ============================================================================
// REQUÊTE : 01 - src_SanitoralWorkbook
// OBJECTIF : Ouvrir une seule fois le classeur Excel utilisé comme source
// DÉPENDANCE : pDataFilePath
// SORTIE   : Table de navigation contenant les feuilles du classeur
// CHARGEMENT : Désactivé, car cette requête sert uniquement de source technique
// ============================================================================

let
    // Lit le fichier binaire indiqué par le paramètre, puis expose son contenu
    Source = Excel.Workbook(File.Contents(pDataFilePath), null, true)
in
    Source