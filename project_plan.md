# Project Plan: gcp-terraform-scripts

## 1. Project Overview
**Role:** AI Cloud Solution Architect
**Objective:** Provision GCP infrastructure using Terraform to host a secure Kubernetes cluster (GKE).
**Workloads:** - 1x Frontend UI Application (Publicly Accessible)
- 2x Backend AI Agents (Private/Internal Only)
**AI Development Assistant:** Claude Opus 4.7

## 2. Architecture & Security Strategy
- **Network Isolation:** Create a custom Virtual Private Cloud (VPC) with dedicated subnets.
- **Private GKE Cluster:** Nodes will have internal IP addresses only to protect the backend AI agents.
- **Outbound Connectivity:** Implement Cloud Router and Cloud NAT so private AI agents can fetch external updates or reach external APIs securely.
- **Inbound Connectivity:** Use a GCP Global External HTTP(S) Load Balancer (via GKE Ingress) restricted to route traffic *only* to the Frontend UI pods.
- **Firewall Rules:** Strict ingress rules allowing only Load Balancer health checks and IAP (Identity-Aware Proxy) for administration.

## 3. Execution Phases

### Phase 1: Network Infrastructure Generation (Terraform)
*Prompt the AI to generate `network.tf` and `variables.tf`*
- [x] Define the custom VPC network.
- [x] Define the primary subnet (for GKE nodes) and secondary ranges (for Pods and Services).
- [x] Provision a Cloud Router.
- [x] Provision a Cloud NAT to allow outbound internet access for private nodes.
- [x] Define VPC Firewall rules (deny all ingress by default, allow internal VPC communication, allow external load balancer health checks).

### Phase 2: GKE Cluster Provisioning (Terraform)
*Prompt the AI to generate `gke.tf`*
- [x] Define a google_container_cluster resource (VPC-native).
- [x] Enable `private_cluster_config` (no public IP for nodes, access control for the control plane).
- [x] Configure Workload Identity for secure access to GCP services.
- [x] Define `google_container_node_pool` with autoscaling enabled and appropriate machine types for AI workloads (e.g., standard or GPU-enabled instances depending on agent requirements).

### Phase 3: Kubernetes Networking & Security Deployment
*Prompt the AI to generate `k8s-manifests.tf` or raw YAMLs*
- [x] **Backend AI Agents:** Define Kubernetes `Deployment` and `Service` (Type: `ClusterIP`) for Agent 1 and Agent 2. This ensures they are only reachable within the cluster.
- [x] **Frontend UI:** Define Kubernetes `Deployment` and `Service` (Type: `NodePort` or `ClusterIP` depending on Ingress).
- [x] **Ingress Configuration:** Define a Kubernetes `Ingress` resource mapped *only* to the Frontend UI service, triggering GCP to provision an External Load Balancer.

### Phase 4: AI Collaboration & Code Review
- [x] Feed plan to AI assistant step-by-step to generate Terraform HCL.
- [ ] Run `terraform init`, `terraform plan`, and review output for security compliance.
- [ ] Run `terraform apply` to provision the environment.