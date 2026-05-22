module SHACL.InferenceShapeDictionary exposing
    ( AuxiliaryTtl
    , InferenceTransformKind(..)
    , InferenceTransformSpec
    , InferenceTransformers
    , LoadedInferenceTransforms
    , LoadedTransform
    , LoadedTransformKind(..)
    , PortInferenceTransformSpec
    , PortInferenceTransformsRequest
    , applicableTransformsForGraph
    , combineDirectoryAndPath
    , inferenceTransformErrorDecoder
    , inferredQuadsForTransformDecoder
    , loadedInferenceTransformsDecoder
    , shapesTtlForLoadedKind
    , specApplicableToGraph
    , toPortRequest
    )

{-| SHACL-driven inference catalog and loader pipeline.

An `InferenceTransformers` value is the declarative top-level catalog:
a named list of inference jobs (`InferenceTransformSpec`) plus a path
to the shared SHACL functions library. Each spec is tagged with its
execution shape via `InferenceTransformKind` — a SHACL rule TTL, a
template TTL with a SPARQL `.rq` body inlined, a SHACL-SPARQL TTL, or
a bare SPARQL `CONSTRUCT` query.

A round-trip through ports (`toPortRequest` →
`loadedInferenceTransformsDecoder` → `inferredQuadsForTransformDecoder`)
loads each spec's file contents, runs them via the Jena SHACL
inference engine, and returns the inferred quads.


# Spec catalog

@docs InferenceTransformers, InferenceTransformSpec, AuxiliaryTtl, InferenceTransformKind


# Port payload (Elm → TS)

@docs PortInferenceTransformsRequest, PortInferenceTransformSpec, toPortRequest


# Path joining and graph-filter helpers

@docs combineDirectoryAndPath, specApplicableToGraph, applicableTransformsForGraph


# Loaded payload (TS → Elm)

@docs LoadedInferenceTransforms, LoadedTransform, LoadedTransformKind


# Shapes-TTL synthesis

@docs shapesTtlForLoadedKind


# Decoders

@docs loadedInferenceTransformsDecoder, inferredQuadsForTransformDecoder, inferenceTransformErrorDecoder

-}

import Json.Decode as D
import Rdf.Wire.Types exposing (JSONrdfObject, JSONrdfQuad, JSONrdfTermTypeAndValue)
import SHACL.Internal.CoreTypes exposing (FilePath, GraphId)
import Time



-- SPEC


{-| Top-level inference catalog: a named, declarative list of inference
jobs. Each spec under `transformSpecs` is tagged with its execution
shape via `InferenceTransformKind`. The shared SHACL functions library
(e.g. `qudt-shacl-functions.ttl`) is referenced by `functionsPath` and
loaded inline at Phase 1 so the runner can send it without re-reading
the file or worrying about path-format conventions.
-}
type alias InferenceTransformers =
    { name : String
    , directory : FilePath
    , transformSpecs : List InferenceTransformSpec
    , functionsPath : FilePath
    }


{-| One inference job within an `InferenceTransformers` catalog: its
name, execution shape (`InferenceTransformKind`), destination file
path, and optional graph-scope restriction lists.
-}
type alias InferenceTransformSpec =
    { name : String
    , inferenceTransformKind : InferenceTransformKind
    , destinationFilePath : FilePath
    , onlyApplicableToGraphs : List GraphId
    , ancillaryGraphs : List GraphId
    }


type alias QueryFilePath =
    FilePath


{-| Optional auxiliary TTL companion to a `SPARQLconstructQuery`. The
file's content is loaded into the Jena dataset under the named graph
identified by `graphIri`, so the embedded query can reference it via
`GRAPH <graphIri> { … }` patterns. The TTL's `@prefix` declarations
are also extracted and prepended as SPARQL `PREFIX` lines so the
query can resolve those CURIEs (the `sh:prefixes qfn:` mechanism only
covers prefixes declared in the qfn ontology).
-}
type alias AuxiliaryTtl =
    { ttlPath : FilePath
    , graphIri : String
    }


