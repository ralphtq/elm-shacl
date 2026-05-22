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

{-| Dictionaries of named SHACL shapes, loaded from disk or a network
endpoint and held in memory as parsed Turtle plus the prefix declarations
needed to re-serialize them.

A `ShapeCollection` groups a `ShapeDictionary` (the named shapes keyed
by short name) with the `PrefixDictionary` of CURIE prefixes used across
those shapes. A `ShapeCollectionEntry` wraps that with its source file
path, derived key, and a separate dictionary of "common" shapes (prefix
declarations and SPARQL function libraries shared across the collection).


# Entries

@docs ShapeEntry, ShapeDictionary


# Collections

@docs ShapeCollection, ShapeCollectionEntry, ShapeCollections


# Building from parsed input

@docs buildEntry, shapeCollectionResponseDecoder


# Reassembling Turtle

@docs reassembleShapeTTL, reassembleShapeTTLfromEntry

-}

import Dict exposing (Dict)
import Json.Decode as D
import Rdf.Core.Types exposing (PrefixDictionary)
import SHACL.Internal.CoreFunctions exposing (keyFromFilePath)


{-| A single named SHACL shape: its display name, a human-readable
description, and the Turtle source of the shape itself (without prefix
declarations).
-}
type alias ShapeEntry =
    { name : String
    , description : String
    , shapeTTL : String
    }


{-| Map from short name (the key in the source TTL) to its `ShapeEntry`.
-}
type alias ShapeDictionary =
    Dict String ShapeEntry


{-| A parsed shape collection: the named shapes and the prefix
dictionary needed to render them as valid Turtle.
-}
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


{-| Map of `ShapeCollectionEntry` values keyed by their derived `key`
(usually the source file basename without the `.ttl` extension).
-}
type alias ShapeCollections =
    Dict String ShapeCollectionEntry


{-| Build a `ShapeCollectionEntry` from the raw parser output and its
source path. The `key` and `label` both default to `keyFromFilePath`.
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


{-| Decode the JSON response from the TS shape-collection parser:
the source path, a dictionary of common shapes, and the named-shape
collection (shapes + prefixes).
-}
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


{-| Reassemble a valid Turtle document from a selection of shape keys.
Joins the collection's prefix declarations, every common shape, and the
named shapes whose keys appear in the given list (in source order).
-}
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
