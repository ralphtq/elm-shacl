module SHACL.SHACLtypes exposing
    ( BlankNodeRecord
    , Class
    , ConstraintComponent
    , ConstraintComponentType
    , ConstraintValidator(..)
    , DataTypeId
    , Instance
    , NodeShape
    , NumericUnion(..)
    , Property
    , PropertyGroup
    , PropertyShape
    , PropertyShapeId
    , PropertyShapeKind(..)
    , PropertyValues
    , SHACLconstruct(..)
    , SHACLdictionary
    , SHACLmodel
    , SHACLmodels
    , Shape
    , ShapeConstraint(..)
    , ShapeKind(..)
    , ValueTypeUnion(..)
    , ValueUnion(..)
    , ValuesList
    , emptyShape
    )

{-| Core SHACL AST types: shapes, constraints, and the per-graph
`SHACLmodel` that holds the parsed constructs for one named graph.

A `SHACLmodel` is a dictionary keyed by `TermId` over `SHACLconstruct`
values — each construct is either a node, a class, a property, a
node shape, a property shape, a property group, a values list, a
shape-level constraint, or a blank-node record. The AST is intentionally
non-recursive at the top level; shape constraints reference other
shapes by id and are resolved at render time.

This module ships the type definitions only. The AST builder lives in
`SHACL.AST.Builder.*` and is layered on top.


# Per-graph SHACL model

@docs SHACLmodel, SHACLmodels, SHACLdictionary, SHACLconstruct


# Class / Instance / Property

@docs Class, Instance, Property, PropertyGroup, ValuesList, BlankNodeRecord


# Shapes

@docs Shape, NodeShape, PropertyShape, PropertyShapeKind, ShapeKind, emptyShape


# Constraints

@docs ShapeConstraint, ConstraintComponent, ConstraintComponentType
@docs ConstraintValidator, ValueUnion, ValueTypeUnion


# Identifier aliases

@docs DataTypeId, PropertyShapeId, NumericUnion


# Property values

@docs PropertyValues

-}

import Dict exposing (Dict)
import Rdf.Core.Types
    exposing
        ( BlankNodeId
        , ClassId
        , NamedNodeId
        , PredicateTerm
        , Quad
        , RDFnonLiteralTerm
        , RDFobject
        , RDFterm
        , SubjectId
        )
import SHACL.Internal.CoreTypes
    exposing
        ( GraphId
        , GraphMetaData
        , GraphRole(..)
        , IRI
        , MarkdownString
        , PropertyId
        , StringType
        , TermId
        )


{-| Map of `SHACLmodel` values keyed by graph id.
-}
type alias SHACLmodels =
    Dict GraphId SHACLmodel


{-| The parsed SHACL constructs for a single named graph: the list of
graph ids this model covers (usually a singleton), optional graph
metadata, the construct dictionary, and the ids of graphs this one
depends on.
-}
type alias SHACLmodel =
    { graphIds : List GraphId
    , metadata : Maybe GraphMetaData
    , constructs : Dict TermId SHACLconstruct
    , dependencies : List GraphId
    }


{-| A class in the SHACL model: id, optional name, optional reference
to a node shape that validates instances, and the class's metaclasses,
superclasses, properties, and traits.
-}
type alias Class =
    { classId : String
    , name : Maybe StringType
    , nodeShape : Maybe TermId
    , metaClasses : Maybe (List ClassId)
    , superClasses : Maybe (List ClassId)
    , properties : Maybe (List PropertyValues)
    , traits : Maybe (List AspectId)
    }


{-| One construct in a `SHACLmodel`: a node, instance, class, property,
node shape, property shape, property group, values list, top-level
constraint, or blank-node record.
-}
type SHACLconstruct
    = SHACLnode TermId
    | SHACLinstance Instance
    | SHACLclass Class
    | SHACLproperty Property
    | SHACLnodeshape NodeShape
    | SHACLpropertyshape PropertyShape
    | SHACLpropertygroup PropertyGroup
    | SHACLlist ValuesList
    | SHACLconstraint ( TermId, ShapeConstraint )
    | SHACLblankNode BlankNodeRecord



{-
   A shape is an IRI or blank node that fulfills at least one of the following conditions in the shapes graph:

      1. a SHACL instance of sh:NodeShape or sh:PropertyShape.
      2. a subject of a triple that has sh:targetClass, sh:targetNode, sh:targetObjectsOf
         or sh:targetSubjectsOf as predicate.
      3. a subject of a triple that has a parameter as predicate.
      4. a value of a shape-expecting, non-list-taking parameter such as sh:node,
         or a member of a SHACL list
         that is a value of a shape-expecting and list-taking parameter such as sh:or.
-}