{-| Four supported execution shapes. Each carries the spec-relative
path(s) needed to fetch the file contents at Phase 1; the runner then
synthesises a `shapesTtl` per kind via `shapesTtlForLoadedKind`.
-}
type InferenceTransformKind
    = SHACLrule FilePath
    | SHACLruleTemplate FilePath QueryFilePath
    | SHACLSPARQLrule FilePath
    | SPARQLconstructQuery (Maybe AuxiliaryTtl) QueryFilePath



-- LOADER PORT PAYLOAD


{-| Port-safe representation of an `InferenceTransformSpec` (Elm port
records cannot carry custom types directly, so the kind is flattened
to a tag string + maybe-wrapped paths).
-}
type alias PortInferenceTransformSpec =
    { name : String
    , kindTag : String
    , destinationFilePath : FilePath
    , rulePath : Maybe FilePath
    , templatePath : Maybe FilePath
    , queryPath : Maybe FilePath
    , auxiliaryTtlPath : Maybe FilePath
    , auxiliaryGraphIri : Maybe String
    , ancillaryGraphs : List GraphId
    }


{-| Port-safe top-level transforms request: the catalog name, base
directory, shared functions path, and a flat list of port specs.
-}
type alias PortInferenceTransformsRequest =
    { name : String
    , directory : FilePath
    , functionsPath : FilePath
    , specs : List PortInferenceTransformSpec
    }


{-| Convert an `InferenceTransformers` value into the port-safe shape.

Every path in every spec is resolved against the collection's
`directory` so the TS layer receives CWD-relative paths and does not
need to know about the `directory`/`spec-path` split. Same for
`functionsPath` and `destinationFilePath`.

-}
toPortRequest : InferenceTransformers -> PortInferenceTransformsRequest
toPortRequest transforms =
    let
        prefix =
            combineDirectoryAndPath transforms.directory
    in
    { name = transforms.name
    , directory = transforms.directory
    , functionsPath = prefix transforms.functionsPath
    , specs = List.map (specToPort prefix) transforms.transformSpecs
    }


specToPort : (FilePath -> FilePath) -> InferenceTransformSpec -> PortInferenceTransformSpec
specToPort prefix spec =
    let
        base =
            { name = spec.name
            , kindTag = ""
            , destinationFilePath = prefix spec.destinationFilePath
            , rulePath = Nothing
            , templatePath = Nothing
            , queryPath = Nothing
            , auxiliaryTtlPath = Nothing
            , auxiliaryGraphIri = Nothing
            , ancillaryGraphs = spec.ancillaryGraphs
            }
    in
    case spec.inferenceTransformKind of
        SHACLrule path ->
            { base | kindTag = "SHACLrule", rulePath = Just (prefix path) }

        SHACLruleTemplate templatePath queryPath ->
            { base
                | kindTag = "SHACLruleTemplate"
                , templatePath = Just (prefix templatePath)
                , queryPath = Just (prefix queryPath)
            }

        SHACLSPARQLrule path ->
            { base | kindTag = "SHACLSPARQLrule", rulePath = Just (prefix path) }

        SPARQLconstructQuery maybeAux queryPath ->
            { base
                | kindTag = "SPARQLconstructQuery"
                , queryPath = Just (prefix queryPath)
                , auxiliaryTtlPath = Maybe.map (.ttlPath >> prefix) maybeAux
                , auxiliaryGraphIri = Maybe.map .graphIri maybeAux
            }


{-| Join a transforms-directory with a spec-relative path. The result
is CWD-relative (suitable for the Vite plugin's
`safeWorkspacePath(...)` and for any consumer that needs a single
filesystem-rooted path).

Strips trailing slashes from the directory and leading slashes from
the path so the join produces no doubled or empty segments. An empty
directory is a no-op.

-}
combineDirectoryAndPath : FilePath -> FilePath -> FilePath
combineDirectoryAndPath directory path =
    let
        cleanDir =
            stripTrailingSlashes directory

        cleanPath =
            stripLeadingSlashes path
    in
    if cleanDir == "" then
        cleanPath

    else if cleanPath == "" then
        cleanDir

    else
        cleanDir ++ "/" ++ cleanPath


