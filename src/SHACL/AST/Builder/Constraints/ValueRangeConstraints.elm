module SHACL.AST.Builder.Constraints.ValueRangeConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


maxExclusiveConstraintText : MarkdownString
maxExclusiveConstraintText =
    """
The maximum exclusive value. 
The values of **sh:maxExclusive** in a shape are literals. 
A shape has at most one value for sh:maxExclusive.

Let **$maxExclusive** be a parameter value for sh:maxExclusive.
For each value node v where the SPARQL expression **$maxExclusive** > v does not return true,
there is a validation result with v as sh:value.
"""


minExclusiveConstraintText : MarkdownString
minExclusiveConstraintText =
    """
The minimum exclusive value. 
The values of **sh:minExclusive** in a shape are literals. 
A shape has at most one value for sh:minExclusive.

Let **$minExclusive** be a parameter value for sh:minExclusive.
For each value node v where the SPARQL expression **$minExclusive** < v does not return true,
there is a validation result with v as sh:value.
"""


maxInclusiveConstraintText : MarkdownString
maxInclusiveConstraintText =
    """
The maximum inclusive value. 
The values of **sh:maxInclusive** in a shape are literals. 
A shape has at most one value for sh:maxInclusive.

Let **$maxInclusive** be a parameter value for sh:maxInclusive.
For each value node v where the SPARQL expression **$maxInclusive** >= v does not return true,
 there is a validation result with v as sh:value.
"""


minInclusiveConstraintText : MarkdownString
minInclusiveConstraintText =
    """
The minimum inclusive value. 
The values of **sh:minInclusive** in a shape are literals. 
A shape has at most one value for sh:minInclusive.

Let **$minInclusive** be a parameter value for sh:minInclusive.
For each value node v where the SPARQL expression **$minInclusive** <= v does not return
 true, there is a validation result with v as sh:value.
"""


valueRangeConstraintMappings : Dict PropertyId ConstraintComponent
valueRangeConstraintMappings =
    [ ( "sh:maxExclusive"
      , { property = "sh:maxExclusive"
        , description = maxExclusiveConstraintText
        , allowedOnNodeShape = False
        , constraintType = ValueRangeConstraintType
        , valueType = LiteralUnionValueType LiteralUnion
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:minExclusive"
      , { property = "sh:minExclusive"
        , description = minExclusiveConstraintText
        , allowedOnNodeShape = False
        , constraintType = ValueRangeConstraintType
        , valueType = LiteralUnionValueType LiteralUnion
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:maxInclusive"
      , { property = "sh:maxInclusive"
        , description = maxInclusiveConstraintText
        , allowedOnNodeShape = False
        , constraintType = ValueRangeConstraintType
        , valueType = LiteralUnionValueType LiteralUnion
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:minInclusive"
      , { property = "sh:minInclusive"
        , description = minInclusiveConstraintText
        , allowedOnNodeShape = False
        , constraintType = ValueRangeConstraintType
        , valueType = LiteralUnionValueType LiteralUnion
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    ]
        |> Dict.fromList