{-| The base shape record shared by `NodeShape` and `PropertyShape` via
the `extendsShape` field. Holds the shape's id, optional constraints,
label, alt labels, description, list of property shape ids, and SHACL
targets (`sh:targetClass`, `sh:targetNode`, etc.).
-}
type alias Shape =
    { id : String
    , constraints : Maybe (List ShapeConstraint)
    , label : Maybe String
    , altLabel : Maybe (List String)
    , description : Maybe (List StringType)
    , properties : Maybe (List PropertyShapeId)
    , targets : Maybe (List NamedNodeId)
    }


{-| A SHACL `sh:NodeShape` — shape-level constraints applied to focus
nodes selected by the shape's targets.
-}
type alias NodeShape =
    { extendsShape : Shape
    , constraints : Maybe (List ShapeConstraint)
    , derivedFrom : Maybe RDFterm
    }


{-| A SHACL `sh:PropertyShape` — property-level constraints on the
values produced by following a property path from a focus node.
-}
type alias PropertyShape =
    { extendsShape : Shape
    , propertyShapeFor : Maybe (List RDFnonLiteralTerm)
    , constraints : Maybe (List ShapeConstraint)
    , propertyShapeId : PropertyShapeId
    , kind : PropertyShapeKind
    , property : Maybe RDFterm
    , reification : Maybe NodeShape
    , name : Maybe String
    , description : Maybe String
    , group : Maybe ( PropertyGroupId, Maybe PropertyOrder )
    , derivedFrom : Maybe RDFterm
    }


{-| Shape-classification tag. WIP — currently a single placeholder
variant; future revisions will distinguish node-shape and property-shape
kinds at this level.
-}
type ShapeKind
    = ShapeShapeKind


{-| Enumeration of SHACL constraint components in their parsed,
typed form. One variant per SHACL spec constraint:
`sh:class`, `sh:datatype`, `sh:and`/`sh:or`/`sh:not`/`sh:xone`,
`sh:minCount`/`sh:maxCount`, cardinality, value range, length,
pattern, uniqueLang, etc. `UnresolvedConstraint` carries the raw
predicate text for anything the builder cannot yet parse.
-}
type ShapeConstraint
    = AndConstraint (List Shape)
    | ClassConstraint ClassId
    | DatatypeConstraint DataTypeId
    | GroupConstraint PropertyGroupId
    | HasValueConstraint ValueUnion
    | LessThanConstraint PropertyId
    | LessThanOrEqualsConstraint PropertyId
    | MaxCountConstraint Int
    | MaxInclusiveConstraint NumericUnion
    | MaxLengthConstraint Int
    | MinCountConstraint Int
    | MinInclusiveConstraint NumericUnion
    | MinLengthConstraint Int
    | NameConstraint String
    | NotConstraint (List Shape)
    | OrConstraint (List Shape)
    | OrderConstraint NumericUnion
    | PatternConstraint String
    | QualifiedMaxCountConstraint Int
    | QualifiedMinCountConstraint Int
    | UniqueLangConstraint Bool
    | UnresolvedConstraint String
    | ValuesConstraint (List NodeShape)
    | XoneConstraint (List Shape)


{-| Metadata about one SHACL constraint component (e.g. `sh:minCount`):
the SHACL property iri, a human-readable description, whether it can
appear on a node shape, its component category, its value type, whether
multiple values are allowed, and the validator + transformer used by
the builder.
-}
type alias ConstraintComponent =
    { property : PropertyId
    , description : MarkdownString
    , allowedOnNodeShape : Bool
    , constraintType : ConstraintComponentType
    , valueType : ValueTypeUnion
    , many : Bool
    , validator : ConstraintValidator
    , transformer : ConstraintTransformer
    }


{-| Validator hook for a constraint component. `ConstraintValidatorTBD`
is the placeholder used when no validator has been wired up yet.
-}
type ConstraintValidator
    = ConstraintValidatorTBD
    | ConstraintValidator ValidateConstraintComponent


type ConstraintTransformer
    = ConstraintTransformerTBD
    | ConstraintTransformer TransformConstraintComponent


type alias TransformConstraintComponent =
    TermId -> ConstraintComponent -> List Quad -> Result String ShapeConstraint


type alias ValidateConstraintComponent =
    TermId -> ConstraintComponent -> List Quad -> Result String Bool


type ConstraintMappingDictionary
    = Dict PropertyId ConstraintComponent


{-| Category tag for a `ConstraintComponent`. Mirrors the SHACL spec
grouping: value-type, cardinality, value-range, string-based,
list-based, property-pair, and logical constraints.
-}
type ConstraintComponentType
    = ValueTypeConstraintType
    | CardinalityConstraintType
    | ValueRangeConstraintType
    | StringBasedConstraintType
    | ListConstraintType
    | PropertyPairConstraintType
    | LogicalConstraintType


