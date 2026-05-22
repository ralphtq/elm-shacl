module SHACL.AST.Builder.Constraints.CardinalityConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import Rdf.Core.Types
    exposing
        ( Quad
        )
import SHACL.SHACLtypes exposing (..)



{-
   sh:MinCountConstraintComponent
   ------------------------------
   Let **$minCount** be a parameter value for sh:minCount.
   If the number of value nodes is less than $minCount, there is a validation result.

   sh:MaxCountConstraintComponent
   ------------------------------
   Let **$maxCount** be a parameter value for sh:maxCount.
   If the number of value nodes is greater than $maxCount, there is a validation result.
-}


minCountText : MarkdownString
minCountText =
    """The minimum cardinality. 
 Node shapes cannot have any value for sh:minCount.
 A property shape has at most one value for sh:minCount.
 The values of sh:minCount in a property shape are literals with datatype xsd:integer.
"""


maxCountText : MarkdownString
maxCountText =
    """The maximum cardinality. 
 Node shapes cannot have any value for sh:maxCount. 
 A property shape has at most one value for sh:maxCount. 
 The values of sh:maxCount in a property shape are literals with datatype xsd:integer.
"""


cardinalityConstraintMappings : Dict PropertyId ConstraintComponent
cardinalityConstraintMappings =
    [ ( "sh:maxCount"
      , { property = "sh:maxCount"
        , description = maxCountText
        , allowedOnNodeShape = False
        , constraintType = CardinalityConstraintType
        , valueType = LiteralValueType (XSDvalue XSDinteger)
        , many = False
        , validator = ConstraintValidator validateMaxCountConstraint
        , transformer = ConstraintTransformer constructMaxCountConstraint
        }
      )
    , ( "sh:minCount"
      , { property = "sh:minCount"
        , description = minCountText
        , allowedOnNodeShape = False
        , constraintType = CardinalityConstraintType
        , valueType = LiteralValueType (XSDvalue XSDinteger)
        , many = False
        , validator = ConstraintValidator validateMinCountConstraint
        , transformer = ConstraintTransformer constructMinCountConstraint
        }
      )
    ]
        |> Dict.fromList


constructMaxCountConstraint : TermId -> ConstraintComponent -> List Quad -> Result String ShapeConstraint
constructMaxCountConstraint constraintId component quads =
    let
        value =
            0
    in
    Ok (MaxCountConstraint value)


validateMaxCountConstraint : TermId -> ConstraintComponent -> List Quad -> Result String Bool
validateMaxCountConstraint constraintId component quads =
    let
        result =
            Ok True
    in
    result


constructMinCountConstraint : TermId -> ConstraintComponent -> List Quad -> Result String ShapeConstraint
constructMinCountConstraint constraintId component quads =
    let
        value =
            0
    in
    Ok (MinCountConstraint value)


validateMinCountConstraint : TermId -> ConstraintComponent -> List Quad -> Result String Bool
validateMinCountConstraint constraintId component quads =
    let
        result =
            Ok True
    in
    result