stripLeadingSlashes : String -> String
stripLeadingSlashes input =
    if String.startsWith "/" input then
        stripLeadingSlashes (String.dropLeft 1 input)

    else
        input


stripTrailingSlashes : String -> String
stripTrailingSlashes input =
    if String.endsWith "/" input then
        stripTrailingSlashes (String.dropRight 1 input)

    else
        input


{-| True if the spec is applicable to the given focus graph. A spec is
applicable when:

  - its `onlyApplicableToGraphs` list is empty (i.e. the spec has no
    graph restriction; applies to any focus graph), OR
  - the focus graph is `Just gid` and `gid` is in the list.

When `Nothing` (no focus graph) and the list is non-empty, the spec
is *not* applicable.

-}
specApplicableToGraph : Maybe GraphId -> InferenceTransformSpec -> Bool
specApplicableToGraph maybeFocusGraph spec =
    if List.isEmpty spec.onlyApplicableToGraphs then
        True

    else
        case maybeFocusGraph of
            Just gid ->
                List.member gid spec.onlyApplicableToGraphs

            Nothing ->
                False


{-| Return a copy of an `InferenceTransformers` value with
`transformSpecs` filtered to those applicable to the given focus
graph. Used by the Focus Graph view's "SHACL Rules" button so a click
loads only the transforms relevant to the current graph; the
Configuration → SHACL Rules sub-tab catalog uses the full unfiltered
catalog.
-}
applicableTransformsForGraph : Maybe GraphId -> InferenceTransformers -> InferenceTransformers
applicableTransformsForGraph maybeFocusGraph transforms =
    { transforms
        | transformSpecs =
            List.filter
                (specApplicableToGraph maybeFocusGraph)
                transforms.transformSpecs
    }



-- LOADED PAYLOAD (TS → Elm response)


{-| Response payload returned by the TS loader: the transforms with
their file contents inlined, plus the shared SHACL functions library.
-}
type alias LoadedInferenceTransforms =
    { name : String
    , directory : FilePath
    , functionsPath : FilePath
    , functionsTtl : Maybe String
    , functionsError : Maybe String
    , transforms : List LoadedTransform
    }


{-| One transform after the TS loader has inlined its file contents:
name, destination path, the resolved kind with its content, any error
message, the (initially empty) inferred quads buffer, and a timestamp
slot.
-}
type alias LoadedTransform =
    { name : String
    , destinationFilePath : FilePath
    , kind : LoadedTransformKind
    , error : Maybe String
    , inferredQuads : List JSONrdfQuad
    , lastInferredAt : Maybe Time.Posix
    , ancillaryGraphs : List GraphId
    }


{-| The four supported execution shapes, with their file contents
inlined. `LoadedTransformKindUnknown` is a fallback for forward
compatibility — a kindTag the Elm side does not recognise round-trips
unchanged so the runner can report it instead of failing the whole
batch decode.
-}
type LoadedTransformKind
    = LoadedSHACLrule { path : FilePath, content : String }
    | LoadedSHACLruleTemplate
        { templatePath : FilePath
        , templateContent : String
        , queryPath : FilePath
        , queryContent : String
        }
    | LoadedSHACLSPARQLrule { path : FilePath, content : String }
    | LoadedSPARQLconstructQuery
        { queryPath : FilePath
        , queryContent : String
        , auxiliaryTtlPath : Maybe FilePath
        , auxiliaryTtlContent : Maybe String
        , auxiliaryGraphIri : Maybe String
        }
    | LoadedTransformKindUnknown String


{-| Decoder for the `LoadedInferenceTransforms` JSON payload sent by
the TS loader after it reads the rule / template / query files.
-}
loadedInferenceTransformsDecoder : D.Decoder LoadedInferenceTransforms
loadedInferenceTransformsDecoder =
    D.map6
        (\name directory functionsPath functionsTtl functionsError transforms ->
            { name = name
            , directory = directory
            , functionsPath = functionsPath
            , functionsTtl = functionsTtl
            , functionsError = functionsError
            , transforms = transforms
            }
        )
        (D.field "name" D.string)
        (D.field "directory" D.string)
        (D.field "functionsPath" D.string)
        (D.maybe (D.field "functionsTtl" D.string))
        (D.maybe (D.field "functionsError" D.string))
        (D.field "transforms" (D.list loadedTransformDecoder))


