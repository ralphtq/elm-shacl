module SHACL.Internal.CoreFunctions exposing
    ( englishLang
    , getResourceQuads
    , keyFromFilePath
    , nonLiteralObjectsForGivenSubjectPredicate
    , nonLiteralToString
    , objectsForGivenSubjectPredicate
    , predicateToId
    , predicateToString
    , quadGraphToGraphId
    , quadsToQuadStatements
    , rdfTermToString
    , statementsForGivenSubject
    , subjectHasPredicateObject
    , subjectPredicateQuad
    , subjectPredicatesForGivenObject
    , subjectsForGivenPredicateObject
    )

{-| Internal helpers carried into the package to avoid depending on
elm-qudt's `Lib.CoreFunctions` and `RDF.Datamodel.*` modules. Not part
of the public API.
-}

import Dict
import Rdf.Core.Types as Core
import Rdf.Core.Types
    exposing
        ( GraphId
        , IRI
        , NamedNodeId(..)
        , PredicateTerm(..)
        , Quad
        , QuadGraph(..)
        , QuadStatement
        , RDFliteralTerm(..)
        , RDFnonLiteralTerm(..)
        , RDFterm(..)
        , TermId
        )
import SHACL.Internal.CoreTypes exposing (PropertyId)


{-| `Just "en"` — convenience constant for the English language tag,
used when stamping a default language onto labels with no explicit tag.
-}
englishLang : Maybe Core.LangString
englishLang =
    Just "en"


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


{-| Extract the IRI string from a `PredicateTerm`.
-}
predicateToString : PredicateTerm -> TermId
predicateToString predicate =
    case predicate of
        PredicateNamedNode iri ->
            iri


{-| Alias for `predicateToString` returning an `IRI`. Convenience name
used by callers that conceptually want the predicate's id (an IRI).
-}
predicateToId : PredicateTerm -> IRI
predicateToId predicate =
    case predicate of
        PredicateNamedNode iri ->
            iri


{-| Extract the identifier string from an `RDFnonLiteralTerm`, returning
the IRI of a named node or the blank-node id of a blank node.
-}
nonLiteralToString : RDFnonLiteralTerm -> TermId
nonLiteralToString nonLiteral =
    case nonLiteral of
        NamedNode iri ->
            iri

        BlankNode blankNodeId ->
            blankNodeId


{-| Extract the `GraphId` (a String) from a `QuadGraph`. The default
graph is the empty string; named-node graphs are their IRI.
-}
quadGraphToGraphId : QuadGraph -> GraphId
quadGraphToGraphId quadGraph =
    case quadGraph of
        DefaultGraph ->
            ""

        QuadGraphNamedNode nodeId ->
            case nodeId of
                IRIid iri ->
                    iri


{-| Return every quad whose subject equals `resource`.
-}
getResourceQuads : RDFnonLiteralTerm -> List Quad -> List Quad
getResourceQuads resource quads =
    quads
        |> List.filter (\q -> q.subject == resource)


{-| The single quad with the given subject and predicate, if exactly one
exists. Returns `Nothing` for zero matches or for ambiguous (>1) matches.
-}
subjectPredicateQuad : RDFnonLiteralTerm -> PredicateTerm -> List Quad -> Maybe Quad
subjectPredicateQuad resource predicateTerm quads =
    case
        quads
            |> List.filter
                (\q ->
                    (q.subject == resource)
                        && (q.predicate == predicateTerm)
                )
    of
        [ head ] ->
            Just head

        _ ->
            Nothing


{-| For every quad whose object is `NonLiteral resource`, return the
distinct `(subject, predicate)` pairs.
-}
subjectPredicatesForGivenObject : RDFnonLiteralTerm -> List Quad -> List ( RDFnonLiteralTerm, PredicateTerm )
subjectPredicatesForGivenObject resource quads =
    quads
        |> List.filter (\q -> q.object == NonLiteral resource)
        |> List.map (\q -> ( q.subject, q.predicate ))
        |> dedupe


