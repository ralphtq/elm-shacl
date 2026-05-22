module SHACL.AST.Builder.Constraints.SHACLpredicates exposing (shaclPredicates)

import SHACL.Internal.CoreTypes exposing (TermId)


shaclPredicates : List TermId
shaclPredicates =
    [ "sh:alternativePath"
    , "sh:and"
    , "sh:declare"
    , "sh:class"
    , "sh:datatype"
    , "sh:entailment"
    , "sh:group"
    , "sh:ignoredProperties"
    , "sh:languageIn"
    , "sh:in"
    , "sh:node"
    , "sh:not"
    , "sh:or"
    , "sh:property"
    , "sh:sparql"
    , "sh:targetSubjectsOf"
    , "sh:values"
    , "sh:xone"
    ]
