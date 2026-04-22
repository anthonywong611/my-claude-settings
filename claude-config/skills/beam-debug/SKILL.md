---
name: beam-debug
description: >
  Debug Apache Beam / Dataflow pipeline failures. Use automatically when the user
  reports a pipeline error, 401 Unauthorized, credential issue, worker VM failure,
  job graph problem, or serialization error.
argument-hint: "[error message, job ID, or paste stack trace]"
allowed-tools: [Bash, Read, Grep, Glob]
---

You are debugging an Apache Beam / Dataflow pipeline. Work methodically through
the checklist below before proposing a fix. Never guess — read the actual files.

## Step 1 — Capture environment context

! gcloud auth list --format="value(account)" 2>/dev/null | head -1
! gcloud config get-value project 2>/dev/null
! python --version 2>/dev/null

## Step 2 — Classify the error

Analyse: $ARGUMENTS

Determine which category applies:
- **401 / credential**: Secret not reached inside DoFn. `get_secret()` called at construction time, not inside `process()`.
- **Serialisation**: DoFn holds an unpicklable object (DB conn, file handle, requests.Session). Move to `setup()`.
- **Schema mismatch**: BigQuery row fields don't match declared schema. Check nullable vs required.
- **GCS path**: Bucket/object doesn't exist or IAM deny. Validate path before read.
- **Logic / transform**: Incorrect key, windowing, or side-input.
- **OOM / quota**: Worker ran out of memory or hit API rate limit.

## Step 3 — Inspect relevant code

Search the repo for the failing component:

```bash
grep -r "get_secret\|os.environ\|os.getenv" --include="*.py" -n .
grep -r "class.*DoFn" --include="*.py" -n .
```

Read the flagged files fully before proposing changes.

## Step 4 — Check credential propagation (if 401)

Reference @includes/credential-patterns.md.

The canonical fix for 401 on Dataflow workers:
```python
class MyDoFn(beam.DoFn):
    def setup(self):
        # Called once per worker. Safe to fetch secrets here.
        self._token = get_secret("my-api-token")

    def process(self, element):
        # Use self._token — NOT os.environ
        ...
```

## Step 5 — Propose the minimal diff

Output only the changed functions/methods. Do not rewrite the whole file.
Explain *why* each change is needed in one sentence.
