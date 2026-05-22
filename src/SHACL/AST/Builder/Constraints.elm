module SHACL.AST.Builder.Constraints exposing
    ( buildClassConstraint
    , buildDatatypeConstraint
    , buildGroupConstraint
    , buildHasValueConstraint
    , buildLessThanConstraint
    , buildLessThanOrEqualsConstraint
    , buildMaxCountConstraint
    , buildMaxInclusiveConstraint
    , buildMaxLengthConstraint
    , buildMinCountConstraint
    , buildMinInclusiveConstraint
    , buildMinLengthConstraint
    , buildNameConstraint
    , buildOrderConstraint
    , buildPatternConstraint
    , buildPropertyShapeConstraints
    , buildQualifiedMaxCountConstraint
    , buildQualifiedMinCountConstraint
    , buildShapeConstraint
    , buildUniqueLangConstraint
    , buildValuesConstraint
    )

{-| Builders that turn SHACL constraint quads into typed
`ShapeConstraint` values for the AST.

WIP — most builders currently return placeholder values; full quad
inspection per constraint is the next iteration.


# Shape-level constraint dispatch

@docs buildShapeConstraint, buildPropertyShapeConstraints


# Per-constraint builders

@docs buildClassConstraint, buildDatatypeConstraint, buildGroupConstraint
@docs buildHasValueConstraint, buildLessThanConstraint, buildLessThanOrEqualsConstraint
@docs buildMaxCountConstraint, buildMaxInclusiveConstraint, buildMaxLengthConstraint
@docs buildMinCountConstraint, buildMinInclusiveConstraint, buildMinLengthConstraint
@docs buildNameConstraint, buildOrderConstraint, buildPatternConstraint
@docs buildQualifiedMaxCountConstraint, buildQualifiedMinCountConstraint
@docs buildUniqueLangConstraint, buildValuesConstraint

-}

import Dict exposing (Dict)
import Rdf.Core.Types
    exposing
        ( Quad
        , RDFnonLiteralTerm(..)
        )
import SHACL.Internal.CoreFunctions
    exposing
        ( nonLiteralToString
        , objectsForGivenSubjectPredicate
        , predicateToString
        )
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


{-| Build a single shape-level constraint from its constraint id and
quads. WIP — currently returns `UnresolvedConstraint` for everything.
-}
buildShapeConstraint : RDFnonLiteralTerm -> List Quad -> ( TermId, ShapeConstraint )
buildShapeConstraint constraintId quads =
    let
        id : TermId
        id =
            nonLiteralToString constraintId
    in
    ( id, UnresolvedConstraint ("TODO: " ++ id) )


{-| Dispatch each predicate in the property shape's quads to the
appropriate constraint builder, returning the list of typed
`ShapeConstraint` values.
-}
buildPropertyShapeConstraints : PropertyShapeId -> List Quad -> List Quad -> List ShapeConstraint
buildPropertyShapeConstraints propertyShapeId shapeQuads quads =
    let
        constraintPredicateFunctions : Dict TermId (PropertyShapeId -> List Quad -> ShapeConstraint)
        constraintPredicateFunctions =
            [ ( "sh:class", buildClassConstraint )
            , ( "sh:datatype", buildDatatypeConstraint )

            -- , ( "sh:declare" , ...)
            , ( "sh:hasValue", buildHasValueConstraint )
            , ( "sh:group", buildGroupConstraint )
            , ( "sh:lessThan", buildLessThanConstraint )
            , ( "sh:lessThanOrEquals", buildLessThanOrEqualsConstraint )
            , ( "sh:maxCount", buildMaxCountConstraint )
            , ( "sh:maxInclusive", buildMaxInclusiveConstraint )
            , ( "sh:maxLength", buildMaxLengthConstraint )
            , ( "sh:minCount", buildMinCountConstraint )
            , ( "sh:minInclusive", buildMinInclusiveConstraint )
            , ( "sh:minLength", buildMinLengthConstraint )
            , ( "sh:name", buildNameConstraint )
            , ( "sh:order", buildOrderConstraint )
            , ( "sh:pattern", buildPatternConstraint )
            , ( "sh:qualifiedMaxCount", buildQualifiedMaxCountConstraint )
            , ( "sh:qualifiedMinCount", buildQualifiedMinCountConstraint )
            , ( "sh:uniqueLang", buildUniqueLangConstraint )
            , ( "sh:values", buildValuesConstraint )
            ]
                |> Dict.fromList

        constraints : List ShapeConstraint
        constraints =
            shapeQuads
                |> List.filterMap
                    (\shapeQuad ->
                        let
                            predicateAsTermId =
                                predicateToString shapeQuad.predicate
                        in
                        Dict.get predicateAsTermId constraintPredicateFunctions
                    )
                |> List.map (\fn -> fn propertyShapeId quads)

        -- _ =
        --     Debug.log ("buildPropertyShapeConstraints " ++ shapeId) constraints
    in
    constraints


