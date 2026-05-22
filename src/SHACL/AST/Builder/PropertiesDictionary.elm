module SHACL.AST.Builder.PropertiesDictionary exposing (..)

import SHACL.Internal.CoreFunctions exposing (..)
import SHACL.Internal.CoreTypes exposing (..)

-- import Shared.Msg exposing (Msg(..))

import Rdf.Core.Types
    exposing
        ( Quad
        , RDFnonLiteralTerm
        , RDFterm(..)
        )
import SHACL.SHACLtypes exposing (..)


-- TOFIX
-- applicablePropertyShapes classIds quads
--     |> Dict.values
--     |> List.filterMap .property
--     |> List.map
--         (\propertyAsTermId ->
--             ( propertyAsTermId
--             , statementsForGivenSubject (NamedNode propertyAsTermId) quads
--                 |> List.map
--                     (\( predicate, object ) ->
--                         ( predicateToString predicate, object )
--                     )
--             )
--         )
--     |> List.map
--         (\( propertyAsTermId, propertyStatements ) ->
--             ( propertyAsTermId
--             , buildProperty propertyAsTermId (Dict.fromList propertyStatements)
--             )
--         )
--     |> Dict.fromList


buildProperty : RDFnonLiteralTerm -> List Quad -> Property
buildProperty property quads =
    { propertyId = nonLiteralToString property
    , type_ = "TBD"
    , label = Nothing
    , description = Nothing
    , derivedFrom = Just (NonLiteral property)
    }
