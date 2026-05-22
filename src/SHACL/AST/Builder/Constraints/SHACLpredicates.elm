module SHACL.AST.Builder.Constraints.SHACLpredicates exposing (shaclPredicates)

{-| The CURIE-form SHACL predicates the AST builder is aware of.

@docs shaclPredicates

-}

import SHACL.Internal.CoreTypes exposing (TermId)


{-| The list of recognised SHACL predicates in CURIE form (e.g.
`sh:and`, `sh:class`). Used by the builder to dispatch a quad's
predicate to the right constraint constructor.
-}
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