{-| Build a `sh:pattern` constraint. WIP — placeholder.
-}
buildPatternConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildPatternConstraint propertyShapeId quads =
    "a string"
        |> PatternConstraint



-- buildPropertyComparisonConstraint : (PropertyId -> ShapeConstraint) -> List Quad -> ShapeConstraint
-- buildPropertyComparisonConstraint constraintFn propertyShapeId quads =
--     let
--         propertyId : PropertyId
--         propertyId =
--             ""
--     in
--     constraintFn propertyId


{-| Build a `sh:class` constraint. WIP — placeholder.
-}
buildClassConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildClassConstraint propertyShapeId quads =
    "aClass"
        |> ClassConstraint


{-| Build a `sh:datatype` constraint. WIP — placeholder.
-}
buildDatatypeConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildDatatypeConstraint propertyShapeId quads =
    let
        dataTypeId : DataTypeId
        dataTypeId =
            "a string"
    in
    dataTypeId
        |> DatatypeConstraint


{-| Build a `sh:group` constraint. WIP — placeholder.
-}
buildGroupConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildGroupConstraint propertyShapeId quads =
    let
        anId =
            "anId"
    in
    GroupConstraint anId


{-| Build a `sh:hasValue` constraint. WIP — placeholder.
-}
buildHasValueConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildHasValueConstraint propertyShapeId quads =
    let
        value : ValueUnion
        value =
            NoValue
    in
    value
        |> HasValueConstraint


{-| Build a `sh:lessThan` constraint. WIP — placeholder.
-}
buildLessThanConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildLessThanConstraint propertyShapeId quads =
    "propertyId"
        |> LessThanConstraint


{-| Build a `sh:lessThanOrEquals` constraint. WIP — placeholder.
-}
buildLessThanOrEqualsConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildLessThanOrEqualsConstraint propertyShapeId quads =
    "propertyId"
        |> LessThanOrEqualsConstraint


{-| Build a `sh:maxCount` constraint from the value-count of the
relevant quads.
-}
buildMaxCountConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMaxCountConstraint propertyShapeId quads =
    objectsForGivenSubjectPredicate (NamedNode propertyShapeId) "sh:minCount" quads
        |> List.length
        |> MaxCountConstraint


{-| Build a `sh:maxInclusive` constraint. WIP — placeholder integer.
-}
buildMaxInclusiveConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMaxInclusiveConstraint propertyShapeId quads =
    let
        numericUnion : NumericUnion
        numericUnion =
            IntValue 999
    in
    numericUnion
        |> MaxInclusiveConstraint


{-| Build a `sh:maxLength` constraint. WIP — placeholder integer.
-}
buildMaxLengthConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMaxLengthConstraint propertyShapeId quads =
    901
        |> MaxLengthConstraint


{-| Build a `sh:minCount` constraint from the value-count of the
relevant quads.
-}
buildMinCountConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMinCountConstraint propertyShapeId quads =
    objectsForGivenSubjectPredicate (NamedNode propertyShapeId) "sh:minCount" quads
        |> List.length
        -- TODO: finish this - just wanted an integer
        |> MinCountConstraint


