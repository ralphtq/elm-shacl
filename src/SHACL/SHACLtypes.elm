module SHACL.SHACLtypes exposing (..)

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



-- shapeConstraint : ShapeConstraint -> ConstraintKind
-- shapeConstraint constraint =
--     ShapeConstraint constraint


type alias SHACLmodels =
    Dict GraphId SHACLmodel


type alias SHACLmodel =
    { graphIds : List GraphId
    , metadata : Maybe GraphMetaData
    , constructs : Dict TermId SHACLconstruct
    , dependencies : List GraphId
    }


type alias Class =
    { classId : String
    , name : Maybe StringType
    , nodeShape : Maybe TermId
    , metaClasses : Maybe (List ClassId)
    , superClasses : Maybe (List ClassId)
    , properties : Maybe (List PropertyValues)
    , traits : Maybe (List AspectId)
    }


type alias SingleConstraintOccurrence =
    { occurrence : ( SubjectId, RDFobject ), property : PropertyId }


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


type alias Shape =
    { id : String
    , constraints : Maybe (List ShapeConstraint)
    , label : Maybe String
    , altLabel : Maybe (List String)
    , description : Maybe (List StringType)
    , properties : Maybe (List PropertyShapeId)
    , targets : Maybe (List NamedNodeId)
    }


type alias NodeShape =
    { extendsShape : Shape
    , constraints : Maybe (List ShapeConstraint)
    , derivedFrom : Maybe RDFterm
    }


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


type ShapeKind
    = ShapeShapeKind


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



-- type ConstraintKind
--     = ShapeConstraint ShapeConstraint
--     | NodeShapeConstraintKind ShapeConstraint
--     | PropertyShapeConstraintKind ShapeConstraint
-- type ShapeConstraint
--     = AndConstraintV1 (List Shape)
--     -- | InConstraint (List ValueUnion)
--     -- | NodeConstraint NodeShapeId
--     -- | NodeKindConstraint NodeKind
--     -- | NotConstraint (List NodeShape)
--     -- | OrConstraint (List Shape)
--     -- | QualifiedValueConstraint ValueUnion
--     -- | XoneConstraint (List Shape)
--     -- | UnresolvedConstraint String
-- type ShapeConstraint
--     = ClosedConstraint Bool
--     | IgnoredPropertiesConstraint (List PropertyId)
--     | TargetClassConstraint (List NamedNodeId)
--     | TargetNodeConstraint NamedNodeId
--     | TargetObjectsOfConstraint NamedNodeId
--     | TargetSubjectsOfConstraint NamedNodeId
-- type ShapeConstraint
--     = ClassConstraint ClassId
--     | DatatypeConstraint DataTypeId
--     | EqualsConstraint NodeKind
--     | FlagsConstraint String
--     | GroupConstraint PropertyGroupId
--     | HasValueConstraint ValueUnion
--     | LessThanConstraint PropertyId
--     | LessThanOrEqualsConstraint PropertyId
--     | MaxCountConstraint Int
--     | MaxInclusiveConstraint NumericUnion
--     | MaxLengthConstraint Int
--     | MinCountConstraint Int
--     | MinInclusiveConstraint NumericUnion
--     | MinLengthConstraint Int
--     | NameConstraint String
--     | OrderConstraint NumericUnion
--     | PathConstraint String
--     | PatternConstraint String
--     | QualifiedMinCountConstraint Int
--     | QualifiedMaxCountConstraint Int
--     | UniqueLangConstraint Bool
--     | ValuesConstraint (List NodeShape)


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


type ConstraintComponentType
    = ValueTypeConstraintType
    | CardinalityConstraintType
    | ValueRangeConstraintType
    | StringBasedConstraintType
    | ListConstraintType
    | PropertyPairConstraintType
    | LogicalConstraintType



-- Non-validated ones: name, description, order, group


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


type ValueUnion
    = NoValue
    | BlankNodeValue BlankNodeId
    | NamedNodeValue NamedNodeId
    | StringValue StringType


type NodeKind
    = LiteralNode LiteralType


type ValueTypeUnion
    = NonLiteralValueType NonLiteralType
    | LiteralValueType LiteralType
    | LiteralUnionValueType LiteralType
    | NodeKindValueType NonLiteralType


type PropertyShapeKind
    = DatatypePropertyShape DataTypeId
    | UnresolvedPropertyShape


type alias Property =
    { propertyId : PropertyId
    , type_ : ResourceId
    , label : Maybe String
    , description : Maybe String
    , derivedFrom : Maybe RDFterm
    }


type alias PropertyGroup =
    { propertyGroupId : PropertyGroupId
    , label : Maybe String
    , order : Maybe Int
    , derivedFrom : Maybe RDFterm
    }


type alias Instance =
    { id : String
    , name : Maybe StringType
    , altNames : Maybe (List String)
    , description : Maybe StringType
    , typeList : List ClassId
    , properties : List PropertyValues -- List ( PredicateTerm, List RDFterm ) --  List PropertyValues
    , derivedFrom : Maybe RDFterm
    }


type alias ValuesList =
    { id : String
    , values : List String -- List ( PredicateTerm, RDFterm ) -- List ValueUnion
    , derivedFrom : Maybe RDFterm
    }


type alias BlankNodeRecord =
    { id : String
    , fields : List ( PredicateTerm, RDFterm )
    , referencedBy : List ( RDFnonLiteralTerm, PredicateTerm )
    , derivedFrom : Maybe RDFterm
    }


type alias PropertyValues =
    { property : IRI
    , values : List ValueUnion
    }


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


type alias SHACLdictionary =
    Dict TermId SHACLconstruct


type alias SHACLconstructsDictionary construct =
    Dict TermId construct


graphRoleToString : GraphRole -> String
graphRoleToString graphRole =
    case graphRole of
        SchemaGraph ->
            "Schema Graph"

        VocabGraph ->
            "Vocabulary Graph"

        UnspecifiedGraphRole ->
            "Unspecified Graph Role"


type alias PropertyOrder =
    Int


type alias AspectId =
    String


type alias DataTypeId =
    String


type alias PropertyGroupId =
    String


type alias NodeShapeId =
    String


type alias PropertyShapeId =
    String


type alias ResourceId =
    String


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
