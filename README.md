# Infrastructure Learning Roadmap

Phase 1 focuses on fundamentals, first deployments, trials-and-errors. Phase 2 applies those
learned knowledge into building Atlas(It was harder than I thought ngl).

## Phases

| Phase | Focus | Outcome |
| --- | --- | --- |
| [Phase 1](phase-1/README.md) | Docker, Minikube, Kubernetes basics, Helm, Terraform, AWS primitives, Argo CD, monitoring | Built foundational deployment and basic troubleshooting knowledge |
| [Phase 2: Atlas](phase-2/atlas/README.md) | Terraform-managed AWS infrastructure, EKS, RDS, S3, ECR, Helm, Argo CD, API service, worker CronJob | Built a infrastructure capstone project |

## Repository Structure

```text
.
  phase-1/         # Foundational infrastructure experiments and notes
  phase-2/atlas/   # AWS EKS capstone project
```

Key starting points:

- [Phase 1 README](phase-1/README.md)
- [Atlas README](phase-2/atlas/README.md)
- [Atlas end-to-end test runbook](phase-2/atlas/docs/e2e-test-runbook.md)

## What This Demonstrates

- Cloud infrastructure provisioning with Terraform.
- AWS networking, IAM, EKS, ECR, RDS, S3, and ALB usage.
- Kubernetes application deployment and operations.
- Helm-based application packaging.
- GitOps delivery with Argo CD.
- API and worker deployment patterns.
- Database-backed application readiness and worker-generated S3 reports.
- Monitoring foundations.
