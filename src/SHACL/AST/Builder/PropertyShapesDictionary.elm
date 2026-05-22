module SHACL.AST.Builder.PropertyShapesDictionary exposing (buildPropertyShape)

{-| Build the typed `PropertyShape` AST for a SHACL property shape
referenced by an `RDFnonLiteralTerm`.

@docs buildPropertyShape

-}

import Rdf.Core.Types
    exposing
        ( Quad
        , RDFnonLiteralTerm
        , RDFterm(..)
        )
import SHACL.AST.Builder.Constraints exposing (..)
import SHACL.Internal.CoreFunctions exposing (..)
import SHACL.Internal.CoreTypes exposing (..)
import SHACL.SHACLtypes exposing (..)


{-| Build a `PropertyShape` from its identifier and the full quad list.
WIP — looks up `sh:name`, `sh:path`, and the reverse `sh:property`
references, then delegates to the constraint builder. The resulting
shape's `kind` is `UnresolvedPropertyShape` until datatype detection
is wired up.
-}
buildPropertyShape : RDFnonLiteralTerm -> List Quad -> PropertyShape
buildPropertyShape propertyShape quads =
    let
        propertyShapeId : TermId
        propertyShapeId =
            nonLiteralToString propertyShape

        propertyShapeQuads : List Quad
        propertyShapeQuads =
            getResourceQuads propertyShape quads

        shape : Shape
        shape =
            { id = propertyShapeId
            , constraints = Nothing
            , label = Nothing
            , altLabel = Nothing
            , description = Nothing
            , properties = Nothing
            , targets = Nothing
            }

        shName : Maybe String
        shName =
            objectsForGivenSubjectPredicate propertyShape "sh:name" quads
                |> List.head
                |> Maybe.map rdfTermToString

        property : Maybe RDFterm
        property =
            objectsForGivenSubjectPredicate propertyShape "sh:path" quads
                |> List.head

        referencedBy : Maybe (List RDFnonLiteralTerm)
        referencedBy =
            subjectsForGivenPredicateObject "sh:property" (NonLiteral propertyShape) quads

        constraints : List ShapeConstraint
        constraints =
            buildPropertyShapeConstraints propertyShapeId propertyShapeQuads quads
    in
    { propertyShapeId = propertyShapeId
    , propertyShapeFor = referencedBy
    , kind = UnresolvedPropertyShape
    , property = property
    , reification = Nothing
    , name = shName
    , description = Nothing
    , group = Nothing
    , extendsShape = shape
    , constraints = Just constraints
    , derivedFrom = Just (NonLiteral propertyShape)
    }


-- addPropertyShapeToNode : NodeShape -> PropertyShapeId -> NodeShape
-- addPropertyShapeToNode ns psQN = { ns | properties = psQN :: ns.properties  }
-- buildPropertyShape cQN psKIND pQN name description psConstraints pg order  =
--   let
--     psQN = cQN ++ "--" ++ pQN
--   in
--     PropertyShape psQN psKIND pQN psConstraints
--         Nothing -- for reification
--         name description pg order
--
--
-- shaclmate - PropertyShape.ts
-- ============================
-- import type { BlankNode, Literal, NamedNode } from "@rdfjs/types";
-- import type { Maybe } from "purify-ts";
-- import type { OntologyLike } from "./OntologyLike.js";
-- import type { PropertyPath } from "./PropertyPath.js";
-- import { Shape } from "./Shape.js";
-- import type { ShapesGraph } from "./ShapesGraph.js";
-- import type * as generated from "./generated.js";
-- export class PropertyShape<
--   NodeShapeT extends ShapeT,
--   OntologyT extends OntologyLike,
--   PropertyGroupT,
--   PropertyShapeT extends ShapeT,
--   ShapeT,
-- > extends Shape<NodeShapeT, OntologyT, PropertyGroupT, PropertyShapeT, ShapeT> {
--   readonly constraints: Shape.Constraints<
--     NodeShapeT,
--     OntologyT,
--     PropertyGroupT,
--     PropertyShapeT,
--     ShapeT
--   >;
--   constructor(
--     private readonly generatedShaclCorePropertyShape: Omit<
--       generated.ShaclCorePropertyShape,
--       "type"
--     >,
--     shapesGraph: ShapesGraph<
--       NodeShapeT,
--       OntologyT,
--       PropertyGroupT,
--       PropertyShapeT,
--       ShapeT
--     >,
--   ) {
--     super(generatedShaclCorePropertyShape, shapesGraph);
--     this.constraints = new Shape.Constraints(
--       generatedShaclCorePropertyShape,
--       shapesGraph,
--     );
--   }
--   get defaultValue(): Maybe<BlankNode | Literal | NamedNode> {
--     return this.generatedShaclCorePropertyShape.defaultValue;
--   }
--   get descriptions(): readonly Literal[] {
--     return this.generatedShaclCorePropertyShape.descriptions;
--   }
--   get groups(): readonly PropertyGroupT[] {
--     return this.generatedShaclCorePropertyShape.groups.flatMap((identifier) =>
--       this.shapesGraph.propertyGroupByIdentifier(identifier).toList(),
--     );
--   }
--   get names(): readonly Literal[] {
--     return this.generatedShaclCorePropertyShape.names;
--   }
--   get order(): Maybe<number> {
--     return this.generatedShaclCorePropertyShape.order;
--   }
--   get path(): PropertyPath {
--     return this.generatedShaclCorePropertyShape.path;
--   }
--   override toString(): string {
--     const keyValues: string[] = [`node=${this.identifier.value}`];
--     const path = this.path;
--     if (path.kind === "PredicatePath") {
--       keyValues.push(`path=${path.iri.value}`);
--     }
--     return `PropertyShape(${keyValues.join(", ")})`;
--   }
-- }