{-| Build a `sh:minInclusive` constraint. WIP — placeholder integer.
-}
buildMinInclusiveConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMinInclusiveConstraint propertyShapeId quads =
    let
        numericUnion : NumericUnion
        numericUnion =
            IntValue 902
    in
    numericUnion
        |> MinInclusiveConstraint


{-| Build a `sh:minLength` constraint. WIP — placeholder integer.
-}
buildMinLengthConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMinLengthConstraint propertyShapeId length =
    903
        |> MinLengthConstraint


{-| Build a `sh:name` constraint. WIP — placeholder.
-}
buildNameConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildNameConstraint propertyShapeId quads =
    "aString"
        |> NameConstraint


{-| Build a `sh:order` constraint. WIP — placeholder integer.
-}
buildOrderConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildOrderConstraint propertyShapeId quads =
    let
        numericUnion : NumericUnion
        numericUnion =
            IntValue 999
    in
    numericUnion
        |> OrderConstraint


{-| Build a `sh:qualifiedMaxCount` constraint. WIP — placeholder integer.
-}
buildQualifiedMaxCountConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildQualifiedMaxCountConstraint propertyShapeId quads =
    904
        |> QualifiedMaxCountConstraint


{-| Build a `sh:qualifiedMinCount` constraint. WIP — placeholder integer.
-}
buildQualifiedMinCountConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildQualifiedMinCountConstraint propertyShapeId quads =
    905
        |> QualifiedMinCountConstraint


{-| Build a `sh:uniqueLang` constraint. WIP — placeholder.
-}
buildUniqueLangConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildUniqueLangConstraint propertyShapeId quads =
    True
        |> UniqueLangConstraint


{-| Build a `sh:values` constraint. WIP — placeholder empty list.
-}
buildValuesConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildValuesConstraint propertyShapeId quads =
    []
        |> ValuesConstraint



-- buildConstraintsFromQuads : TermId -> TermId -> List Quad -> List RDFterm
-- buildConstraintsFromQuads subjectId predicateId propertyShapeId quads =
--     let
--         subject : RDFnonLiteralTerm
--         subject =
--             NamedNode subjectId
--         minValue =
--             case predicateId of
--                 "sh:minValue" ->
--                     objectsForGivenSubjectPredicate subject predicateId quads
--                         |> (\objects ->
--                                 case objects of
--                                     [ Literal o ] ->
--                                         String.toInt (literalToString o)
--                                             |> MaybeX.unwrap 0 identity
--                                             |> MinCountValue
--                                     _ -> False
--                                         MinCountValue 0
--                            )
--                 _ ->
--                     MinCountValue 0
--     in
--     []
-- buildShapeConstraints : ShapeId -> List Quad -> List Quad -> List ShapeConstraint
-- buildShapeConstraints shapeId shapeQuads graphQuads =
--     let
--         constraintPredicateFunctions : Dict TermId (List Quad -> ShapeConstraint)
--         constraintPredicateFunctions =
--             [ ( "sh:and", buildAndConstraint )
--             , ( "sh:in", buildInConstraint )
--             , ( "sh:node", buildNodeConstraint )
--             , ( "sh:not", buildNotConstraint )
--             , ( "sh:or", buildOrConstraint )
--             , ( "sh:nodeKind", buildNodeKindConstraint )
--             , ( "sh:xone", buildXoneConstraint )
--             ]
--                 |> Dict.fromList
--         constraints : List ShapeConstraint
--         constraints =
--             shapeQuads
--                 |> List.filterMap
--                     (\shapeQuad ->
--                         let
--                             predicateAsTermId =
--                                 predicateToString shapeQuad.predicate
--                         in
--                         Dict.get predicateAsTermId constraintPredicateFunctions
--                     )
--                 |> List.map (\fn -> fn graphQuads)
--     in
--     []
