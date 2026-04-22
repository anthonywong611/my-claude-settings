# GCP Rules

## Authentication
- Local dev: `gcloud auth application-default login`
- CI/CD: Workload Identity Federation (preferred) or service account key (last resort)
- Dataflow workers: Secret Manager only — never pass credentials as pipeline options

## Secret Manager
- All secrets live in Secret Manager. Access via:
  ```python
  from google.cloud import secretmanager
  def get_secret(secret_id: str, project_id: str | None = None) -> str:
      project = project_id or os.environ["GOOGLE_CLOUD_PROJECT"]
      client = secretmanager.SecretManagerServiceClient()
      name = f"projects/{project}/secrets/{secret_id}/versions/latest"
      return client.access_secret_version(name=name).payload.data.decode()
  ```
- Secret names: `kebab-case`, environment-suffixed where needed (`icis-api-token-prod`)

## BigQuery
- Always partition large tables on `_PARTITIONTIME` or an explicit date column
- Use `INFORMATION_SCHEMA` views to monitor slot usage in production
- Set `maximumBytesBilled` on exploratory queries in scripts

## GCS
- Bucket naming: `{project}-{env}-{purpose}` (e.g. `myproj-prod-dataflow-temp`)
- Validate paths before use: check bucket exists and SA has read access
- Use `gsutil -m` for parallel multi-file operations

## IAM
- Dataflow SA minimum roles: `dataflow.worker`, `storage.objectAdmin`, `bigquery.dataEditor`, `secretmanager.secretAccessor`
- Never assign `roles/owner` or `roles/editor` to pipeline service accounts
