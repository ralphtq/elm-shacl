module SHACL.AST.Builder.Constraints.ShapeBasedConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


nodeConstraintText : MarkdownString
nodeConstraintText =
    """
Let **$node** be a value of sh:node.
For each value node v: A failure MUST be produced if the conformance checking of v
 against **$node** produces a failure. 
Otherwise, if v does not conform to $node, there is a validation result with v as sh:value.
"""


propertyConstraintText : MarkdownString
propertyConstraintText =
    """
Let **$property** be a value of sh:property.
For each value node v: A failure MUST be produced if the validation of v as focus node
 against the property shape **$property** produces a failure. 
Otherwise, the validation results are the results of validating v as focus node against
 the property shape $property.
"""


qualifiedMinCountConstraintText : MarkdownString
qualifiedMinCountConstraintText =
    """
Let **$qualifiedValueShape** be a value of sh:qualifiedValueShape. 
Let **$qualifiedMinCount** be a parameter value for sh:qualifiedMinCount. 
Let C be the number of value nodes v where v conforms to **$qualifiedValueShape** and
 where v does not conform to any of the sibling shapes for the current shape, i.e. the
 shape that v is validated against and which has **$qualifiedValueShape** as its value
 for sh:qualifiedValueShape. 
A failure MUST be produced if any of the said conformance checks produces a failure. 
Otherwise, there is a validation result if C is less than $qualifiedMinCount. 
The constraint component for sh:qualifiedMinCount is sh:QualifiedMinCountConstraintComponent.
"""


qualifiedMaxCountConstraintText : MarkdownString
qualifiedMaxCountConstraintText =
    """
Let **$qualifiedMaxCount** be a parameter value for sh:qualifiedMaxCount. 
Let C be as defined for sh:qualifiedMinCount above. 
A failure MUST be produced if any of the said conformance checks produces a failure. 
Otherwise, there is a validation result if C is greater than $qualifiedMaxCount. 
The constraint component for sh:qualifiedMaxCount is sh:QualifiedMaxCountConstraintComponent.
"""


reifierShapeConstraintText : MarkdownString
reifierShapeConstraintText =
    """
Let t be the triple term (focus node, $path, value node).
For each reifier for the triple term t, a failure MUST be produced if validating the
 reifier against the node shape **$reifierShape** with the reifier as focus node produces
 a failure.
For each reifier t that does not conform to $reifierShape, there is a validation result
 with t as sh:value.
"""


reificationRequiredConstraintText : MarkdownString
reificationRequiredConstraintText =
    """
 If **$reificationRequired** is set to true and there is no reified statement for the
  triple term t in the data graph, there is a validation result with t as sh:value.
"""


nodeByExpressionConstraintText : MarkdownString
nodeByExpressionConstraintText =
    """
Let **$expr** be a value of sh:nodeByExpression.
For each value node v: perform a conformance check of v against each output node of
 evalExpr(expr, data graph, v, {}) s. 
A failure MUST be produced if the conformance check of v against s produces a failure. 
Otherwise, if v does not conform to s, there is a validation result with v as sh:value
 and a deep copy of s as sh:sourceConstraint.
"""


shapeBasedConstraintMappings : Dict PropertyId ConstraintComponent
shapeBasedConstraintMappings =
    Dict.empty
