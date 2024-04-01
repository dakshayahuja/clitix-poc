provider "google" {
  project     = "dakshay-goapptiv"
  region      = "asia-south1"
  credentials = file("demo-sa.json")
}

module "team_dakshay" {
  source            = "./mig_module"
  team_name         = "dakshay"
  health_check_link = google_compute_health_check.example.self_link
}

module "team_manan" {
  source            = "./mig_module"
  team_name         = "manan"
  health_check_link = google_compute_health_check.example.self_link
}

resource "google_compute_health_check" "example" {
  name                = "example-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  tcp_health_check {
    port = "80"
  }
}