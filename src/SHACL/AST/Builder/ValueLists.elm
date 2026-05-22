module SHACL.AST.Builder.ValueLists exposing
    ( buildBlankNodes
    , buildValuesList
    )

import SHACL.Internal.CoreFunctions exposing (..)
import SHACL.Internal.CoreTypes exposing (..)

import Rdf.Core.Types
    exposing
        ( PredicateTerm(..)
        , Quad
        , RDFnonLiteralTerm(..)
        , RDFterm(..)
        )
import SHACL.SHACLtypes exposing (..)


-- qudt:NumericTypeUnion
--   a rdf:List ;
--   dcterms:description """
--   An rdf:List that can be used in property constraints as value for sh:or to indicate that all values
--    of a property must be a string, an integer, a float, a double or a decimal.
--   """ ;
--   rdf:first [
--       sh:datatype xsd:string ;
--     ] ;
--   rdf:rest (
--       [
--         sh:datatype xsd:nonNegativeInteger ;
--       ]
--       [
--         sh:datatype xsd:positiveInteger ;
--       ]
--       [
--         sh:datatype xsd:integer ;
--       ]
--       [
--         sh:datatype xsd:int ;
--       ]
--       [
--         sh:datatype xsd:float ;
--       ]
--       [
--         sh:datatype xsd:double ;
--       ]
--       [
--         sh:datatype xsd:decimal ;
--       ]
--     ) ;
--   rdfs:isDefinedBy <http://qudt.org/3.1.3/schema/shacl/qudt> ;
--   rdfs:label "Numeric Type Union" ;
-- .
-- qudt:Quantifiable-value
--   a sh:PropertyShape ;
--   sh:path qudt:value ;
--   rdfs:isDefinedBy <http://qudt.org/3.1.3/schema/shacl/qudt> ;
--   sh:maxCount 1 ;
--   sh:node (
--       [
--         sh:or qudt:NumericTypeUnion ;
--       ]
--       [
--         sh:property [
--             sh:path qudt:value ;
--             sh:class qudt:DataItem ;
--           ] ;
--       ]
--       [
--         sh:property [
--             sh:path qudt:value ;
--             sh:class qudt:EnumeratedValue ;
--           ] ;
--       ]
--     ) ;
-- .


buildBlankNodes : RDFnonLiteralTerm -> List Quad -> BlankNodeRecord
buildBlankNodes blankNode quads =
    let
        termId =
            nonLiteralToString blankNode

        referencedBy : List ( RDFnonLiteralTerm, PredicateTerm )
        referencedBy =
            subjectPredicatesForGivenObject blankNode quads
    in
    { id = termId
    , fields = statementsForGivenSubject blankNode quads
    , referencedBy = referencedBy
    , derivedFrom = Just (NonLiteral blankNode)
    }


-- TODO: finish this


buildValuesList : RDFnonLiteralTerm -> List Quad -> ValuesList
buildValuesList subject quads =
    let
        listElementQuad : Maybe Quad
        listElementQuad =
            subjectPredicateQuad subject (PredicateNamedNode "rdf:first") quads

        -- _ =
        --     Debug.log "buildValuesList" listElementQuad
        rdfList : Quad -> List String -> List String
        rdfList listElement listSoFar =
            let
                first : Maybe RDFterm
                first =
                    objectsForGivenSubjectPredicate listElement.subject "rdf:first" quads
                        |> List.head

                rest : Maybe RDFterm
                rest =
                    objectsForGivenSubjectPredicate listElement.subject "rdf:rest" quads
                        |> List.head

                elementQuads : RDFnonLiteralTerm -> List RDFterm
                elementQuads resource =
                    getResourceQuads resource quads
                        |> List.map
                            (\quad -> quad.object)
            in
            case first of
                Just (NonLiteral (BlankNode first_)) ->
                    let
                        newValue =
                            Debug.toString <| elementQuads (BlankNode first_)

                        newList =
                            newValue :: listSoFar
                    in
                    case rest of
                        Just (NonLiteral rest_) ->
                            let
                                restQuad =
                                    subjectPredicateQuad
                                        rest_
                                        (PredicateNamedNode "rdf:first")
                                        quads
                            in
                            case restQuad of
                                Just restQuad_ ->
                                    rdfList restQuad_ newList

                                Nothing ->
                                    newList

                        Just _ ->
                            newList

                        Nothing ->
                            newList

                Just _ ->
                    listSoFar

                Nothing ->
                    listSoFar
    in
    { id = nonLiteralToString subject
    , values =
        case listElementQuad of
            Just listElementQuad_ ->
                rdfList listElementQuad_ []

            Nothing ->
                []
    , derivedFrom = Just (NonLiteral subject)
    }
