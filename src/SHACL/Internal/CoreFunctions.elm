module SHACL.Internal.CoreFunctions exposing (keyFromFilePath)

{-| Internal helpers carried into the package to avoid depending on
elm-qudt's `Lib.CoreFunctions`. Not part of the public API.
-}


{-| Derive a stable dictionary key from a file path. Strips the leading
directory, then drops the final ".ttl" / ".TTL" extension if present.

    keyFromFilePath "/data/qudt/COLLECTION_QUDT_QA_TESTS_ALL.ttl"
        == "COLLECTION_QUDT_QA_TESTS_ALL"

-}
keyFromFilePath : String -> String
keyFromFilePath filePath =
    let
        afterLastSlash =
            filePath
                |> String.split "/"
                |> List.reverse
                |> List.head
                |> Maybe.withDefault filePath

        lower =
            String.toLower afterLastSlash
    in
    if String.endsWith ".ttl" lower then
        String.dropRight 4 afterLastSlash

    else
        afterLastSlash
