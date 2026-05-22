module SHACL.AST.Builder.PropertyGroupsDictionary exposing (..)

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
--     |> List.filterMap .group
-- |> List.map
--     (\( pgName, maybeOrder ) ->
--         ( pgName
--         , maybeOrder
--         )
--     )
-- |> Dict.fromList


buildPropertyGroup : RDFnonLiteralTerm -> List Quad -> PropertyGroup
buildPropertyGroup propertyGroup quads =
    { propertyGroupId = nonLiteralToString propertyGroup
    , label = Nothing
    , order = Just 0
    , derivedFrom = Just (NonLiteral propertyGroup)
    }
