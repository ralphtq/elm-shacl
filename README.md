# ralphtq/elm-shacl

SHACL types and helpers for Elm. Companion to
[`ralphtq/elm-rdf`](https://github.com/ralphtq/elm-rdf).

## Status

Pre-release. `1.0.0` is the first cut from the `elm-qudt` extraction —
shape dictionaries and validation report types. Subsequent phases will
add the SHACL AST (types, builder, transformer, retriever, constraints)
once the elm-qudt seam with `Lib.CoreTypes` is resolved.

## Install

```sh
elm install ralphtq/elm-shacl
```

## Modules

- `SHACL.ShapeDictionary` — `ShapeEntry`, `ShapeCollection`,
  `ShapeCollectionEntry`, JSON decoders, and TTL reassembly helpers.
- `SHACL.ValidationTypes` — `Severity` ADT, `ShaclValidationReport`,
  `ShaclValidationResult`, `ShapeDefinition`, `EngineInfo`, IRI/label
  helpers.

## License

MIT
