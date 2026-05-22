module SHACL.AST.Builder.Constraints.StringBasedConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


minLengthConstraintText : MarkdownString
minLengthConstraintText =
    """
**sh:minLength** specifies the minimum string length of each value node that satisfies the condition. 
This can be applied to any literals and IRIs, but not to blank nodes.

The values of sh:minLength in a shape are literals with datatype xsd:integer. 
A shape has at most one value for sh:minLength.

For each value node v where the length (as defined by the SPARQL STRLEN function) of the 
string representation of v (as defined by the SPARQL str function) is less than $minLength,
 or where v is a blank node, there is a validation result with v as sh:value.
"""


maxLengthConstraintText : MarkdownString
maxLengthConstraintText =
    """
**sh:maxLength** specifies the maximum string length of each value node that satisfies the condition. 
This can be applied to any literals and IRIs, but not to blank nodes.

The values of sh:maxLength in a shape are literals with datatype xsd:integer. 
A shape has at most one value for sh:maxLength.

For each value node v where the length (as defined by the SPARQL STRLEN function) of the 
string representation of v (as defined by the SPARQL str function) is less than $maxLength,
 or where v is a blank node, there is a validation result with v as sh:value.
"""


patternConstraintText : MarkdownString
patternConstraintText =
    """
Let **$pattern** be a parameter value for sh:pattern.
Let **$flags** be a parameter value for sh:flags.
For each value node that is a blank node or where the string representation (as defined by the
SPARQL str function) does not match the regular expression **$pattern** (as defined by the SPARQL REGEX function),
there is a validation result with the value node as sh:value.
If **$flags** has a value then the matching MUST follow the definition of the 3-argument variant of the
SPARQL REGEX function, using **$flags** as third argument.
"""


singleLineConstraintText : MarkdownString
singleLineConstraintText =
    """
Let **$singleLine** be a parameter value for sh:singleLine.
If **$singleLine** is true, then, for each value node that is a literal where the lexical
form matches the regular expression (as defined by the SPARQL REGEX function)
[\\f\\r\\n\\v], there is a validation result.
"""


languageInConstraintText : MarkdownString
languageInConstraintText =
    """
Let **$languageIn** be a value of sh:languageIn.
For each value node that is either not a literal or that does not have a language tag
matching any of the basic language ranges that are the members of **$languageIn** following
the filtering schema defined by the SPARQL langMatches function, there is a validation
result with the value node as sh:value.
"""


uniqueLangConstraintText : MarkdownString
uniqueLangConstraintText =
    """
Let **$uniqueLang** be a parameter value for sh:uniqueLang.
If **$uniqueLang** is true then for each non-empty language tag that is used by at least
 two value nodes, there is a validation result.
 """


stringBasedConstraintMappings : Dict PropertyId ConstraintComponent
stringBasedConstraintMappings =
    [ ( "sh:minListLength"
      , { property = "sh:minListLength"
        , description = minLengthConstraintText
        , allowedOnNodeShape = False
        , constraintType = StringBasedConstraintType
        , valueType = LiteralValueType (XSDvalue XSDinteger)
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:maxListLength"
      , { property = "sh:maxListLength"
        , description = maxLengthConstraintText
        , allowedOnNodeShape = False
        , constraintType = StringBasedConstraintType
        , valueType = LiteralValueType (XSDvalue XSDinteger)
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:pattern"
      , { property = "sh:pattern"
        , description = maxLengthConstraintText
        , allowedOnNodeShape = False
        , constraintType = StringBasedConstraintType
        , valueType = LiteralValueType (XSDvalue XSDinteger)
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:languageIn"
      , { property = "sh:languageIn"
        , description =
            maxLengthConstraintText
        , allowedOnNodeShape = False
        , constraintType = StringBasedConstraintType
        , valueType = LiteralValueType (XSDvalue XSDinteger)
        , many = True
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    , ( "sh:uniqueLang"
      , { property = "sh:uniqueLang"
        , description = maxLengthConstraintText
        , allowedOnNodeShape = False
        , constraintType = StringBasedConstraintType
        , valueType = LiteralValueType (XSDvalue XSDboolean)
        , many = False
        , validator = ConstraintValidatorTBD
        , transformer = ConstraintTransformerTBD
        }
      )
    ]
        |> Dict.fromList
