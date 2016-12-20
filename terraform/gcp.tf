variable "gcp_image_name" {
  default = "packer-1481128993"
}

variable "gcp_instance_count" {
  default = "1"
}

variable "gcp_region" {
  default = "europe-west1"
}

variable "gcp_region_zone" {
  default = "europe-west1-b"
}

variable "gcp_machine_type" {
  default = "f1-micro"
}

variable "project_name" {
  default = "emerald-mission-151101"
  description = "The ID of the Google Cloud project"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "../gcp.json"
}

variable "gcp_public_key_path" {
  description = "Path to file containing public key"
  default     = "~/.ssh/id_rsa.pub"
}

provider "google" {
  region      = "${var.gcp_region}"
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}

resource "google_compute_http_health_check" "default" {
  name                = "tf-www-basic-check"
  request_path        = "/"
  check_interval_sec  = 1
  healthy_threshold   = 1
  unhealthy_threshold = 10
  timeout_sec         = 1
}

resource "google_compute_target_pool" "default" {
  name          = "tf-www-target-pool"
  instances     = ["${google_compute_instance.nginx.*.self_link}"]
  health_checks = ["${google_compute_http_health_check.default.name}"]
}

resource "google_compute_forwarding_rule" "default" {
  name       = "tf-www-forwarding-rule"
  target     = "${google_compute_target_pool.default.self_link}"
  port_range = "80"
}

resource "google_compute_instance" "nginx" {
  count = "${var.gcp_instance_count}"

  name         = "tf-nginx-${count.index}"
  machine_type = "${var.gcp_machine_type}"
  zone         = "${var.gcp_region_zone}"
  tags         = ["www-node"]

  disk {
    image = "${var.gcp_image_name}"
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.gcp_public_key_path}")}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d -p 9100:9100 --net=\"host\" prom/node-exporter"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
    }
  }
}

resource "google_compute_firewall" "default" {
  name    = "tf-www-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "9100"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["www-node"]
}

output "gcp_load_balancer_address" {
  value = "${google_compute_forwarding_rule.default.ip_address}"
}

output "gcp_instances" {
  value = "${join(" ", google_compute_instance.nginx.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}