loadedTransformDecoder : D.Decoder LoadedTransform
loadedTransformDecoder =
    D.map5
        (\name destinationFilePath kind error ancillaryGraphs ->
            { name = name
            , destinationFilePath = destinationFilePath
            , kind = kind
            , error = error
            , inferredQuads = []
            , lastInferredAt = Nothing
            , ancillaryGraphs = ancillaryGraphs
            }
        )
        (D.field "name" D.string)
        (D.field "destinationFilePath" D.string)
        loadedTransformKindDecoder
        (D.maybe (D.field "error" D.string))
        (D.oneOf
            [ D.field "ancillaryGraphs" (D.list D.string)
            , D.succeed []
            ]
        )


loadedTransformKindDecoder : D.Decoder LoadedTransformKind
loadedTransformKindDecoder =
    D.field "kindTag" D.string
        |> D.andThen
            (\tag ->
                case tag of
                    "SHACLrule" ->
                        D.map2
                            (\p c -> LoadedSHACLrule { path = p, content = c })
                            (D.field "rulePath" D.string)
                            (D.field "ruleContent" D.string)

                    "SHACLruleTemplate" ->
                        D.map4
                            (\tp tc qp qc ->
                                LoadedSHACLruleTemplate
                                    { templatePath = tp
                                    , templateContent = tc
                                    , queryPath = qp
                                    , queryContent = qc
                                    }
                            )
                            (D.field "templatePath" D.string)
                            (D.field "templateContent" D.string)
                            (D.field "queryPath" D.string)
                            (D.field "queryContent" D.string)

                    "SHACLSPARQLrule" ->
                        D.map2
                            (\p c -> LoadedSHACLSPARQLrule { path = p, content = c })
                            (D.field "rulePath" D.string)
                            (D.field "ruleContent" D.string)

                    "SPARQLconstructQuery" ->
                        D.map5
                            (\qp qc auxP auxC auxG ->
                                LoadedSPARQLconstructQuery
                                    { queryPath = qp
                                    , queryContent = qc
                                    , auxiliaryTtlPath = auxP
                                    , auxiliaryTtlContent = auxC
                                    , auxiliaryGraphIri = auxG
                                    }
                            )
                            (D.field "queryPath" D.string)
                            (D.field "queryContent" D.string)
                            (D.maybe (D.field "auxiliaryTtlPath" D.string))
                            (D.maybe (D.field "auxiliaryTtlContent" D.string))
                            (D.maybe (D.field "auxiliaryGraphIri" D.string))

                    _ ->
                        D.succeed (LoadedTransformKindUnknown tag)
            )



-- RUNNER: per-kind SHACL shapes-TTL synthesis
--
-- The Jena bridge accepts a list of `{ key, shapesTtl }` records. To
-- unify all four `LoadedTransformKind` variants behind that single
-- execution path, each kind is converted to a shapes-TTL string:
--
--   • `LoadedSHACLrule`         — content is already a SHACL rule TTL
--   • `LoadedSHACLSPARQLrule`   — content is already a SHACL-SPARQL TTL
--   • `LoadedSHACLruleTemplate` — substitute the query into the template
--   • `LoadedSPARQLconstructQuery` — wrap the bare CONSTRUCT in a small
--     `sh:NodeShape`/`sh:SPARQLRule` envelope (`wrapConstructInSparqlRule`)
--
-- `LoadedTransformKindUnknown` returns `Nothing`; the caller should
-- treat that as "transform cannot be run".


