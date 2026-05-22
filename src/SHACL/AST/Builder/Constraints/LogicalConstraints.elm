module SHACL.AST.Builder.Constraints.LogicalConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import Rdf.Core.Types
    exposing
        ( Quad
        )
import SHACL.SHACLtypes exposing (..)


notConstraintText : MarkdownString
notConstraintText =
    """
**sh:not** specifies the condition that each value node cannot conform to a given shape. 
This is comparable to negation and the logical "not" operator.

The values of sh:not in a shape must be well-formed shapes.

Let **$not** be a value of sh:not.
For each value node v: A failure MUST be reported if the conformance checking of v against
 the shape **$not** produces a failure. Otherwise, if v conforms to the shape $not,
 there is validation result with v as sh:value.
"""


andConstraintText : MarkdownString
andConstraintText =
    """
**sh:and** specifies the condition that each value node conforms to all provided shapes. 
This is comparable to conjunction and the logical "and" operator.

**sh:and** defines a SHACL list of shapes to validate the value nodes against. 
Each value of **sh:and** in a shape is a SHACL list. 
Each member of such list must be a well-formed shape.

Let **$and** be a value of sh:and.
For each value node v: A failure MUST be produced if the conformance checking of v
 against any of the members of **$and** produces a failure. 
Otherwise, if v does not conform to each member of $and, there is a validation result
 with v as sh:value.
"""


orConstraintText : MarkdownString
orConstraintText =
    """
 Let **$or** be a value of sh:or.
 For each value node v: A failure MUST be produced if the conformance checking of v
  against any of the members produces a failure. 
Otherwise, if v conforms to none of the members of **$or** there is a validation result
 with v as sh:value.
"""


xoneConstraintText : MarkdownString
xoneConstraintText =
    """
**sh:xone ** specifies the condition that each value node conforms to exactly one of the
 provided shapes.

A SHACL list of shapes to validate the value nodes against. 
Each value of **sh:xone ** in a shape is a SHACL list. 
Each member of such list must be a well-formed shape.

Let **$xone** be a value of **sh:xone **.
For each value node v let N be the number of the shapes that are members of **$xone**
 where v conforms to the shape. 
A failure MUST be produced if the conformance checking of v against any of the members produces a failure. 
Otherwise, if N is not exactly 1, there is a validation result with v as sh:value.
"""


logicalConstraintMappings : Dict PropertyId ConstraintComponent
logicalConstraintMappings =
    [ ( "sh:not"
      , { property = "sh:not"
        , description = notConstraintText
        , allowedOnNodeShape = True
        , constraintType = LogicalConstraintType
        , valueType = NonLiteralValueType ShapeNonLiteral
        , many = False
        , validator = ConstraintValidator validateNotConstraint
        , transformer = ConstraintTransformer constructNotConstraint
        }
      )
    , ( "sh:and"
      , { property = "sh:and"
        , description = andConstraintText
        , allowedOnNodeShape = True
        , constraintType = LogicalConstraintType
        , valueType = NonLiteralValueType ShapeNonLiteral
        , many = True
        , validator = ConstraintValidator validateAndConstraint
        , transformer = ConstraintTransformer constructAndConstraint
        }
      )
    , ( "sh:or"
      , { property = "sh:or"
        , description = orConstraintText
        , allowedOnNodeShape = True
        , constraintType = LogicalConstraintType
        , valueType = NonLiteralValueType ShapeNonLiteral
        , many = True
        , validator = ConstraintValidator validateOrConstraint
        , transformer = ConstraintTransformer constructOrConstraint
        }
      )
    , ( "sh:xone"
      , { property = "sh:xone"
        , description = xoneConstraintText
        , allowedOnNodeShape = True
        , constraintType = LogicalConstraintType
        , valueType = NonLiteralValueType ShapeNonLiteral
        , many = True
        , validator = ConstraintValidator validateXoneConstraint
        , transformer = ConstraintTransformer constructXoneConstraint
        }
      )
    ]
        |> Dict.fromList


constructNotConstraint : TermId -> ConstraintComponent -> List Quad -> Result String ShapeConstraint
constructNotConstraint constraintId component quads =
    let
        shapes : List Shape
        shapes =
            []
    in
    Ok (NotConstraint shapes)


validateNotConstraint : TermId -> ConstraintComponent -> List Quad -> Result String Bool
validateNotConstraint constraintId component quads =
    let
        result =
            Ok True
    in
    result


constructAndConstraint : TermId -> ConstraintComponent -> List Quad -> Result String ShapeConstraint
constructAndConstraint constraintId component quads =
    let
        shapes : List Shape
        shapes =
            []
    in
    Ok (AndConstraint shapes)


validateAndConstraint : TermId -> ConstraintComponent -> List Quad -> Result String Bool
validateAndConstraint constraintId component quads =
    let
        result =
            Ok True
    in
    result


constructOrConstraint : TermId -> ConstraintComponent -> List Quad -> Result String ShapeConstraint
constructOrConstraint constraintId component quads =
    let
        shapes : List Shape
        shapes =
            []
    in
    Ok (OrConstraint shapes)


validateOrConstraint : TermId -> ConstraintComponent -> List Quad -> Result String Bool
validateOrConstraint constraintId component quads =
    let
        result =
            Ok True
    in
    result


constructXoneConstraint : TermId -> ConstraintComponent -> List Quad -> Result String ShapeConstraint
constructXoneConstraint constraintId component quads =
    let
        shapes : List Shape
        shapes =
            []
    in
    Ok (XoneConstraint shapes)


validateXoneConstraint : TermId -> ConstraintComponent -> List Quad -> Result String Bool
validateXoneConstraint constraintId component quads =
    let
        result =
            Ok True
    in
    result
