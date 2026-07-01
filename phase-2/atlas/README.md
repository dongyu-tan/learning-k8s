# Atlas: Self-Hosted Data Plane Simulator

Atlas is an infrastructure capstone project that provisions and operates a small
data platform on AWS EKS. It uses Terraform for AWS infrastructure, Helm for
Kubernetes packaging, Argo CD for GitOps delivery, FastAPI for the API service,
PostgreSQL for source metadata and check history, and S3 for worker-generated
freshness reports.

## Architecture

![Atlas architecture diagram](asset/architecture.png)

Runtime data flow:

1. A client creates a source through `POST /api/v1/sources`.
2. The API stores source metadata in PostgreSQL.
3. The worker CronJob checks source freshness against the configured table and timestamp column.
4. The worker writes freshness results to PostgreSQL.
5. The worker uploads a JSON report to S3.
6. The API exposes the latest result and result history.

Freshness statuses:

| Status | Meaning |
| --- | --- |
| `ok` | Latest data is within `expected_frequency_minutes`. |
| `stale` | Latest data is older than `expected_frequency_minutes`. |
| `no_data` | The monitored table has no rows. |

## Tech Stack

| Tool | Purpose |
| --- | --- |
| Terraform | AWS infrastructure provisioning |
| AWS EKS | Kubernetes cluster |
| AWS RDS PostgreSQL | Application database |
| AWS S3 | Worker report storage |
| AWS ECR | Docker image registry |
| Helm | Kubernetes app packaging |
| Argo CD | GitOps deployment |
| AWS Load Balancer Controller | ALB Ingress provisioning |
| FastAPI | API service |
| Python worker | Scheduled data freshness checks |
| kube-prometheus-stack | Monitoring foundation |

## Repository Structure

```text
phase-2/atlas/
  argocd/                 # Argo CD root and application manifests
  charts/
    api-service/          # Helm chart for the FastAPI service
    worker/               # Helm chart for the worker CronJob
  docs/                   # Runbooks and capstone documentation guides
  services/
    api-service/          # FastAPI application
    workers/              # Freshness-checking worker
  terraform/
    environments/aws/dev/ # AWS dev environment entrypoint
    modules/aws/          # Reusable AWS modules
```

## Infrastructure Provisioned

The Terraform dev environment provisions:

- VPC networking for EKS and RDS.
- EKS cluster and managed node groups.
- RDS PostgreSQL database.
- S3 bucket for worker freshness reports.
- ECR repositories for API and worker images.
- IAM roles and IRSA for the worker and cluster controllers.
- AWS Load Balancer Controller.
- Argo CD.
- kube-prometheus-stack.

Primary entrypoint:

```bash
cd /infra-roadmap/phase-2/atlas/terraform/environments/aws/dev
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

After apply, configure `kubectl`:

```bash
aws eks update-kubeconfig \
  --region ap-southeast-5 \
  --name "$(terraform output -raw eks_cluster_name)"
```

## Application Components

### API Service

The API service is a FastAPI application deployed as a Kubernetes Deployment. It
exposes:

- `GET /docs` for Swagger UI.
- `GET /healthz` for basic liveness.
- `GET /readyz` for database-backed readiness.
- `POST /api/v1/sources` to register a source.
- `GET /api/v1/sources` to list sources.
- `GET /api/v1/sources/{source_id}` to read a source and latest result.
- `GET /api/v1/sources/{source_id}/history` to read check history.

### Worker

The worker is a Kubernetes CronJob. It reads registered sources from PostgreSQL,
checks the most recent timestamp in each configured table, records check results,
and writes a JSON report to S3 under `reports/`.

### Ingress

The API chart enables an AWS ALB Ingress with host `atlas.local`. Browser access
requires DNS or a temporary `/etc/hosts` entry. Directly opening the ALB DNS name
may not match the Ingress host rule.

The ALB health check path is `/healthz`.

## Deployment Flow

Atlas uses a GitOps deployment model:

```text
Code changes -> Docker build -> Push image to ECR
Manifest changes -> Commit and push to GitHub
Argo CD watches GitHub main
Argo CD applies Helm charts to EKS
Kubernetes pulls images from ECR
```

Important operational detail: Argo CD reconciles from the configured Git
repository and revision in `argocd/root-app.yaml`. It does not read uncommitted
local files.

Rebuild and push Docker images when API or worker code changes. A rebuild is not
needed for Helm values, Ingress rules, secret names, resource limits, or other
Kubernetes-only configuration changes.

Useful verification commands:

```bash
kubectl -n argocd get applications
kubectl -n atlas get deploy,po,svc,cronjob,ingress
kubectl -n atlas rollout status deploy/atlas-api-api-service
```

## End-to-End Validation

The detailed validation flow is documented in
[docs/e2e-test-runbook.md](docs/e2e-test-runbook.md).

At a high level, the system is working when:

- Terraform provisions the dev environment successfully.
- EKS nodes are `Ready`.
- Argo CD deploys `atlas-api` and `atlas-worker`.
- API `/docs` returns HTTP 200.
- `POST /api/v1/sources` creates a source.
- Test data can be inserted into PostgreSQL.
- The worker CronJob can be triggered manually and completes.
- `GET /api/v1/sources/{id}` shows a non-null `latest_result`.
- `GET /api/v1/sources/{id}/history` returns check history.
- S3 contains a JSON report under `reports/`.

Example API validation through a port-forward:

```bash
kubectl -n atlas port-forward svc/atlas-api-api-service 8080:80
```

```bash
curl -i http://localhost:8080/docs