{-| Produce a SHACL-shapes TTL string from a `LoadedTransformKind`.
Returns `Nothing` for `LoadedTransformKindUnknown` (the runner treats
that as "transform cannot be run").
-}
shapesTtlForLoadedKind : LoadedTransformKind -> Maybe String
shapesTtlForLoadedKind kind =
    case kind of
        LoadedSHACLrule { content } ->
            Just content

        LoadedSHACLSPARQLrule { content } ->
            Just content

        LoadedSHACLruleTemplate { templateContent, queryContent } ->
            Just (substituteQueryIntoTemplate templateContent queryContent)

        LoadedSPARQLconstructQuery { queryContent, auxiliaryTtlContent } ->
            let
                prologue =
                    case auxiliaryTtlContent of
                        Just ttl ->
                            extractTurtlePrefixDeclarations ttl

                        Nothing ->
                            ""
            in
            Just
                (wrapConstructInSparqlRule
                    { prologue = prologue
                    , query = queryContent
                    }
                )

        LoadedTransformKindUnknown _ ->
            Nothing


{-| Substitute a SPARQL query body into an infer-template string.
Strips the query's leading `prefix …` declarations and escapes
backslashes / triple-quotes so the result survives TTL string
un-escaping when Jena reads back the embedded `sh:construct""" … """`.
-}
substituteQueryIntoTemplate : String -> String -> String
substituteQueryIntoTemplate template query =
    String.replace "{{QUERY_WITHOUT_PREFIXES}}"
        (escapeForTtlTripleQuoteLiteral (stripPrefixLines query))
        template


escapeForTtlTripleQuoteLiteral : String -> String
escapeForTtlTripleQuoteLiteral query =
    query
        |> String.replace "\\" "\\\\"
        |> String.replace "\"\"\"" "\\\"\\\"\\\""


{-| Drop leading `prefix …` declarations from a SPARQL string. Keeps
blank lines and any non-prefix content. Conservative: matches lines
beginning (after trim) with `prefix` (case-insensitive).
-}
stripPrefixLines : String -> String
stripPrefixLines query =
    query
        |> String.lines
        |> List.filter (not << isPrefixLine)
        |> String.join "\n"


isPrefixLine : String -> Bool
isPrefixLine line =
    let
        trimmed =
            line |> String.trim |> String.toLower
    in
    String.startsWith "prefix " trimmed
        || String.startsWith "@prefix" trimmed


{-| Wrap a bare SPARQL `CONSTRUCT` query (the entire `.rq` file body)
in a minimal SHACL-SPARQL rule TTL so the Jena SHACL inference engine
will execute it. The wrapper:

  - declares an `owl:Ontology` that imports `qfn:` so the merged QUDT
    SHACL functions library is available (matches the convention used
    by `infer-template.ttl` files under `sparql2shacl/`);
  - attaches the rule to a `sh:NodeShape` whose only target is a
    sentinel IRI (`<urn:elm-qudt:construct-rule#focus>`), so the rule
    fires exactly once regardless of what the query references;
  - sets `sh:prefixes qfn:` to pull SHACL-side prefix declarations
    from the qfn ontology.

The optional `prologue` is a string of SPARQL `PREFIX` declarations
(typically extracted from an auxiliary TTL via
`extractTurtlePrefixDeclarations`) that gets prepended to the embedded
query body so its CURIEs resolve. Use this when the rule references a
namespace that the qfn ontology doesn't declare (e.g. `cnf:` for
`lang-label-config.ttl`).

The query is passed through `stripPrefixLines` and
`escapeForTtlTripleQuoteLiteral` so backslashes and triple-quotes
survive Turtle parsing intact.

-}
wrapConstructInSparqlRule : { prologue : String, query : String } -> String
wrapConstructInSparqlRule { prologue, query } =
    let
        bareQuery =
            stripPrefixLines query

        composed =
            if String.isEmpty (String.trim prologue) then
                bareQuery

            else
                prologue ++ "\n" ++ bareQuery

        escaped =
            escapeForTtlTripleQuoteLiteral composed
    in
    String.join "\n"
        [ "@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> ."
        , "@prefix owl: <http://www.w3.org/2002/07/owl#> ."
        , "@prefix sh: <http://www.w3.org/ns/shacl#> ."
        , "@prefix qfn: <http://qudt.org/shacl/functions#> ."
        , ""
        , "<urn:elm-qudt:construct-rule>"
        , "  a owl:Ontology ;"
        , "  owl:imports qfn: ."
        , ""
        , "<urn:elm-qudt:construct-rule#shape>"
        , "  a sh:NodeShape ;"
        , "  sh:targetNode <urn:elm-qudt:construct-rule#focus> ;"
        , "  sh:rule ["
        , "    a sh:SPARQLRule ;"
        , "    sh:prefixes qfn: ;"
        , "    sh:construct \"\"\""
        , escaped
        , "    \"\"\" ;"
        , "  ] ."
        , ""
        ]


