terraform {
  required_version = "0.12.26"

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "clubhub"

    workspaces {
      name = "development"
    }
  }
}

provider "google" {
  version = "3.24"
  credentials = var.credentials
  project = var.project
  region = var.region
}

provider "google-beta" {
  version = "3.24"
  credentials = var.credentials
  project = var.project
  region = var.region
}

locals {
  googleapis = {
    cloudbuild = "cloudbuild.googleapis.com"
    firebase = "firebase.googleapis.com"
    run = "run.googleapis.com"
    secretmanager = "secretmanager.googleapis.com"
    storage = "storage-component.googleapis.com"
  }
}

resource "google_project_service" "default" {
  for_each = local.googleapis

  service = each.value
  disable_dependent_services = true
}

data "google_project" "default" { }
