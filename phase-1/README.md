## Phase 1

This phase invovles learning and utilizng the follwing tools and techniques

- Docker
  - Basic Docker commands
  - Basic Docker configs
  - Dockerfile basics

- Minikube(k8s)
  - Basic kubectl commands
    - kubectl:
      - create, spin up something
      - expose, expose to network
      - service, open service
      - describe, get configs
      - logs
      - exec
      - delete
  - Basic k8s configs
    - With liveness and readiness probes

- Helm charts
  - Basic helm commands
    - helm:
      - repo add, add artifact repository
      - repo update, update local repo cache
      - search repo
      - install, install a chart
      - list, list all helm application
      - upgrade, upgrade application
      - uninstall, uninstall and delete resource
      - show values 
      - get values
  - Basic helm configs

- ArgoCD (GitOps)
  - Basics of ArgoCD

- Terraform (IaC)
  - Basic terraform commands
  - Basic terraform configs
    - State, plan, apply and modules

- AWS
  - ECR
  - EC2
  - IAM Policy
  - IAM Role attachements to EC2
  - VPC
    - Subnets
    - Security Groups
      - Traffic bouncer
    - Gateways
      - IGW
      - NAT
    - Route Tables
  - EKS
    - IRSA(IAM Roles for service)
    - ALB Controller

By the end of this phase, I should be able to understand, apply and utilize to the extend of basic use of:
- Docker
- Helm
- Kubernetes
- Terraform (IaC)
- AWS(EC2, ECR, VPC, IAM, EKS, ECS, ALB)
- CI/CD Pipeline
- Networking & Security Groups

Note:
- Simple workflow with helm and kubectl:
  - minikube start -> helm install {release name} or {chart} -> kubectl get pods -> kubectl logs
- When login to aws, need to sudo docker login, docker login doesn't work
- cicd pipeline works
- Stuck on eks deployment, turns out to be missing vpc id for the pods, terraform deployment was done
  - "DDX" the wrong direction from the start, terraform was done, it's the resource, always check the logs first
  - "DDX" procedure:
    - Something is not working
    - Is the pod running? kubectl get pods
    - Why is it not running? kubectl describe pod <name>
    - What is it saying? kubectl logs <name>
  - TLDR:
    - Logs first, always
- ALB Controller: For EKS to manage the ALB itself, restarting container changes IP all the time, ALB controller managed that.
- Anything K8s created needs to be cleaned up through k8s first, i.e. kubectl delete ingress, helm uninstall, finally terraform destroy.
  - TLDR Destroy order:
    - Kubernetes resources before Terraform
- AWS Networking flow involving EKS:
  - VPC Box -> Subnets -> Gateways -> Route tables -> Security group -> EKS Clusters
- IGW & NAT: 
  - IGW: bidirectional, attached to public subnet
  - NAT: unidirectional, allow private subnets talk to outside world only
- Route tables:
  - Public route table:
    - send traffic through Internet Gateway
  - Private route table:
    - send traffic through NAT Gateway from within
- Subnets tags are functional, not just metadata
- ArgoCD, when adding repo using ssh, remember to argocd login localhost:8080
