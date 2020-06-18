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