curl -s -X POST http://localhost:8080/api/v1/sources \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "simulated-events",
    "table_name": "simulated_events",
    "timestamp_column": "created_at",
    "expected_frequency_minutes": 15
  }' | jq

curl -s http://localhost:8080/api/v1/sources/1 | jq
curl -s http://localhost:8080/api/v1/sources/1/history | jq
```

Example worker validation:

```bash
export JOB_NAME="atlas-worker-manual-$(date +%s)"

kubectl -n atlas create job \
  --from=cronjob/atlas-worker \
  "$JOB_NAME"

kubectl -n atlas wait --for=condition=complete "job/$JOB_NAME" --timeout=120s
kubectl -n atlas logs "job/$JOB_NAME"
```

Example S3 report check:

```bash
aws s3 ls "s3://$S3_BUCKET/reports/" --recursive
```

## Incident Response Drills 

Current validation status:

- Healthy baseline checks: tested.
- Core Kubernetes triage commands: tested.
- `CrashLoopBackOff` drill: included in the runbook for application crash diagnosis.
- Secret misconfiguration drill: documented, but the current simulation needs revision because it did not reproduce cleanly against the live Deployment.
- `OOMKilled` drill: tested.
- Recovery with `kubectl rollout undo`: included as the standard recovery path after live-cluster drill changes.

The intended response loop is:

1. Capture a healthy baseline.
2. Introduce a controlled failure.
3. Identify the failing workload.
4. Diagnose with `kubectl describe`, logs, events, and rollout history.
5. Recover or roll back.
6. Verify API, worker, database, and S3 behavior after recovery.

## Observability

Current observability foundation:

- kube-prometheus-stack is installed.
- Kubernetes status, events, logs, and rollout history support manual troubleshooting.
- The worker stores durable check history in PostgreSQL.
- The worker uploads JSON reports to S3.
- API liveness and readiness endpoints exist at `/healthz` and `/readyz`.

Known observability gaps:

- No application-level Prometheus metrics yet.
- No custom Grafana dashboards yet.
- No Alertmanager rules for API, worker, stale data, or pod restart symptoms yet.
- Logs are not structured JSON yet.

## Security / Secrets

- Database credentials are stored in Kubernetes Secrets.
- The API uses a SQLAlchemy database URL format:
  `postgresql+psycopg://USER:PASSWORD@HOST:5432/DB`.
- The worker uses a psycopg database URL format:
  `postgresql://USER:PASSWORD@HOST:5432/DB`.
- The worker uses IRSA for S3 report access.
- Argo CD and Helm manifests can reference existing runtime secrets instead of
  creating plaintext secret values in Git.

Useful checks that do not expose secret values:

```bash
kubectl -n atlas get secret atlas-api-secret atlas-worker-secret
kubectl -n atlas describe sa atlas-worker
```

## Cleanup

Destroy the dev environment when it is no longer needed to avoid ongoing AWS
costs:

```bash
cd /infra-roadmap/phase-2/atlas/terraform/environments/aws/dev
terraform destroy -var-file=dev.tfvars
```

Before destroying, confirm whether the S3 bucket is expected to be emptied or
retained, and delete temporary manual worker Jobs if they are no longer needed.

## Known Limitations

- No production DNS or TLS configured by default.
- Ingress uses `atlas.local` for test routing.
- Runtime secret creation is still manual.
- No full application-level metrics yet.
- No automated alerting rules yet.
- No CI/CD pipeline for image build, push, and manifest tag updates yet.
- Database tables are created through SQLAlchemy `create_all`, not a migration tool.

## Future Improvements

- Add Alembic migrations.
- Add Prometheus metrics to the API and worker.
- Add Grafana dashboards.
- Add Alertmanager rules.
- Add GitHub Actions for image build, push, and manifest tag updates.
- Add TLS and real DNS for the ALB Ingress.
- Add External Secrets Operator or AWS Secrets Manager integration.
- Add automated Terraform and Helm validation in CI.

## Supporting Docs

- [End-to-end test runbook](docs/e2e-test-runbook.md)