{-| Render an `RDFterm` to its string form for display: literals lose
their type tag but keep the language suffix; named nodes return their
IRI; blank nodes return their id; predicate terms return their IRI;
anything else falls back to `Debug.toString`.
-}
rdfTermToString : RDFterm -> String
rdfTermToString rdfTerm =
    case rdfTerm of
        Literal literal ->
            case literal of
                LiteralString str maybeLangCode ->
                    case maybeLangCode of
                        Just lang ->
                            str ++ " ( " ++ lang ++ ")"

                        Nothing ->
                            str

                LiteralDataType str _ ->
                    str

        NonLiteral (NamedNode iri) ->
            iri

        NonLiteral (BlankNode blankNodeId) ->
            blankNodeId

        Predicate predicate ->
            case predicate of
                PredicateNamedNode iri ->
                    iri

        _ ->
            Debug.toString rdfTerm


{-| Like `objectsForGivenSubjectPredicate` but only returns objects
that are non-literal terms (named or blank nodes).
-}
nonLiteralObjectsForGivenSubjectPredicate : RDFnonLiteralTerm -> TermId -> List Quad -> List RDFnonLiteralTerm
nonLiteralObjectsForGivenSubjectPredicate subject predicate quads =
    objectsForGivenSubjectPredicate subject predicate quads
        |> List.filterMap
            (\rdfTerm ->
                case rdfTerm of
                    NonLiteral nl ->
                        Just nl

                    _ ->
                        Nothing
            )


{-| `True` if any quad in the list has the given subject, predicate,
and object.
-}
subjectHasPredicateObject : RDFnonLiteralTerm -> PredicateTerm -> RDFterm -> List Quad -> Bool
subjectHasPredicateObject subject predicate object quads =
    quads
        |> List.any
            (\q ->
                (q.subject == subject)
                    && (q.predicate == predicate)
                    && (q.object == object)
            )


{-| Filter the quads for a given subject + predicate and return the
distinct objects (using structural equality).
-}
objectsForGivenSubjectPredicate : RDFnonLiteralTerm -> PropertyId -> List Quad -> List RDFterm
objectsForGivenSubjectPredicate subject predicateId quads =
    quads
        |> List.filter
            (\q ->
                (q.predicate == PredicateNamedNode predicateId)
                    && (q.subject == subject)
            )
        |> List.map (\q -> q.object)
        |> dedupe


{-| Filter the quads for a given predicate + object and return the
distinct subjects. Returns `Nothing` when no quads match.
-}
subjectsForGivenPredicateObject : TermId -> RDFterm -> List Quad -> Maybe (List RDFnonLiteralTerm)
subjectsForGivenPredicateObject predicate object quads =
    let
        matching =
            quads
                |> List.filter
                    (\q ->
                        (q.predicate == PredicateNamedNode predicate)
                            && (q.object == object)
                    )
                |> List.map (\q -> q.subject)
                |> dedupe
    in
    if List.isEmpty matching then
        Nothing

    else
        Just matching


{-| All `(predicate, object)` pairs whose subject equals `subject`,
de-duplicated by structural equality.
-}
statementsForGivenSubject : RDFnonLiteralTerm -> List Quad -> List ( PredicateTerm, RDFterm )
statementsForGivenSubject subject quads =
    quads
        |> List.filter (\q -> q.subject == subject)
        |> List.map (\q -> ( q.predicate, q.object ))
        |> dedupe


{-| Collapse a list of quads into a list of `QuadStatement` records,
grouping multiple objects under the same `(subject, predicate, graph)`
key into a single statement.
-}
quadsToQuadStatements : List Quad -> List QuadStatement
quadsToQuadStatements quads =
    quads
        |> List.foldl
            (\quad acc ->
                let
                    key : ( String, String, String )
                    key =
                        ( nonLiteralToString quad.subject
                        , predicateToId quad.predicate
                        , quadGraphToGraphId quad.graph
                        )

                    updatedStatement =
                        case Dict.get key acc of
                            Just statementsSoFar ->
                                { subject = quad.subject
                                , predicate = quad.predicate
                                , objects = quad.object :: statementsSoFar.objects
                                , graph = quad.graph
                                }

                            Nothing ->
                                { subject = quad.subject
                                , predicate = quad.predicate
                                , objects = [ quad.object ]
                                , graph = quad.graph
                                }
                in
                Dict.insert key updatedStatement acc
            )
            Dict.empty
        |> Dict.values
        |> dedupe


dedupe : List a -> List a
dedupe list =
    List.foldr
        (\x acc ->
            if List.member x acc then
                acc

            else
                x :: acc
        )
        []
        list
