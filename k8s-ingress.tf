# We provision a global static IP address so that our UI has a permanent entrypoint
resource "google_compute_global_address" "ingress_ip" {
  name = "ecommerce-alb-public-ip"

  depends_on = [google_project_service.compute]
}

output "public_ip" {
  value       = google_compute_global_address.ingress_ip.address
  description = "The public IP address assigned to the ALB Ingress."
}
