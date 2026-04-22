# Apache Beam Patterns

## Canonical batch pipeline structure
```python
with beam.Pipeline(options=pipeline_options) as p:
    (
        p
        | "ReadFromGCS"    >> beam.io.ReadFromText(gcs_path)
        | "ParseRows"      >> beam.ParDo(ParseRowDoFn())
        | "NormalizeSchema">> beam.ParDo(NormalizeDoFn())
        | "FilterInvalid"  >> beam.Filter(lambda r: r is not None)
        | "WriteToBQ"      >> beam.io.WriteToBigQuery(
            table=f"{project}:{dataset}.{table}",
            schema=load_schema("schema/my_table.json"),
            write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
        )
    )
```

## Reading Excel from GCS
```python
import io
import apache_beam as beam
import pandas as pd
from google.cloud import storage


class ReadExcelFromGCSDoFn(beam.DoFn):
    def __init__(self, bucket: str) -> None:
        self._bucket_name = bucket

    def setup(self) -> None:
        self._gcs = storage.Client()

    def process(self, blob_name: str):
        bucket = self._gcs.bucket(self._bucket_name)
        blob = bucket.blob(blob_name)
        data = blob.download_as_bytes()
        df = pd.read_excel(io.BytesIO(data), dtype=str)
        for row in df.to_dict("records"):
            yield row
```

## Schema loading helper
```python
import json
from apache_beam.io.gcp.bigquery_tools import parse_table_schema_from_json

def load_schema(path: str) -> dict:
    with open(path) as f:
        return parse_table_schema_from_json(json.dumps(json.load(f)))
```

## Pipeline options template
```python
from apache_beam.options.pipeline_options import PipelineOptions, GoogleCloudOptions, WorkerOptions

class MyPipelineOptions(PipelineOptions):
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_argument("--input-bucket", required=True)
        parser.add_argument("--output-table", required=True)
        parser.add_argument("--secret-id", default="icis-api-token")

options = MyPipelineOptions()
gcloud_opts = options.view_as(GoogleCloudOptions)
gcloud_opts.project = project_id
gcloud_opts.region = "us-central1"
gcloud_opts.staging_location = f"gs://{temp_bucket}/staging"
gcloud_opts.temp_location = f"gs://{temp_bucket}/temp"
worker_opts = options.view_as(WorkerOptions)
worker_opts.machine_type = "n1-standard-2"
```
