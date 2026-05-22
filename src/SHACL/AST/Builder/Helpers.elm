module SHACL.AST.Builder.Helpers exposing (..)

import SHACL.Internal.CoreFunctions exposing (..)
import SHACL.Internal.CoreTypes exposing (..)

import Basics.Extra exposing (flip)
import SHACL.Internal.CoreTypes exposing (StringType(..))
import Rdf.Core.Types
    exposing
        ( DataType(..)
        , Quad
        , RDFliteralTerm(..)
        , RDFnonLiteralTerm
        , RDFterm(..)
        )


literalToStringType : List RDFterm -> Maybe StringType
literalToStringType rdfTerms =
    rdfTerms
        |> List.map
            (\rdfTerm ->
                case rdfTerm of
                    Literal (LiteralString value Nothing) ->
                        TextValue value Nothing

                    Literal (LiteralString value lang) ->
                        TextValue value lang

                    Literal (LiteralDataType value (Just (DataType "xsd:string"))) ->
                        TextValue value Nothing

                    Literal (LiteralDataType value (Just (DataType "rdf:HTML"))) ->
                        HTMLvalue value

                    Literal (LiteralDataType value (Just (DataType "qudt:LatexString"))) ->
                        LaTeXvalue value

                    _ ->
                        TextValue "TODO: something else" Nothing
            )
        |> (\valuesList ->
                case List.length valuesList of
                    0 ->
                        Just (TextValue "-" Nothing)

                    1 ->
                        List.head valuesList

                    _ ->
                        Debug.toString valuesList
                            |> flip TextValue Nothing
                            |> Just
            -- Just (TextValue ("TODO: Handle multiple values for: " ++ () Nothing))
           )


preferredLabel : Maybe LangString -> RDFnonLiteralTerm -> List Quad -> Maybe StringType
preferredLabel lang subject quads =
    objectsForGivenSubjectPredicate subject "rdfs:label" quads
        |> literalToStringType


preferredDescription : RDFnonLiteralTerm -> List Quad -> Maybe StringType
preferredDescription subject quads =
    let
        dctermsDescriptions : List RDFterm
        dctermsDescriptions =
            objectsForGivenSubjectPredicate subject "dcterms:description" quads

        rdfsComments : List RDFterm
        rdfsComments =
            objectsForGivenSubjectPredicate subject "rdfs:comment" quads
    in
    if List.isEmpty dctermsDescriptions then
        if List.isEmpty rdfsComments then
            Nothing

        else
            rdfsComments
                |> literalToStringType

    else
        dctermsDescriptions
            |> literalToStringType


-- liftSHACLmodel : Model -> SHACLmodel
-- liftSHACLmodel model =
--     model.sharedModel.shaclModels
--         |> Dict.get ""
--         |> Maybe.withDefault emptySHACLmodel
