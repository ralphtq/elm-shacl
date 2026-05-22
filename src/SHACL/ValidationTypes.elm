module SHACL.ValidationTypes exposing
    ( EngineInfo
    , ShapeDefinition
    , ShaclValidationReport
    , ShaclValidationResult
    , Severity(..)
    , severityFromIRI
    , severityLabel
    )

{-| Types for SHACL validation reports as returned by a validation
engine (e.g. `rdf-validate-shacl`, Apache Jena's `shacl` CLI).

A `ShaclValidationReport` is the top-level structure: a conformance
flag, the list of per-target `ShaclValidationResult` records, the
shape definitions consulted, summary counts, and an `EngineInfo`
record describing which engine produced the report.

`Severity` is a small ADT that classifies results — the standard SHACL
severities (`Violation`, `Warning`, `Info`) plus extras the engine may
emit when running SHACL-SPARQL constraints (`QueryTimeout`,
`QueryError`, `Skipped`).


# Reports

@docs ShaclValidationReport, ShaclValidationResult, ShapeDefinition, EngineInfo


# Severity

@docs Severity, severityFromIRI, severityLabel

-}


{-| Metadata about a single SHACL shape consulted during validation.
The `turtle` field carries the shape's source Turtle (helpful for
showing the user the constraint that produced a result).
-}
type alias ShapeDefinition =
    { shapeIRI : String
    , label : String
    , description : String
    , turtle : String
    }


{-| Metadata about which validation engine produced the report and how
it ran. `jenaFallback` is `True` when the primary in-browser engine
failed and the report came from a server-side Jena run instead.
-}
type alias EngineInfo =
    { engine : String
    , jenaFallback : Bool
    , jenaError : String
    , elapsedMs : Int
    }


{-| A complete SHACL validation report: whether the data conforms, the
per-result details, the shape definitions consulted, and summary counts.
-}
type alias ShaclValidationReport =
    { conforms : Bool
    , results : List ShaclValidationResult
    , shapeDefinitions : List ShapeDefinition
    , subjectsTargeted : Int
    , dataSubjects : Int
    , engineInfo : EngineInfo
    }


{-| A single validation result: the focus node, the property path (if
any), the constraint component that fired, the source shape, a
human-readable message, and the offending value.
-}
type alias ShaclValidationResult =
    { severity : String
    , focusNode : String
    , path : String
    , sourceConstraintComponent : String
    , sourceShape : String
    , message : String
    , value : String
    }


{-| Classification of a validation result. Standard SHACL severities
are `Violation`, `Warning`, and `Info`. `QueryTimeout`, `QueryError`,
and `Skipped` are extras that SHACL-SPARQL constraint engines may
emit. `UnknownSeverity` carries the raw IRI for anything not
recognised.
-}
type Severity
    = Violation
    | Warning
    | Info
    | QueryTimeout
    | QueryError
    | Skipped
    | UnknownSeverity String


{-| Classify a severity IRI string into a `Severity` value. Matches
substrings (so the full IRI `http://www.w3.org/ns/shacl#Violation`
works as well as a bare `"Violation"`).
-}
severityFromIRI : String -> Severity
severityFromIRI iri =
    if String.contains "Violation" iri then
        Violation

    else if String.contains "Warning" iri then
        Warning

    else if String.contains "QueryTimeout" iri then
        QueryTimeout

    else if String.contains "QueryError" iri then
        QueryError

    else if String.contains "Skipped" iri then
        Skipped

    else if String.contains "Info" iri then
        Info

    else
        UnknownSeverity iri


{-| Display label for a `Severity` value. `UnknownSeverity iri` becomes
`"Unknown (iri)"`.
-}
severityLabel : Severity -> String
severityLabel severity =
    case severity of
        Violation ->
            "Violation"

        Warning ->
            "Warning"

        Info ->
            "Info"

        QueryTimeout ->
            "Query Timeout"

        QueryError ->
            "Query Error"

        Skipped ->
            "Skipped"

        UnknownSeverity s ->
            "Unknown (" ++ s ++ ")"
