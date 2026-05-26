# Cloud-Native Internal Developer Platform (IDP) 

## Overview
This repository contains a fully automated, production-grade **Internal Developer Platform (IDP)**. It is designed to optimize developer velocity by abstracting infrastructure complexity, enforcing declarative GitOps patterns, and providing built-in enterprise observability.

The platform follows a **"Golden Path"** approach, allowing developers to focus on code while the platform handles provisioning, security, delivery, and monitoring.

---

## System Architecture

The platform is structured into five core pillars:

### 1. Control Plane & GitOps (ArgoCD)
We utilize **ArgoCD** as our declarative delivery engine.
- **App-of-Apps Pattern**: A root bootstrap application (`bootstrap/root-app.yaml`) manages the entire cluster state by watching the `infrastructure/`, `platform/`, and `workloads/` directories.
- **ApplicationSets**: Dynamically generates Kubernetes resources. Specifically, the **Pull Request Generator** is used to spin up ephemeral "Preview Environments" for every open PR.

### 2. Infrastructure as Code (Terraform & Crossplane)
We employ a hybrid approach to infrastructure provisioning:
- **Modular Terraform**: Located in `infrastructure/terraform/`, these reusable modules (S3, RDS) allow for standardized cloud resource creation across environments.
- **Crossplane**: A Kubernetes-native IaC engine used to manage cloud resources as Custom Resources (CRDs). This allows developers to request a database or bucket directly via a YAML manifest.

### 3. CI/CD & Security (GitHub Actions & Trivy)
Security is shifted left into the CI pipeline.
- **Multi-Stage Docker builds**: Uses `gcr.io/distroless` to ensure minimal attack surfaces.
- **Trivy Integration**: The CI pipeline (`.github/workflows/ci-pipeline.yaml`) scans every image build and **hard-fails** if HIGH or CRITICAL vulnerabilities are found.

### 4. Delivery Engine (Preview Environments)
For every Pull Request, the platform:
1. Creates a unique namespace (`preview-pr-{number}`).
2. Deploys the application workload.
3. Applies a strict **NetworkPolicy** to isolate the preview environment from the rest of the cluster.
4. Automatically cleans up (garbage collects) the namespace when the PR is closed.

### 5. Observability Mesh (LGO Stack)
A unified monitoring tier built on:
- **Prometheus & Grafana**: For metrics collection and visualization.
- **OpenTelemetry (OTel) Collector**: A unified pipeline for traces and metrics, allowing for vendor-neutral observability.
- **ServiceMonitors**: Automated discovery of new workloads for metric scraping.

---

## Directory Structure

```text
cloud-native-idp/
├── .github/workflows/       # CI/CD Pipelines (Trivy, Build, Lint)
├── bootstrap/               # Root GitOps manifests (App-of-Apps)
│   ├── apps/                # Child Applications (Infra, Platform, Previews)
│   └── kind-config.yaml     # Local multi-node cluster spec
├── infrastructure/          # IaC (Terraform & Crossplane)
│   ├── terraform/           # Modular AWS/Cloud modules
│   └── crossplane/          # K8s-native infra providers
├── platform/                # Core services (Ingress, Cert-Manager)
├── templates/               # Reusable scaffolding for workloads
└── workloads/               # Developer microservices (Sample Go app)
```

---

## Getting Started (Local Validation)

### Prerequisites
- Docker Desktop
- Kind (Kubernetes in Docker)
- Kubectl
- Helm

### 1. Spin up the Cluster
```powershell
kind create cluster --config bootstrap/kind-config.yaml --name idp-cluster
```

### 2. Bootstrap the Platform (ArgoCD)
The platform is self-healing. Once ArgoCD is installed, point the root app to your fork:
```powershell
kubectl apply -f bootstrap/root-app.yaml
```

### 3. Access the Dashboards
- **ArgoCD**: `kubectl port-forward svc/argocd-server -n argocd 8080:443` (Pass: `admin` / `D8DWI6uyfGHewjiY`)
- **Grafana**: `kubectl port-forward svc/prometheus-stack-grafana -n observability 3000:80`

---

## Security Mandate
- **Distroless Images**: No shell or package managers in production containers.
- **Non-Root Execution**: All workloads run as UID 1000.
- **Network Isolation**: Default-deny ingress policies for ephemeral environments.

---

## Tech Stack
- **Orchestration**: Kubernetes (Kind)
- **GitOps**: ArgoCD
- **IaC**: Terraform, Crossplane
- **CI/CD**: GitHub Actions
- **Security**: Trivy
- **Observability**: Prometheus, Grafana, OpenTelemetry
- **Language**: Go (Sample Workload)
