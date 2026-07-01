# Atlas End-to-End Test Runbook

This runbook validates the full Atlas flow from an empty AWS/EKS environment to a working API, worker CronJob, database freshness check, and S3 report upload.

## Goal

Atlas is a self-hosted data plane simulator. The expected end-to-end behavior is:

1. Terraform provisions AWS infrastructure: VPC, EKS, RDS PostgreSQL, S3, ECR, Argo CD, AWS Load Balancer Controller, and kube-prometheus-stack.
2. Docker images are built for the API and worker services and pushed to ECR.
3. Argo CD deploys the API Deployment and worker CronJob from Helm charts.
4. The API creates and reads source definitions.
5. The worker checks source freshness, writes check results to PostgreSQL, and uploads a JSON report to S3.

## Prerequisites

Install and configure:

```bash
aws sts get-caller-identity
terraform -version
kubectl version --client
helm version
docker version
jq --version
```

Use the Atlas project directory:

```bash
cd /home/dytan/Projects/infra-roadmap/phase-2/atlas
```

The examples assume:

- AWS region: `ap-southeast-5`
- Terraform environment: `terraform/environments/aws/dev`
- Kubernetes namespace: `atlas`
- API service secret: `atlas-api-secret`
- Worker secret: `atlas-worker-secret`

## 1. Provision Infrastructure

Create a local tfvars file and apply the dev environment:

```bash
cd /home/dytan/Projects/infra-roadmap/phase-2/atlas/terraform/environments/aws/dev

cp dev.tfvars.example dev.tfvars
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

Configure kubectl for the new EKS cluster:

```bash
aws eks update-kubeconfig \
  --region ap-southeast-5 \
  --name "$(terraform output -raw eks_cluster_name)"
```

Verify infrastructure:

```bash
terraform output
kubectl get nodes
kubectl get ns
kubectl get pods -A
```

Success criteria:

- `terraform apply` completes successfully.
- EKS nodes are `Ready`.
- Argo CD pods exist in the `argocd` namespace.
- Monitoring pods exist in the `monitoring` namespace.
- There are no persistent `CrashLoopBackOff` or `ImagePullBackOff` pods in system namespaces.

## 2. Build And Push Docker Images

Get the ECR repository URLs from Terraform:

```bash
cd /home/dytan/Projects/infra-roadmap/phase-2/atlas/terraform/environments/aws/dev
terraform output ecr_repository_urls
```

Build and push API and worker images:

```bash
cd /home/dytan/Projects/infra-roadmap/phase-2/atlas

export AWS_REGION=ap-southeast-5
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export IMAGE_TAG="$(git rev-parse --short HEAD)"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin \
  "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

docker build -t capstone-1-api:"$IMAGE_TAG" services/api-service
docker tag capstone-1-api:"$IMAGE_TAG" \
  "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/capstone-1-api:$IMAGE_TAG"
docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/capstone-1-api:$IMAGE_TAG"

docker build -t capstone-1-worker:"$IMAGE_TAG" services/workers
docker tag capstone-1-worker:"$IMAGE_TAG" \
  "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/capstone-1-worker:$IMAGE_TAG"
docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/capstone-1-worker:$IMAGE_TAG"
```

Update the Argo CD app manifests if the account ID or image tag changed:

- `argocd/apps/api-service-app.yaml`
- `argocd/apps/worker-app.yaml`

Important: Argo CD reads from the Git repository configured in `argocd/root-app.yaml`, not directly from the local working tree. Commit and push image manifest changes before expecting Argo CD to apply them.

Success criteria:

- Both images are pushed to ECR.
- Argo CD manifests reference image repositories and tags that exist in ECR.

## 3. Create Runtime Secrets

The API and worker both need database access, but the URL formats differ:

- API: SQLAlchemy format, `postgresql+psycopg://USER:PASSWORD@HOST:5432/DB`
- Worker: psycopg format, `postgresql://USER:PASSWORD@HOST:5432/DB`

Create Kubernetes secrets from Terraform outputs and the RDS master secret:

```bash
cd /home/dytan/Projects/infra-roadmap/phase-2/atlas/terraform/environments/aws/dev

export RDS_ENDPOINT="$(terraform output -raw rds_endpoint)"
export RDS_SECRET_ARN="$(terraform output -raw rds_master_user_secret_arn)"
export S3_BUCKET="$(terraform output -raw s3_bucket_name)"

export RDS_SECRET_JSON="$(
  aws secretsmanager get-secret-value \
    --secret-id "$RDS_SECRET_ARN" \
    --query SecretString \
    --output text
)"

export DB_USER="$(echo "$RDS_SECRET_JSON" | jq -r .username)"
export DB_PASS="$(echo "$RDS_SECRET_JSON" | jq -r .password)"
export DB_NAME="capstone1"
export DB_HOST="${RDS_ENDPOINT%%:*}"

kubectl create namespace atlas --dry-run=client -o yaml | kubectl apply -f -

kubectl -n atlas create secret generic atlas-api-secret \
  --from-literal=DATABASE_URL="postgresql+psycopg://$DB_USER:$DB_PASS@$DB_HOST:5432/$DB_NAME" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n atlas create secret generic atlas-worker-secret \
  --from-literal=DATABASE_URL="postgresql://$DB_USER:$DB_PASS@$DB_HOST:5432/$DB_NAME" \
  --from-literal=S3_BUCKET="$S3_BUCKET" \
  --dry-run=client -o yaml | kubectl apply -f -
```

Verify:

```bash
kubectl -n atlas get secret atlas-api-secret atlas-worker-secret
```

Success criteria:

