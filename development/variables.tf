variable "project" { }
variable "region" {
  default = "us-central1"
}
variable "storage_region" {
  default = "US"
}
variable "run_region" {
  default = "us-central1"
}

variable "credentials" { }

variable "web_app_nickname" { }
variable "web_repository_owner" { }
variable "web_repository_name" { }
variable "web_repository_branch" {
  default = "master"
}

variable "FIREBASE_CLIENT_EMAIL" { }
variable "FIREBASE_PRIVATE_KEY" { }
variable "FIREBASE_TOKEN" { }
variable "SESSION_SECRET_CURRENT" { }
variable "SESSION_SECRET_PREVIOUS" { }
variable "WEB_ENV" { }
