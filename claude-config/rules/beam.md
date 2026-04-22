# Apache Beam Rules

## DoFn lifecycle
- `__init__`: accept only serializable primitives (strings, ints). No connections, no clients.
- `setup()`: initialise clients, fetch secrets, open connections. Called once per worker process.
- `process()`: pure transform logic. Use `self._client` initialized in `setup()`.
- `teardown()`: close connections, flush buffers.

## Serialization
- DoFns are pickled and shipped to workers. Any non-serializable object at class level will fail.
- Pattern: store config as strings in `__init__`, materialise as clients in `setup()`.

## PTransforms
- Every transform must have a descriptive label string: `beam.Map("ParseIcisRow", parse_row)`
- Compose PTransforms from smaller, testable units — avoid monolithic DoFns over 50 lines
- Use `beam.ParDo(MyDoFn()).with_output_types(OutputType)` to aid type inference

## Credentials (critical)
- Secrets must be fetched inside `setup()` using `get_secret()` from Secret Manager
- Azure DevOps pipeline variables DO NOT reach Dataflow worker VMs
- Reference: @includes/credential-patterns.md

## BigQuery writes
- Always pass `schema=` explicitly to `WriteToBigQuery`
- Use `CREATE_IF_NEEDED` + `WRITE_TRUNCATE` for idempotent batch jobs
- Never use auto-detect schema in production pipelines

## Testing
- Test DoFns directly with `TestPipeline` and `assert_that`
- Mock GCS reads with `beam.testing.util` or inject fake sources
