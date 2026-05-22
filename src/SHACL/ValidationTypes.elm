module SHACL.ValidationTypes exposing
    ( EngineInfo
    , ShapeDefinition
    , ShaclValidationReport
    , ShaclValidationResult
    , Severity(..)
    , severityFromIRI
    , severityLabel
    )


type alias ShapeDefinition =
    { shapeIRI : String
    , label : String
    , description : String
    , turtle : String
    }


type alias EngineInfo =
    { engine : String
    , jenaFallback : Bool
    , jenaError : String
    , elapsedMs : Int
    }


type alias ShaclValidationReport =
    { conforms : Bool
    , results : List ShaclValidationResult
    , shapeDefinitions : List ShapeDefinition
    , subjectsTargeted : Int
    , dataSubjects : Int
    , engineInfo : EngineInfo
    }


type alias ShaclValidationResult =
    { severity : String
    , focusNode : String
    , path : String
    , sourceConstraintComponent : String
    , sourceShape : String
    , message : String
    , value : String
    }


type Severity
    = Violation
    | Warning
    | Info
    | QueryTimeout
    | QueryError
    | Skipped
    | UnknownSeverity String


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
