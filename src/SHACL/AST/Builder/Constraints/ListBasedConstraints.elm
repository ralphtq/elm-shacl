module SHACL.AST.Builder.Constraints.ListBasedConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


memberShapeConstraintText : MarkdownString
memberShapeConstraintText =
    """
 Let **$memberShape** be a parameter value for sh:memberShape. 
 Each value node v must be a SHACL list - if v is not a SHACL list there is a validation result.
 If any member m of the SHACL list v does not conform to $memberShape, there is a validation result.
"""


minLengthConstraintText : MarkdownString
minLengthConstraintText =
    """
Let **$minLength** be a parameter value for sh:minLength.
For each value node v where the length (as defined by the SPARQL STRLEN function) of the
 string representation of v (as defined by the SPARQL str function) is less than $minLength,
 or where v is a blank node, there is a validation result with v as sh:value.
"""


maxLengthConstraintText : MarkdownString
maxLengthConstraintText =
    """
Let **$maxLength** be a parameter value for sh:maxLength.
For each value node v where the length (as defined by the SPARQL STRLEN function) of the
 string representation of v (as defined by the SPARQL str function) is greater than $maxLength,
 or where v is a blank node, there is a validation result with v as sh:value.
"""


uniqueMembersConstraintText : MarkdownString
uniqueMembersConstraintText =
    """
Let **$uniqueMembers** be a parameter value for sh:uniqueMembers.
Each value node v must be a SHACL list - if v is not a SHACL list there is a validation result.
If **$uniqueMembers** is true and the list v has duplicate members, there is a validation result.
"""


listConstraintMappings : Dict PropertyId ConstraintComponent
listConstraintMappings =
    [ ( "sh:memberShape"
      , { property = "sh:memberShape"
        , description = memberShapeConstraintText
        , allowedOnNodeShape = True
        , constraintType = ListConstraintType
        , valueType = LiteralValueType NodeShapeId
        , many = True
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:minListLength"
      , { property = "sh:minListLength"
        , description = memberShapeConstraintText
        , allowedOnNodeShape = True
        , constraintType = ListConstraintType
        , valueType = LiteralValueType (XSDvalue XSDinteger)
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:maxListLength"
      , { property = "sh:maxListLength"
        , description = memberShapeConstraintText
        , allowedOnNodeShape = True
        , constraintType = ListConstraintType
        , valueType = LiteralValueType (XSDvalue XSDinteger)
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:uniqueMembers"
      , { property = "sh:uniqueMembers"
        , description = memberShapeConstraintText
        , allowedOnNodeShape = True
        , constraintType = ListConstraintType
        , valueType = LiteralValueType (XSDvalue XSDboolean)
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    ]
        |> Dict.fromList
