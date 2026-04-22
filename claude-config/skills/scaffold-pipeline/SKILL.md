---
name: scaffold-pipeline
description: >
  Scaffold a new Apache Beam / Dataflow batch pipeline from a template.
  Use when user wants to create a new pipeline, ETL job, or Dataflow component.
argument-hint: "[pipeline name and brief description of source/sink]"
allowed-tools: [Bash, Write, Edit]
---

You are scaffolding a production-grade Apache Beam batch pipeline on GCP Dataflow.

## Pipeline spec: $ARGUMENTS

## Questions to resolve before writing code
If not answered in $ARGUMENTS, ask these (one message, all at once):
1. Source: GCS (CSV/Excel/Parquet/JSON) or API?
2. Sink: BigQuery table name + dataset?
3. Is schema fixed or does it vary between runs?
4. Approximate row count per batch (for worker sizing)?
5. Any transformations beyond read → normalize → write?

## Scaffold structure
```
pipelines/<name>/
├── pipeline.py          # Entry point, pipeline options, runner config
├── transforms/
│   ├── __init__.py
│   ├── read.py          # Source DoFn / PTransform
│   ├── normalize.py     # Schema normalization
│   └── write.py         # BQ writer PTransform
├── schema/
│   └── <name>.json      # BigQuery JSON schema
├── tests/
│   ├── test_read.py
│   ├── test_normalize.py
│   └── conftest.py
├── requirements.txt
└── README.md
```

Reference @includes/beam-patterns.md and @includes/credential-patterns.md
when writing DoFns. Credentials must be fetched in `setup()`.
