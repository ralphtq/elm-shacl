module SHACL.AST.Builder.Constraints exposing (..)

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


buildShapeConstraint : RDFnonLiteralTerm -> List Quad -> ( TermId, ShapeConstraint )
buildShapeConstraint constraintId quads =
    let
        id : TermId
        id =
            nonLiteralToString constraintId
    in
    ( id, UnresolvedConstraint ("TODO: " ++ id) )


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


buildClassConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildClassConstraint propertyShapeId quads =
    "aClass"
        |> ClassConstraint


buildDatatypeConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildDatatypeConstraint propertyShapeId quads =
    let
        dataTypeId : DataTypeId
        dataTypeId =
            "a string"
    in
    dataTypeId
        |> DatatypeConstraint


buildGroupConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildGroupConstraint propertyShapeId quads =
    let
        anId =
            "anId"
    in
    GroupConstraint anId


buildHasValueConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildHasValueConstraint propertyShapeId quads =
    let
        value : ValueUnion
        value =
            NoValue
    in
    value
        |> HasValueConstraint


buildLessThanConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildLessThanConstraint propertyShapeId quads =
    "propertyId"
        |> LessThanConstraint


buildLessThanOrEqualsConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildLessThanOrEqualsConstraint propertyShapeId quads =
    "propertyId"
        |> LessThanOrEqualsConstraint


buildMaxCountConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMaxCountConstraint propertyShapeId quads =
    objectsForGivenSubjectPredicate (NamedNode propertyShapeId) "sh:minCount" quads
        |> List.length
        |> MaxCountConstraint


buildMaxInclusiveConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMaxInclusiveConstraint propertyShapeId quads =
    let
        numericUnion : NumericUnion
        numericUnion =
            IntValue 999
    in
    numericUnion
        |> MaxInclusiveConstraint


buildMaxLengthConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMaxLengthConstraint propertyShapeId quads =
    901
        |> MaxLengthConstraint


buildMinCountConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMinCountConstraint propertyShapeId quads =
    objectsForGivenSubjectPredicate (NamedNode propertyShapeId) "sh:minCount" quads
        |> List.length
        -- TODO: finish this - just wanted an integer
        |> MinCountConstraint


buildMinInclusiveConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMinInclusiveConstraint propertyShapeId quads =
    let
        numericUnion : NumericUnion
        numericUnion =
            IntValue 902
    in
    numericUnion
        |> MinInclusiveConstraint


buildMinLengthConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildMinLengthConstraint propertyShapeId length =
    903
        |> MinLengthConstraint


buildNameConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildNameConstraint propertyShapeId quads =
    "aString"
        |> NameConstraint


buildOrderConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildOrderConstraint propertyShapeId quads =
    let
        numericUnion : NumericUnion
        numericUnion =
            IntValue 999
    in
    numericUnion
        |> OrderConstraint


buildQualifiedMaxCountConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildQualifiedMaxCountConstraint propertyShapeId quads =
    904
        |> QualifiedMaxCountConstraint


buildQualifiedMinCountConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildQualifiedMinCountConstraint propertyShapeId quads =
    905
        |> QualifiedMinCountConstraint


buildUniqueLangConstraint : PropertyShapeId -> List Quad -> ShapeConstraint
buildUniqueLangConstraint propertyShapeId quads =
    True
        |> UniqueLangConstraint


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
