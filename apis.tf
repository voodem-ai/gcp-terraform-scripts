# Enable Compute Engine API
resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Enable Kubernetes Engine API
resource "google_project_service" "kubernetes" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}
