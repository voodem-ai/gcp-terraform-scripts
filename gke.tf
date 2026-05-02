# Zonal GKE Cluster for lowest possible cost
resource "google_container_cluster" "primary" {
  name     = "ecommerce-best-products-cluster"
  location = var.zone

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1

  # Required to use VPC native networking and Alias IPs (needed for ALB ingress)
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  # Private cluster — nodes have no external IPs, protected from the internet
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_cidr_block
  }

  # Workload Identity — secure, keyless access to GCP services from pods
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Control plane access — open for CI/CD; tighten for production
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All (CI/CD compatible — restrict for production)"
    }
  }

  deletion_protection = false
  depends_on          = [google_project_service.kubernetes]
}

# Add a single node pool with preemptible e2-small instances for minimal cost
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    preemptible  = true
    machine_type = "e2-small"

    # Minimal scopes for basic read-only access + logging
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Workload Identity requires this metadata to be set on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  depends_on = [google_compute_router_nat.nat]
}

