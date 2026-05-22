module SHACL.ShapeDictionary exposing
    ( ShapeEntry
    , ShapeDictionary
    , ShapeCollection
    , ShapeCollectionEntry
    , ShapeCollections
    , buildEntry
    , shapeCollectionResponseDecoder
    , reassembleShapeTTL
    , reassembleShapeTTLfromEntry
    )

import Dict exposing (Dict)
import Json.Decode as D
import Rdf.Core.Types exposing (PrefixDictionary)
import SHACL.Internal.CoreFunctions exposing (keyFromFilePath)


type alias ShapeEntry =
    { name : String
    , description : String
    , shapeTTL : String
    }


type alias ShapeDictionary =
    Dict String ShapeEntry


type alias ShapeCollection =
    { shapes : ShapeDictionary
    , prefixes : PrefixDictionary
    }


{-| One loaded shape-collection file: the parsed shapes, the parsed
common shapes (prefix declarations + SPARQL functions), the prefixes,
and the source path. Held in the model's `shapeCollections` dict keyed
by `key` (derived from the file basename).
-}
type alias ShapeCollectionEntry =
    { key : String
    , filePath : String
    , label : String
    , shapes : ShapeDictionary
    , commonShapes : ShapeDictionary
    , prefixes : PrefixDictionary
    }


type alias ShapeCollections =
    Dict String ShapeCollectionEntry


{-| Build a `ShapeCollectionEntry` from the raw parser output and its
source path. The key and label both default to `keyFromFilePath`.
-}
buildEntry :
    { filePath : String
    , commonShapes : ShapeDictionary
    , collection : ShapeCollection
    }
    -> ShapeCollectionEntry
buildEntry { filePath, commonShapes, collection } =
    let
        key =
            keyFromFilePath filePath
    in
    { key = key
    , filePath = filePath
    , label = key
    , shapes = collection.shapes
    , commonShapes = commonShapes
    , prefixes = collection.prefixes
    }


shapeCollectionResponseDecoder :
    D.Decoder
        { filePath : String
        , commonShapes : ShapeDictionary
        , collection : ShapeCollection
        }
shapeCollectionResponseDecoder =
    D.map4
        (\filePath commonShapes shapes prefixes ->
            { filePath = filePath
            , commonShapes = commonShapes
            , collection = { shapes = shapes, prefixes = prefixes }
            }
        )
        (D.field "filePath" D.string)
        (D.field "commonShapes" shapeDictionaryDecoder)
        (D.field "shapes" shapeDictionaryDecoder)
        (D.field "prefixes" prefixDictionaryDecoder)


shapeDictionaryDecoder : D.Decoder ShapeDictionary
shapeDictionaryDecoder =
    D.list shapeEntryPairDecoder
        |> D.map Dict.fromList


shapeEntryPairDecoder : D.Decoder ( String, ShapeEntry )
shapeEntryPairDecoder =
    D.map4
        (\key name desc ttl ->
            ( key, { name = name, description = desc, shapeTTL = ttl } )
        )
        (D.field "key" D.string)
        (D.field "name" D.string)
        (D.field "description" D.string)
        (D.field "shapeTTL" D.string)


prefixDictionaryDecoder : D.Decoder PrefixDictionary
prefixDictionaryDecoder =
    D.list (D.map2 Tuple.pair (D.field "prefix" D.string) (D.field "iri" D.string))
        |> D.map Dict.fromList


reassembleShapeTTL : ShapeDictionary -> ShapeCollection -> List String -> String
reassembleShapeTTL commonShapesDict collection shapeKeys =
    let
        prefixLines =
            collection.prefixes
                |> Dict.toList
                |> List.map (\( prefix, iri ) -> "@prefix " ++ prefix ++ ": <" ++ iri ++ "> .")
                |> String.join "\n"

        commonTTLs =
            commonShapesDict
                |> Dict.values
                |> List.map .shapeTTL
                |> String.join "\n\n"

        selectedTTLs =
            shapeKeys
                |> List.filterMap (\key -> Dict.get key collection.shapes)
                |> List.map .shapeTTL
                |> String.join "\n\n"
    in
    String.join "\n\n"
        [ prefixLines
        , commonTTLs
        , selectedTTLs
        ]


{-| Convenience wrapper around `reassembleShapeTTL` for callers that
already have a `ShapeCollectionEntry`.
-}
reassembleShapeTTLfromEntry : ShapeCollectionEntry -> List String -> String
reassembleShapeTTLfromEntry entry shapeKeys =
    reassembleShapeTTL
        entry.commonShapes
        { shapes = entry.shapes, prefixes = entry.prefixes }
        shapeKeys
