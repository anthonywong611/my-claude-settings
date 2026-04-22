---
name: gcp-dataflow
description: >
  GCP Dataflow operations: submit jobs, inspect job graphs, read worker logs,
  check IAM, tune pipeline options. Use when user asks about Dataflow job status,
  performance, resource configuration, or job submission.
argument-hint: "[job-id or describe what you need]"
allowed-tools: [Bash, Read]
---

You are operating GCP Dataflow. Always confirm project and region before actions.

! gcloud config get-value project
! gcloud config get-value compute/region

## Common operations

**List recent jobs**
```bash
gcloud dataflow jobs list --region=$REGION --limit=10 --format="table(id,name,currentState,createTime)"
```

**Inspect a specific job**: $ARGUMENTS
```bash
gcloud dataflow jobs describe $ARGUMENTS --region=$REGION --format=json | jq '{id,name,currentState,environment}'
```

**Fetch worker logs (last 50 errors)**
```bash
gcloud logging read \
  'resource.type="dataflow_step" severity>=ERROR' \
  --project=$PROJECT \
  --limit=50 \
  --format="table(timestamp,jsonPayload.message)"
```

**Check pipeline options**
```bash
gcloud dataflow jobs describe $ARGUMENTS --region=$REGION \
  --format="json" | jq '.environment.sdkPipelineOptions.options'
```

## IAM checklist (run if permission errors)
```bash
gcloud projects get-iam-policy $PROJECT \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount" \
  --format="table(bindings.role,bindings.members)"
```

Required roles for Dataflow SA:
- `roles/dataflow.worker`
- `roles/storage.objectAdmin` (GCS buckets)
- `roles/bigquery.dataEditor` (if writing to BQ)
- `roles/secretmanager.secretAccessor` (if using Secret Manager)
