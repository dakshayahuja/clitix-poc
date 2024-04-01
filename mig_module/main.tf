data "google_compute_network" "default" {
  name = "default"
}

resource "google_service_account" "instance_service_account" {
  account_id   = "${var.team_name}-instance-account"
  display_name = "Service Account for ${var.team_name} Instance"
  project      = var.project_id
}

resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.instance_service_account.email}"
}


resource "google_compute_instance_template" "team_template" {
  name_prefix  = "${var.team_name}-instance-template-"
  machine_type = "e2-medium"

  disk {
    source_image = "dakshay-goapptiv/debian-docker"
    auto_delete  = true
    boot         = true
  }

  metadata = {
    team_name = var.team_name
  }

  metadata_startup_script = templatefile("${path.module}/script.sh.tpl", {
    TEAM_NAME = var.team_name
  })

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.instance_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "team_mig" {
  name               = "${var.team_name}-mig"
  base_instance_name = "${var.team_name}-instance"
  zone               = "asia-south1-c"
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.team_template.self_link
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = var.health_check_link
    initial_delay_sec = 300
  }
}