module SHACL.AST.Builder.ClassesDictionary exposing (..)

import SHACL.Internal.CoreFunctions exposing (..)
import SHACL.Internal.CoreTypes exposing (..)

import Rdf.Core.Types
    exposing
        ( ClassId
        , PredicateTerm(..)
        , Quad
        , RDFnonLiteralTerm(..)
        , RDFterm(..)
        )
import SHACL.AST.Builder.Helpers exposing (..)
import SHACL.SHACLtypes
    exposing
        ( Class
        , PropertyValues
        )


isNodeShape : TermId -> List Quad -> Bool
isNodeShape termId quads =
    subjectHasPredicateObject
        (NamedNode termId)
        (PredicateNamedNode "rdf:type")
        (NonLiteral (NamedNode "sh:NodeShape"))
        quads


buildClassPropertyValues : ClassId -> List Quad -> Maybe (List PropertyValues)
buildClassPropertyValues classId quads =
    Nothing


buildClassFromQuads : RDFnonLiteralTerm -> List Quad -> Class
buildClassFromQuads class quads =
    let
        classId : TermId
        classId =
            nonLiteralToString class

        metaClasses : List TermId
        metaClasses =
            nonLiteralObjectsForGivenSubjectPredicate class "rdf:type" quads
                |> List.map (\nonLiteral -> nonLiteralToString nonLiteral)

        superClasses : List TermId
        superClasses =
            nonLiteralObjectsForGivenSubjectPredicate class "rdfs:subClassOf" quads
                |> List.map (\nonLiteral -> nonLiteralToString nonLiteral)
    in
    { classId = classId
    , name = preferredLabel englishLang (NamedNode classId) quads
    , nodeShape =
        if isNodeShape classId quads then
            Just classId

        else
            Nothing
    , metaClasses = Just metaClasses
    , superClasses = Just superClasses
    , properties = buildClassPropertyValues classId quads
    , traits = Nothing
    }


-- buildClassesDictionaryV2 : List RDFnonLiteralTerm -> List Quad -> SHACLdictionary
-- buildClassesDictionaryV2 classes quads =
--     let
--         classesList : List ( ClassId, SHACLconstruct )
--         classesList =
--             classes
--                 |> List.map
--                     (\class ->
--                         getResourceQuads class quads
--                             |> buildClassFromQuads class
--                             |> SHACLclass
--                             |> Tuple.pair (nonLiteralToString class)
--                     )
--     in
--     Dict.fromList classesList
-- elaborateClassesDictionary : SHACLdictionary -> SHACLmodel -> SHACLdictionary
-- elaborateClassesDictionary shaclConstructDictionary shaclModel =
--     let
--         classes : List Class
--         classes =
--             Dict.values shaclConstructDictionary
--                 |> List.map
--                     (\construct ->
--                         case construct of
--                             SHACLclass class ->
--                                 Just class
--                             _ ->
--                                 Nothing
--                     )
--                 |> MaybeX.values
--     in
--     shaclConstructDictionary
