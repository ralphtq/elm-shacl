module SHACL.Internal.CoreFunctions exposing
    ( keyFromFilePath
    , nonLiteralToString
    , objectsForGivenSubjectPredicate
    , predicateToString
    )

{-| Internal helpers carried into the package to avoid depending on
elm-qudt's `Lib.CoreFunctions` and `RDF.Datamodel.*` modules. Not part
of the public API.
-}

import Rdf.Core.Types
    exposing
        ( PredicateTerm(..)
        , Quad
        , RDFnonLiteralTerm(..)
        , RDFterm
        , TermId
        )
import SHACL.Internal.CoreTypes exposing (PropertyId)


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
