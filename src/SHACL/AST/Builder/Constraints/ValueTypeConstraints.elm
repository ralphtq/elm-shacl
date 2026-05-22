module SHACL.AST.Builder.Constraints.ValueTypeConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


classConstraintText : MarkdownString
classConstraintText =
    """
The condition specified by **sh:class** is that each value node is a SHACL instance of a given type.

The type of all value nodes. 
The values of **sh:class** in a shape are either IRIs or blank nodes that are well-formed SHACL lists where all members are IRIs.

Let **$class** be a parameter value for sh:class.
Let classes be a set of IRIs so that when **$class** is an IRI then the set only consists of exactly that IRI,
  and when **$class** is a blank node SHACL list then the set consists of exactly the members of the list.
 
 For each value node that is either a literal, or a non-literal that is not a SHACL instance of any of
  the classes in the data graph, there is a validation result with the value node as **sh:value**.

Reference: [https://www.w3.org/TR/shacl12-core/]9https://www.w3.org/TR/shacl12-core/)
"""


datatypeConstraintText : MarkdownString
datatypeConstraintText =
    """
sh:datatype specifies a condition to be satisfied with regards to the datatype of each value node.

The allowed datatype(s) of all value nodes (e.g., xsd:integer). 
A shape has at most one value for sh:datatype. 
The value of sh:datatype in a shape is either an IRI or a blank node that is a well-formed SHACL list where all members are IRIs.

Let **$datatype** be a parameter value for sh:datatype.
Let datatypes be a set of IRIs so that when **$datatype** is an IRI then the set only consists of exactly that IRI,
and when **$datatype** is a blank node SHACL list then the set consists of exactly the members of the list.

For each value node that is not a literal, or is a literal with a datatype that matches none of the datatypes,
there is a validation result with the value node as **sh:value**.

The datatype of a literal is determined following the datatype function of SPARQL 1.2.
A literal matches a datatype if the literal's datatype has the same IRI and,
for the datatypes supported by SPARQL 1.2, is not an ill-typed literal.
"""


nodeKindConstraintText : MarkdownString
nodeKindConstraintText =
    """
**sh:nodeKind **specifies a condition to be satisfied by the RDF node kind of each value node.
The node kind (IRI, blank node, literal or combinations of these) of all value nodes. 
The values of **sh:nodeKind** in a shape are one of the following six instances of the
 class sh:NodeKind: sh:BlankNode, sh:IRI, sh:Literal sh:BlankNodeOrIRI, sh:BlankNodeOrLiteral
 and sh:IRIOrLiteral. 
A shape has at most one value for **sh:nodeKind **.

Let **$nodeKind** be a parameter value for **sh:nodeKind **.
For each value node that does not match $nodeKind, there is a validation result with the value node as **sh:value**.
Any IRI matches only sh:IRI, sh:BlankNodeOrIRI and sh:IRIOrLiteral. Any blank node matches only sh:BlankNode, sh:BlankNodeOrIRI and sh:BlankNodeOrLiteral.
Any literal matches only sh:Literal, sh:BlankNodeOrLiteral and sh:IRIOrLiteral.
"""



{-
   shaclPropertyMappings
   ---------------------

   Mapppings of each shacl property to its constraint component type and value type

-}


valueTypeConstraintMappings : Dict PropertyId ConstraintComponent
valueTypeConstraintMappings =
    [ ( "sh:class"
      , { property = "sh:class"
        , description = classConstraintText
        , allowedOnNodeShape = False
        , constraintType = ValueTypeConstraintType
        , valueType = NonLiteralValueType IRI
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:datatype"
      , { property = "sh:datatype"
        , description = datatypeConstraintText
        , allowedOnNodeShape = False
        , constraintType = ValueTypeConstraintType
        , valueType = NonLiteralValueType XSDtype
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:nodeKind"
      , { property = "sh:nodeKind"
        , description = nodeKindConstraintText
        , allowedOnNodeShape = False
        , constraintType = ValueTypeConstraintType
        , valueType = NodeKindValueType NodeKind
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    ]
        |> Dict.fromList