- Both secrets exist in the `atlas` namespace.
- `atlas-api-secret` contains `DATABASE_URL`.
- `atlas-worker-secret` contains `DATABASE_URL` and `S3_BUCKET`.

## 4. Deploy With Argo CD

Apply the root app:

```bash
cd /home/dytan/Projects/infra-roadmap/phase-2/atlas
kubectl apply -f argocd/root-app.yaml
```

Watch Argo CD and Atlas resources:

```bash
kubectl -n argocd get applications
kubectl -n atlas get deploy,po,svc,cronjob,sa
```

Expected resources:

- Argo CD applications: `atlas-api`, `atlas-worker`
- API Deployment: `atlas-api-api-service`
- API Service: `atlas-api-api-service`
- Worker CronJob: `atlas-worker`
- Worker ServiceAccount: `atlas-worker`

If the API Deployment, Api Service, CronJob and ServiceAccount is missing, you may have to sync the argocd applications manually

Verify rollout and worker identity:

```bash
kubectl -n atlas rollout status deploy/atlas-api-api-service
kubectl -n atlas describe sa atlas-worker
kubectl -n atlas get cronjob atlas-worker
```

Success criteria:

- API Deployment is available.
- Worker CronJob exists.
- Worker ServiceAccount has the expected EKS IRSA role annotation.
- No Atlas pods are stuck in `ImagePullBackOff`, `CrashLoopBackOff`, or `CreateContainerConfigError`.

## 5. Validate API Behavior

Port-forward the API service:

```bash
kubectl -n atlas port-forward svc/atlas-api-api-service 8080:80
```

In another terminal, verify Swagger and source listing:

```bash
curl -i http://localhost:8080/docs
curl -s http://localhost:8080/api/v1/sources | jq
```

Create a source that points at the built-in `simulated_events` table:

```bash
curl -s -X POST http://localhost:8080/api/v1/sources \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "simulated-events",
    "table_name": "simulated_events",
    "timestamp_column": "created_at",
    "expected_frequency_minutes": 15
  }' | jq
```

Verify the source:

```bash
curl -s http://localhost:8080/api/v1/sources | jq
curl -s http://localhost:8080/api/v1/sources/1 | jq
```

Expected result:

- `/docs` returns HTTP 200.
- `POST /api/v1/sources` returns the created source.
- `GET /api/v1/sources/1` returns the source.
- `latest_result` may be `null` until the worker runs.

## 6. Seed Fresh Test Data

Insert one event into `simulated_events` from inside the cluster:

```bash
kubectl -n atlas run psql-client \
  --rm -i \
  --image=postgres:17 \
  --restart=Never \
  --env="PGPASSWORD=$DB_PASS" \
  -- psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
  -c "INSERT INTO simulated_events (payload) VALUES ('test event');"
```

Success criteria:

- The insert succeeds.
- No RDS connectivity or authentication errors occur.

## 7. Trigger Worker And Verify Results

Create a manual job from the CronJob instead of waiting for the schedule:

```bash
export JOB_NAME="atlas-worker-manual-$(date +%s)"

kubectl -n atlas create job \
  --from=cronjob/atlas-worker \
  "$JOB_NAME"

kubectl -n atlas wait --for=condition=complete "job/$JOB_NAME" --timeout=120s
kubectl -n atlas logs "job/$JOB_NAME"
```

If the job fails, inspect it:

```bash
kubectl -n atlas describe "job/$JOB_NAME"
kubectl -n atlas get pods
```

Verify API check history:

```bash
curl -s http://localhost:8080/api/v1/sources/1 | jq
curl -s http://localhost:8080/api/v1/sources/1/history | jq
```

Expected result:

- The manual worker job completes.
- `GET /api/v1/sources/1` shows a non-null `latest_result`.
- `latest_result.status` is normally `ok` if the inserted event is within `expected_frequency_minutes`.
- `latest_result.status` is `stale` if the latest event is older than the configured frequency.
- `latest_result.status` is `no_data` if the target table has no rows.

## 8. Verify S3 Report

List generated reports:

```bash
aws s3 ls "s3://$S3_BUCKET/reports/" --recursive
```

Inspect a report:

```bash
export REPORT_KEY="<replace-with-key-from-aws-s3-ls>"
aws s3 cp "s3://$S3_BUCKET/$REPORT_KEY" -
```

Success criteria:

- At least one report exists under `reports/YYYY-MM-DD/HH-MM.json`.
- The JSON report includes the worker results for the registered source.

## 9. Overall Success Metrics

The full flow is successful when all of these are true:

- Terraform provisions the dev environment successfully.
- EKS nodes are `Ready`.
- Argo CD deploys `atlas-api` and `atlas-worker`.
- API `/docs` returns HTTP 200.
- `POST /api/v1/sources` creates a source.
- The worker CronJob can be triggered manually and completes.
- `GET /api/v1/sources/{id}` shows a `latest_result`.
- `GET /api/v1/sources/{id}/history` returns check history.
- S3 contains a JSON report under `reports/`.
- There are no persistent image pull, DB connection, RDS security group, or S3 authorization failures.

## Common Failure Points

- Argo CD image tags do not match images pushed to ECR.
- Argo CD is watching GitHub `main`, but local manifest changes were not committed and pushed.
- The API uses the SQLAlchemy database URL format, while the worker uses the psycopg database URL format.
- `atlas-api-secret` or `atlas-worker-secret` is missing because the Argo CD manifests set `secret.create=false`.
- The worker ServiceAccount is missing the IRSA role annotation, causing S3 `AccessDenied`.
- RDS security group or subnet routing prevents pods from reaching PostgreSQL.
- `simulated_events` has no rows, so the expected freshness status is `no_data`, not `ok`.
