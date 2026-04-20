# E-Commerce GCP Infrastructure

This repository contains the authoritative **Terraform Infrastructure as Code (IaC)** required to provision the cloud boundaries, hardware, and traffic routing layer for the E-Commerce Best Products AI ecosystem on the Google Cloud Platform. 

In addition to infrastructure generation, it houses the raw Kubernetes Application Resource Definitions targeting the resulting GKE cluster.

---

## 🏗️ Architecture Matrix

These scripts are carefully tuned to deploy an enterprise-grade Kubernetes topology while constraining the bounds of computation exclusively to minimizing costs via preemptible compute boundaries and zonal deployment limits.

### 🌐 The Cloud Layer (Terraform)
1. **Networking (`vpc.tf`)**: Instantiates a custom logical VPC Network housing dual secondary subnet ranges to natively bridge Kubernetes Service IP management.
2. **Kubernetes (`gke.tf`)**: Constructs a Google Kubernetes Engine Standard zonal cluster. 
    *   **Node Pool Configuration**: Leverages `e2-small` instances utilizing the Spot/Preemptible capability flag, ensuring instances run as long as there is excess capacity on Google Compute Engine, massively cutting hosting costs while autoscale elasticity buffers failures.
3. **Ingress Networking (`k8s-ingress.tf`)**: Allocates a monolithic Global Static IP to permanently pin the Application Load Balancer to a known location for DNS bindings.

### 📂 The Cluster Workload Layer (Kubernetes)
Housed within the `k8s/` boundary, these manifests orchestrate the deployment of the product ecosystem.
*   **Databaseless Configuration**: All data is synthesized at ingestion time utilizing Gemini context boundaries eliminating persistent storage overheads. 
*   **Path Routing Context (`ingress.yaml`)**: An implementation-specific Ingress CRD natively translates to a Google Cloud Http proxy parsing the URL tree. Root level traffic `/*` is siphoned natively into the React App container, while anything under the `/api/*` context path invokes the Client NodePort Orchestration Server implicitly bypassing cross-domain limitations.
*   **System Integrity**: Cloud Native Health hooks deployed via `BackendConfig` ping specific validation endpoints to eject routing artifacts dynamically if individual application instances stall.

---

## 🚀 Execution & Usage

### 1. Prerequisites
Ensure you have installed the core operational logic:
*   [Terraform CLI](https://developer.hashicorp.com/terraform/install)
*   [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install)
*   Valid IAM Authentication credentials mapped to your user instance via `gcloud auth application-default login`.

### 2. Deployment Parameters
Create a `terraform.tfvars` file locally indicating your specific active Google Cloud destination:
```hcl
project_id = "your-gcs-target-project-id"
region     = "us-central1"
zone       = "us-central1-a"
```

### 3. Execution Cycle
1. **Initialize Project Backend**
    ```bash
    terraform init
    ```
2. **Review Infrastructural Deltas**
    ```bash
    terraform plan
    ```
3. **Provision**
    ```bash
    terraform apply
    ```

### 4. Deploying the Containers
After infrastructure provisioning, export cluster context to your CLI via:
```bash
gcloud container clusters get-credentials ecommerce-best-products-cluster --zone us-central1-a
```
Push the secrets boundary into Kubernetes Memory:
```bash
kubectl create secret generic ecommerce-secrets --from-literal=gemini-api-key="YOUR_KEY_HERE"
```
Apply the application limits:
```bash
kubectl apply -f k8s/
```
