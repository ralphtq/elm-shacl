module SHACL.Internal.CoreTypes exposing
    ( FilePath
    , GraphId
    , GraphMetaData
    , GraphRole(..)
    , IRI
    , LangString
    , MarkdownString
    , Prefix
    , PrefixDictionary
    , PropertyId
    , StringType(..)
    , TermId
    )

{-| Internal type module shared between `ralphtq/elm-shacl` and its
consumers (notably `elm-qudt`). These types are the canonical
definitions for nominal types that flow across the package boundary
in records like `GraphMetaData`. Duplicating them in the consumer
would create distinct nominal types and break interop on every record
that embeds one.

The naming `Internal` follows the conventional Elm soft-private signal.
Consumers may import these directly when they need constructor access
that doesn't propagate through type aliases.


# String aliases

@docs FilePath, GraphId, IRI, LangString, MarkdownString, Prefix, PrefixDictionary, PropertyId, TermId


# Nominal custom types

@docs GraphRole, StringType


# Records embedding the nominal types

@docs GraphMetaData

-}

import Rdf.Core.Types



-- STRING ALIASES (structural, no nominal-type issue)


{-| Path on the local file system. Structural alias of `String`.
-}
type alias FilePath =
    String


{-| Graph identifier. Re-export from `Rdf.Core.Types`.
-}
type alias GraphId =
    Rdf.Core.Types.GraphId


{-| Re-export of `Rdf.Core.Types.IRI`.
-}
type alias IRI =
    Rdf.Core.Types.IRI


{-| Language-tagged string. Re-export from `Rdf.Core.Types`.
-}
type alias LangString =
    Rdf.Core.Types.LangString


{-| Markdown-encoded string. Structural alias of `String`.
-}
type alias MarkdownString =
    String


{-| Re-export of `Rdf.Core.Types.Prefix`.
-}
type alias Prefix =
    Rdf.Core.Types.Prefix


{-| Re-export of `Rdf.Core.Types.PrefixDictionary`.
-}
type alias PrefixDictionary =
    Rdf.Core.Types.PrefixDictionary


{-| Identifier for a property. Structural alias of `TermId`.
-}
type alias PropertyId =
    TermId


{-| Identifier for an RDF term. Re-export from `Rdf.Core.Types`.
-}
type alias TermId =
    Rdf.Core.Types.TermId



-- NOMINAL CUSTOM TYPES (the reason this module exists)


{-| The role a graph plays in a SHACL workspace: a SHACL schema graph,
a vocabulary/ontology graph, or unspecified.
-}
type GraphRole
    = SchemaGraph
    | VocabGraph
    | UnspecifiedGraphRole


{-| A string-like value that may carry rendering hints — plain text,
LaTeX, or HTML.
-}
type StringType
    = TextValue String (Maybe LangString)
    | LaTeXvalue String
    | HTMLvalue String



-- RECORD ALIASES THAT EMBED THE NOMINAL TYPES


{-| Metadata describing one named graph: titles, contributors,
versioning, imports, and the `GraphRole`.
-}
type alias GraphMetaData =
    { attribution : Maybe (List String)
    , contributors : Maybe (List String)
    , created : Maybe String
    , description : Maybe String
    , editor : Maybe (List String)
    , graphName : Maybe String
    , graphRole : GraphRole
    , graphTitle : Maybe String
    , imports : List GraphId
    , intent : Maybe String
    , lastModified : Maybe String
    , latestPublishedVersion : Maybe String
    , logo : Maybe String
    , namespace : Maybe String
    , namespacePrefix : Maybe String
    , owner : Maybe String
    , previousPublishedVersion : Maybe String
    , rights : Maybe String
    , specificity : Maybe String
    , turtleFileURL : Maybe String
    , usesNonImportedResource : Maybe (List TermId)
    , version : Maybe String
    }
