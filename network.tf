# =============================================================================
# Cloud Router & Cloud NAT
# Provides outbound internet access for private GKE nodes (no public IPs).
# =============================================================================

resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# =============================================================================
# VPC Firewall Rules
# Deny-all baseline with explicit allow rules for internal traffic,
# Load Balancer health checks, and IAP SSH tunnelling.
# =============================================================================

# Default deny all ingress — lowest priority acts as a safety net
resource "google_compute_firewall" "deny_all_ingress" {
  name    = "${var.network_name}-deny-all-ingress"
  network = google_compute_network.vpc.name

  priority  = 65534
  direction = "INGRESS"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow all internal VPC traffic (node-to-node, pod-to-pod, service-to-service)
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.name

  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  # Primary subnet + Pod range + Service range
  source_ranges = [
    "10.0.0.0/16",
    "10.1.0.0/16",
    "10.2.0.0/20",
  ]
}

# Allow GCP Load Balancer health check probes to reach GKE nodes
resource "google_compute_firewall" "allow_lb_health_checks" {
  name    = "${var.network_name}-allow-lb-health-checks"
  network = google_compute_network.vpc.name

  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  # Google health check probe IP ranges
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
}

# Allow IAP tunnel traffic for secure SSH administration
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_name}-allow-iap-ssh"
  network = google_compute_network.vpc.name

  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP's IP range
  source_ranges = ["35.235.240.0/20"]
}
