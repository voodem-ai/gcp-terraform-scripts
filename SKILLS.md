# Infrastructure Skills & Knowledge

This document catalogs the specific engineering techniques, architectural decisions, and infrastructure philosophies utilized within this repository.

## 1. Cloud-Native Cost Optimization
- **Zonal Clusters:** By explicitly disabling high-availability regional clusters, we eliminate multi-zone control plane replication costs for development and lab environments.
- **Preemptible Node Pools:** The Kubernetes Node Pool strictly utilizes `e2-small` preemptible Google Compute Engine limits. This allows the cluster to tolerate ephemeral node terminations while slashing compute costs by up to 70%.
- **Minimum Resource Scaling:** Initial node counts and minimums are strictly constrained to 1, gracefully autoscaling to a maximum of 2 only when memory constraints are breached.

## 2. Ingress & Traffic Management
- **GCE Ingress Controller Architecture:** Instead of using an Nginx Ingress proxy container which consumes CPU resources, this topology leverages the native GCE ingress controller class. This naturally instantiates a Global Google Application Load Balancer outside the cluster, absorbing network DDoS and freeing up internal pod capacity.
- **BackendConfig:** Employs Custom Kubernetes Resource Definitions (CRDs) via `BackendConfig` to dynamically bind the GCP ALB Health Checks directly to application pods.
- **Path-Based Routing:** The root-level traffic `/*` is routed by the GCE Ingress to the UI service. The UI container utilizes an Nginx reverse proxy to securely route `/api/*` requests internally to the backend services.

## 3. IaC Modularity & Deployment
- Maintains distinct separation of concerns horizontally separating networking (`vpc.tf`), computation (`gke.tf`), and routing objects (`k8s-ingress.tf`).
- **Helm Deployments**: Application workloads are deployed independently using Helm charts, moving deployment configurations closer to the application logic.
