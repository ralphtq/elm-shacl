module SHACL.AST.Builder.Constraints.PropertyPairConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


equalsConstraintText : MarkdownString
equalsConstraintText =
    """
**sh:equals** specifies the condition that the set of all value nodes is equal to the set
 of objects of the triples that have the focus node as subject and the value of sh:equals
 as predicate.

Let **$equals** be a value of sh:equals.
For each value node that does not exist as a value of the property **$equals** at the
 focus node, there is a validation result with the value node as sh:value.
For each value of the property **$equals** at the focus node that is not one of the value
 nodes, there is a validation result with the value as sh:value.   
"""


disjointConstraintText : MarkdownString
disjointConstraintText =
    """
**sh:disjoint** specifies the condition that the set of value nodes is disjoint with
 the set of objects of the triples that have the focus node as subject and the value
  of sh:disjoint as predicate.

Let **$disjoint** be a parameter value of sh:disjoint.
For each value node that also exists as a value of the property **$disjoint** at the
 focus node, there is a validation result with the value node as sh:value.
"""


lessThanConstraintText : MarkdownString
lessThanConstraintText =
    """
**sh:lessThan** specifies the condition that each value node is smaller than all the objects of
 the triples that have the focus node as subject and the value of **sh:** as predicate.

Node shapes cannot have any value for sh:lessThan.

Let **$lessThan** be a value of **sh:lessThan**. 
For each pair of value nodes and the values of the property $lessThan at the given focus node
 where the first value is not less than the second value (based on SPARQL's < operator) or
 where the two values cannot be compared, there is a validation result with the value node
 as sh:value.
"""


lessThanOrEqualsConstraintText : MarkdownString
lessThanOrEqualsConstraintText =
    """
**sh:lessThanOrEquals** specifies the condition that each value node is smaller than or
 equal to all the objects of the triples that have the focus node as subject and the value
 of sh:lessThanOrEquals as predicate.

Node shapes cannot have any value for sh:lessThanOrEquals.

Let **$lessThanOrEquals** be a value of sh:lessThanOrEquals.
For each pair of value nodes and the values of the property **$lessThanOrEquals** at
 the given focus node where the first value is not less than or equal to the second
  value (based on SPARQL's <= operator) or where the two values cannot be compared,
  there is a validation result with the value node as sh:value.
"""


propertyPairConstraintMappings : Dict PropertyId ConstraintComponent
propertyPairConstraintMappings =
    [ ( "sh:equals"
      , { property = "sh:equals"
        , description = equalsConstraintText
        , allowedOnNodeShape = False
        , constraintType = PropertyPairConstraintType
        , valueType = NonLiteralValueType PropertyNonLiteral
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:disjoint"
      , { property = "sh:disjoint"
        , description = disjointConstraintText
        , allowedOnNodeShape = False
        , constraintType = PropertyPairConstraintType
        , valueType = NonLiteralValueType PropertyNonLiteral
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:lessThan"
      , { property = "sh:lessThan"
        , description = lessThanConstraintText
        , allowedOnNodeShape = False
        , constraintType = PropertyPairConstraintType
        , valueType = NonLiteralValueType PropertyNonLiteral
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:lessThanOrEquals"
      , { property = "sh:lessThanOrEquals"
        , description = lessThanOrEqualsConstraintText
        , allowedOnNodeShape = False
        , constraintType = PropertyPairConstraintType
        , valueType = NonLiteralValueType PropertyNonLiteral
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    ]
        |> Dict.fromList
