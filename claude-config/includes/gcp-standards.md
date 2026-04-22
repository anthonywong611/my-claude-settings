# GCP Standards

## Naming conventions
| Resource | Pattern | Example |
|---|---|---|
| GCS bucket | `{project}-{env}-{purpose}` | `myproj-prod-dataflow-temp` |
| BQ dataset | `{domain}_{env}` | `icis_prod` |
| BQ table | `snake_case` | `price_assessments` |
| Secret | `{service}-{key}-{env}` | `icis-api-token-prod` |
| Dataflow job | `{pipeline}-{env}-{yyyymmdd}` | `price-ingest-prod-20250420` |
| Service account | `{purpose}@{project}.iam.gserviceaccount.com` | `dataflow-runner@myproj.iam.gserviceaccount.com` |

## Required labels on all GCP resources
```
env: prod | staging | dev
team: data-engineering
cost-centre: <your-code>
pipeline: <pipeline-name>
```

## BigQuery schema conventions
- Dates: `DATE` type, never string
- Timestamps: `TIMESTAMP` UTC, never string
- Nullable vs required: be explicit — default is `NULLABLE`
- Partition field: `ingestion_date DATE` on all large tables
- Cluster fields: the top 2-3 columns used in `WHERE` clauses

## IAM least-privilege matrix
| Role | Use case |
|---|---|
| `dataflow.worker` | Dataflow SA — always required |
| `storage.objectAdmin` | Dataflow SA reading/writing GCS |
| `bigquery.dataEditor` | Dataflow SA writing to BQ |
| `secretmanager.secretAccessor` | Dataflow SA fetching secrets |
| `bigquery.jobUser` | Dataflow SA submitting BQ jobs |
| `bigquery.dataViewer` | Read-only BQ access for analysts |