type ValueTypeConstraintComponent
    = NodeKindValueConstraint


type ClassValueConstraint
    = ClassIRIlist


type DatatypeValue
    = DatatypeIRIlist


type NodeKindV1
    = LiteralKind LiteralType


type BlankNodeOrIRI
    = BNOIiri IRI


type BlankNodeOrLiteral
    = BNOLliteral LiteralType


{-| Value carried by a constraint that takes a single SHACL value:
absent, a blank node, a named node (IRI), or a string-shaped literal.
-}
type ValueUnion
    = NoValue
    | BlankNodeValue BlankNodeId
    | NamedNodeValue NamedNodeId
    | StringValue StringType


type NodeKind
    = LiteralNode LiteralType


{-| Type-of-value declaration used in `ConstraintComponent.valueType`:
non-literal (named or blank node), literal, literal-union, or node-kind.
-}
type ValueTypeUnion
    = NonLiteralValueType NonLiteralType
    | LiteralValueType LiteralType
    | LiteralUnionValueType LiteralType
    | NodeKindValueType NonLiteralType


{-| Property-shape category: tagged by datatype, or unresolved at
build time.
-}
type PropertyShapeKind
    = DatatypePropertyShape DataTypeId
    | UnresolvedPropertyShape


{-| A property in the SHACL model: id, type, optional label and
description.
-}
type alias Property =
    { propertyId : PropertyId
    , type_ : ResourceId
    , label : Maybe String
    , description : Maybe String
    , derivedFrom : Maybe RDFterm
    }


{-| A SHACL `sh:PropertyGroup` — labels a collection of property shapes
for ordered display.
-}
type alias PropertyGroup =
    { propertyGroupId : PropertyGroupId
    , label : Maybe String
    , order : Maybe Int
    , derivedFrom : Maybe RDFterm
    }


{-| An instance (individual) in the model: id, name, alt names,
description, the list of classes it's an instance of, and its
property/value pairs.
-}
type alias Instance =
    { id : String
    , name : Maybe StringType
    , altNames : Maybe (List String)
    , description : Maybe StringType
    , typeList : List ClassId
    , properties : List PropertyValues -- List ( PredicateTerm, List RDFterm ) --  List PropertyValues
    , derivedFrom : Maybe RDFterm
    }


{-| A SHACL `sh:in`-style enumerable list of allowed values.
-}
type alias ValuesList =
    { id : String
    , values : List String -- List ( PredicateTerm, RDFterm ) -- List ValueUnion
    , derivedFrom : Maybe RDFterm
    }


{-| A blank node as it appears in the AST: blank-node id, the
predicate/object pairs that originate at it, the subject/predicate pairs
that reference it, and an optional derivation pointer.
-}
type alias BlankNodeRecord =
    { id : String
    , fields : List ( PredicateTerm, RDFterm )
    , referencedBy : List ( RDFnonLiteralTerm, PredicateTerm )
    , derivedFrom : Maybe RDFterm
    }


{-| Record pairing a property IRI with its list of values for a given
subject. Used by `Instance.properties` and `Class.properties`.
-}
type alias PropertyValues =
    { property : IRI
    , values : List ValueUnion
    }


{-| Numeric value union for constraints that take an integer (and in
the future, floats / decimals).
-}
type NumericUnion
    = IntValue Int


type LiteralType
    = LiteralUnion
    | NodeShapeId
    | XSDvalue XSDiri


type NonLiteralType
    = PropertyNonLiteral
    | ShapeNonLiteral
    | NodeKind
    | IRI
    | XSDtype


type XSDiri
    = XSDinteger
    | XSDboolean


{-| Dictionary form of a graph's constructs, keyed by `TermId`.
Equivalent to `SHACLmodel.constructs`.
-}
type alias SHACLdictionary =
    Dict TermId SHACLconstruct


type alias SHACLconstructsDictionary construct =
    Dict TermId construct


type alias PropertyOrder =
    Int


type alias AspectId =
    String


{-| String identifier for an XSD datatype IRI (typically CURIE-form like
`"xsd:integer"`).
-}
type alias DataTypeId =
    String


type alias PropertyGroupId =
    String


type alias NodeShapeId =
    String


{-| String identifier for a `PropertyShape` (typically its `sh:path`
target in CURIE form).
-}
type alias PropertyShapeId =
    String


type alias ResourceId =
    String


{-| Empty `Shape` with no constraints, label, or targets. Useful as a
starting value when building a shape incrementally.
-}
emptyShape : Shape
emptyShape =
    { id = ""
    , constraints = Nothing
    , label = Nothing
    , altLabel = Nothing
    , description = Nothing
    , properties = Nothing
    , targets = Nothing
    }
