module SHACL.AST.Builder.InstancesDictionary exposing (..)

import SHACL.Internal.CoreFunctions exposing (..)
import SHACL.Internal.CoreTypes exposing (..)

import Rdf.Core.Types
    exposing
        ( NamedNodeId(..)
        , Quad
        , QuadStatement
        , RDFliteralTerm(..)
        , RDFnonLiteralTerm(..)
        , RDFterm(..)
        )
import SHACL.AST.Builder.Helpers exposing (..)
import SHACL.SHACLtypes
    exposing
        ( Instance
        , ValueUnion(..)
        )


{-
   An instance is a subject that has an rdf:type that is:
    (a) not an rdfs:Class or any of it's subclasses, or
    (b) an rdf:Property or its sub-properties.

   Uses QuadIds in order to use list functions such as "invertClassInstancesList"
-}


buildInstance : RDFnonLiteralTerm -> List Quad -> Instance
buildInstance instance quads =
    let
        instanceId =
            nonLiteralToString instance

        focusGraphQuads : List Quad
        focusGraphQuads =
            getResourceQuads instance quads

        -- _ =
        --     Debug.log "buildInstance" focusGraphQuads
        quadStatements : List QuadStatement
        quadStatements =
            quadsToQuadStatements focusGraphQuads

        predicateValues : List RDFterm -> List ValueUnion
        predicateValues values =
            values
                |> List.map
                    (\v ->
                        case v of
                            NonLiteral nonLiteral ->
                                case nonLiteral of
                                    NamedNode id ->
                                        NamedNodeValue (IRIid id)

                                    BlankNode bn ->
                                        BlankNodeValue bn

                            Literal literal ->
                                -- TODO: More transformations
                                case literal of
                                    LiteralString string maybeLang ->
                                        StringValue (TextValue string maybeLang)

                                    LiteralDataType _ maybeDataType ->
                                        StringValue (TextValue (Debug.toString maybeDataType) Nothing)

                            _ ->
                                StringValue (TextValue ("TODO - Others: " ++ Debug.toString v) Nothing)
                    )

        -- propertyValues : PropertyValues
        propertyValues =
            quadStatements
                |> List.map
                    (\qs ->
                        -- let
                        --     _ =
                        --         Debug.log ("buildInstance for: " ++ Debug.toString qs.subject) qs.predicate
                        -- in
                        { property = predicateToId qs.predicate
                        , values = predicateValues qs.objects
                        }
                    )

        shaclInstance : Instance
        shaclInstance =
            { id = instanceId
            , name = preferredLabel englishLang instance focusGraphQuads
            , altNames = Nothing
            , description = preferredDescription instance focusGraphQuads
            , typeList = []
            , properties = propertyValues
            , derivedFrom = Just (NonLiteral instance)
            }
    in
    shaclInstance