{-| Extract Turtle `@prefix foo: <iri> .` declarations from a TTL
string and return them as SPARQL-style `PREFIX foo: <iri>` lines, one
per line. Conservative parser: matches lines that, after trimming,
start with `@prefix`, then extracts the prefix label, the IRI, and
ignores the rest. Lines that don't match that shape are silently
skipped.
-}
extractTurtlePrefixDeclarations : String -> String
extractTurtlePrefixDeclarations ttl =
    ttl
        |> String.lines
        |> List.filterMap parseTurtlePrefixLine
        |> List.map (\( prefix, iri ) -> "PREFIX " ++ prefix ++ ": <" ++ iri ++ ">")
        |> String.join "\n"


parseTurtlePrefixLine : String -> Maybe ( String, String )
parseTurtlePrefixLine line =
    let
        trimmed =
            String.trim line
    in
    if String.startsWith "@prefix" trimmed then
        let
            afterAtPrefix =
                trimmed
                    |> String.dropLeft 7
                    |> String.trim
        in
        case firstIndexOf ":" afterAtPrefix of
            Just colonAt ->
                let
                    prefix =
                        String.left colonAt afterAtPrefix

                    afterColon =
                        afterAtPrefix
                            |> String.dropLeft (colonAt + 1)
                            |> String.trim
                in
                if String.startsWith "<" afterColon then
                    let
                        afterAngle =
                            String.dropLeft 1 afterColon
                    in
                    case firstIndexOf ">" afterAngle of
                        Just closeAt ->
                            Just ( prefix, String.left closeAt afterAngle )

                        Nothing ->
                            Nothing

                else
                    Nothing

            Nothing ->
                Nothing

    else
        Nothing


firstIndexOf : String -> String -> Maybe Int
firstIndexOf needle haystack =
    String.indexes needle haystack |> List.head



-- INFERENCE-RUN PORT DECODERS


{-| Decoder for the per-transform inference response payload sent by
the TS layer (`receiveInferredQuadsForTransform`).
-}
inferredQuadsForTransformDecoder :
    D.Decoder
        { name : String
        , quads : List JSONrdfQuad
        }
inferredQuadsForTransformDecoder =
    D.map2
        (\n q -> { name = n, quads = q })
        (D.field "name" D.string)
        (D.field "quads" (D.list jsonRdfQuadDecoder))


{-| Decoder for a per-transform inference error payload sent by the TS
layer when a transform fails (`{ name, message }`).
-}
inferenceTransformErrorDecoder :
    D.Decoder
        { name : String
        , message : String
        }
inferenceTransformErrorDecoder =
    D.map2
        (\n m -> { name = n, message = m })
        (D.field "name" D.string)
        (D.field "message" D.string)


jsonRdfQuadDecoder : D.Decoder JSONrdfQuad
jsonRdfQuadDecoder =
    D.map4
        (\s p o g ->
            { subject = s, predicate = p, object = o, graph = g }
        )
        (D.field "subject" jsonTermDecoder)
        (D.field "predicate" jsonTermDecoder)
        (D.field "object" jsonObjectDecoder)
        (D.field "graph" jsonTermDecoder)


jsonTermDecoder : D.Decoder JSONrdfTermTypeAndValue
jsonTermDecoder =
    D.map2
        (\t v -> { termType = t, value = v, id = "" })
        (D.field "termType" D.string)
        (D.field "value" D.string)


jsonObjectDecoder : D.Decoder JSONrdfObject
jsonObjectDecoder =
    D.map4
        (\t v lang dt ->
            { termType = t
            , value = v
            , language = lang
            , datatype = dt
            , id = ""
            }
        )
        (D.field "termType" D.string)
        (D.field "value" D.string)
        (D.maybe (D.field "language" D.string))
        (D.maybe (D.field "datatype" jsonTermDecoder))
