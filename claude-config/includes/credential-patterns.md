# Credential Patterns for Dataflow

## The problem
Azure DevOps pipeline variables are injected as environment variables at **build time**
on the ADO agent. They are NOT passed to Dataflow worker VMs. Workers run in a
separate GCP environment with their own identity (the Dataflow service account).

## The solution: GCP Secret Manager

### 1. Store the secret once (in CI or manually)
```bash
echo -n "my-api-token-value" | \
  gcloud secrets create icis-api-token \
    --data-file=- \
    --project=$GCP_PROJECT_ID
```

### 2. Grant the Dataflow SA access
```bash
gcloud secrets add-iam-policy-binding icis-api-token \
  --member="serviceAccount:$DATAFLOW_SA@$PROJECT.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

### 3. Fetch inside setup() — NOT __init__() or process()

```python
import apache_beam as beam
from google.cloud import secretmanager


def get_secret(secret_id: str, project_id: str) -> str:
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    return client.access_secret_version(name=name).payload.data.decode()


class CallIcisApiDoFn(beam.DoFn):
    def __init__(self, project_id: str, secret_id: str) -> None:
        # Only store serializable primitives here
        self._project_id = project_id
        self._secret_id = secret_id

    def setup(self) -> None:
        # Called once per worker process — safe to fetch secrets
        self._token = get_secret(self._secret_id, self._project_id)
        self._session = requests.Session()
        self._session.headers["Authorization"] = f"Bearer {self._token}"

    def process(self, element):
        response = self._session.get(f"https://api.icis.com/v1/data/{element}")
        response.raise_for_status()
        yield response.json()

    def teardown(self) -> None:
        self._session.close()
```

## Anti-patterns (never do this)

```python
# WRONG: os.environ not available on Dataflow workers
class BadDoFn(beam.DoFn):
    def process(self, element):
        token = os.environ["ICIS_API_TOKEN"]  # KeyError on workers!

# WRONG: requests.Session is not picklable — will fail at worker startup
class AlsoBadDoFn(beam.DoFn):
    def __init__(self):
        self._session = requests.Session()  # Serialization error!
```
