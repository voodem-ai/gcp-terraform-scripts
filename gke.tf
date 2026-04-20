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
  }
}
