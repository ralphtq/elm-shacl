module SHACL.AST.Builder.Constraints.OtherConstraints exposing (..)

import Dict exposing (Dict)
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


closedConstraintText : MarkdownString
closedConstraintText =
    """
Let **$closed** be a parameter value for sh:closed. 
Let **$ignoredProperties** be a value for **sh:ignoredProperties**.

If **$closed** is true or sh:ByTypes and P is the set of properties defined below, then
 there is a validation result for each triple that has a value node as its subject
 and a predicate that is not in P.

If **$ignoredProperties** has a value then the properties enumerated as members of this
 SHACL list are also permitted for the value node. 
The validation result MUST have the predicate of the triple as its sh:resultPath,
 and the object of the triple as its sh:value.

If **$closed** is true, then P is the set of IRI properties that can be reached from the
 current shape via the SPARQL path sh:property/sh:path.

If **$closed** is sh:ByTypes, then P is the set of IRI properties that can be reached from
 the value node via the following algorithm, plus rdf:type:
      
      function collectProperties(S)
          add all IRI properties that can be reached from S via the SPARQL path
                  sh:property/sh:path
          if S is a SHACL instance of rdfs:Class in the shapes graph {
              for each triple in the shapes graph matching (S rdfs:subClassOf ?o)
                  collectProperties(?o)
              for each triple in the shapes graph matching (?s sh:targetClass S)
                  collectProperties(?s)
          }
          if S is a SHACL instance of sh:NodeShape in the shapes graph
              for each triple in the shapes graph matching (S sh:node ?o)
                  collectProperties(?o)

      for each rdf:type T of the value node in the data graph
          collectProperties(T)

Note that implementations need to avoid infinite loops in the algorithm above by preventing
 it from visiting the same S twice.  
"""


hasValueConstraintText : MarkdownString
hasValueConstraintText =
    """
Let **$hasValue** be a parameter value for sh:hasValue.
If the RDF term **$hasValue** is not among the value nodes, there is a validation result.
"""


inConstraintText : MarkdownString
inConstraintText =
    """
 Let **$in** be a value of sh:in.
 For each value node that is not a member of $in, there is a validation result with
  the value node as sh:value.

"""


expressionConstraintText : MarkdownString
expressionConstraintText =
    """
Let **$expr** be a value of sh:expression.
For each value node v where evalExpr(expr, data graph, v, {}) does not return the list
 consisting of exactly true as its output nodes, there is a validation result that has
 v as its sh:value and a deep copy of **$expr** in the results graph as its sh:sourceConstraint.
If the **$expr** has values for sh:message in the shapes graph, then these values become the
 (only) values for sh:resultMessage in the validation result.
"""


otherConstraintMappings : Dict PropertyId ConstraintComponent
otherConstraintMappings =
    Dict.empty
