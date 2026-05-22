module SHACL.AST.Builder.QueryHelpers exposing (..)

import SHACL.Internal.CoreFunctions exposing (..)
import SHACL.Internal.CoreTypes exposing (..)

-- import SharedTemplate exposing (SharedTemplate)
--

import Rdf.Core.Prefixes exposing (encodedPrefixes)
import Url


queryQUDTclasses =
    """
 SELECT ?class ?label ?description
 WHERE {
     ?class a owl:Class .
     OPTIONAL {?class rdfs:label ?label}
     OPTIONAL {?class rdfs:comment ?description}
 }
 """


querySubject : String -> String
querySubject s =
    let
        query =
            "SELECT ?p ?o WHERE { "
                ++ s
                ++ " ?p ?o . "
                ++ " }"
    in
    query


queryQUDTunits =
    """
 SELECT ?unit ?label
 WHERE {
     ?unit a qudt:Unit .
     ?unit rdfs:label ?label .
     FILTER (LANG(?label) = "en")
 } ORDER BY ?ul
 """


queryCountOfUnits =
    """
 SELECT 
    (COUNT(?unit) AS ?numberOfUnits) 
    (COUNT(?qk) AS ?numberOfQuantityKinds)
    (COUNT(?constant) AS ?numberOfConstants)
 WHERE {
    {?unit a qudt:Unit }
    UNION
    {?qk a qudt:QuantityKind}
    UNION
    {?constant a qudt:PhysicalConstant}
 }
 """


queryQUDTtriples =
    """
 SELECT ?subject ?predicate ?object
 WHERE {
   ?subject ?predicate ?object
 }
 """


sparqlQuery : String -> Maybe Int -> String
sparqlQuery query max =
    case max of
        Just n ->
            query ++ "LIMIT" ++ " " ++ String.fromInt n

        Nothing ->
            query


queryUnits =
    encodedPrefixes ++ String.replace "%20" "+" (Url.percentEncode (sparqlQuery queryQUDTunits <| Just 10))


queryCounts =
    encodedPrefixes ++ String.replace "%20" "+" (Url.percentEncode (sparqlQuery queryCountOfUnits Nothing))


buildSPARQLsubjectQuery : TermId -> String
buildSPARQLsubjectQuery termId =
    let
        instanceDetailsQuery =
            sparqlQuery (querySubject termId) (Just 2000)
                |> Url.percentEncode
    in
    encodedPrefixes ++ instanceDetailsQuery


queryTriples : String
queryTriples =
    encodedPrefixes ++ String.replace "%20" "+" (Url.percentEncode (sparqlQuery queryQUDTtriples <| Just 1000))
