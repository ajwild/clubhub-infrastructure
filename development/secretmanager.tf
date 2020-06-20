locals {
  secrets = {
    FIREBASE_CLIENT_EMAIL = var.FIREBASE_CLIENT_EMAIL
    FIREBASE_PRIVATE_KEY = var.FIREBASE_PRIVATE_KEY
    FIREBASE_TOKEN = var.FIREBASE_TOKEN
    SESSION_SECRET_CURRENT = var.SESSION_SECRET_CURRENT
    SESSION_SECRET_PREVIOUS = var.SESSION_SECRET_PREVIOUS
    WEB_ENV = var.WEB_ENV
  }
}

resource "google_secret_manager_secret" "secret" {
  for_each = local.secrets

  secret_id = each.key
  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret_version" "secret_version" {
  for_each = local.secrets

  secret = google_secret_manager_secret.secret[each.key].id
  secret_data = each.value
}

# Try to find service account emails programmatically
resource "google_secret_manager_secret_iam_member" "FIREBASE_TOKEN-cloudbuild" {
  secret_id = "FIREBASE_TOKEN"
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${data.google_project.default.number}@cloudbuild.gserviceaccount.com"
}
resource "google_secret_manager_secret_iam_member" "WEB_ENV-cloudbuild" {
  secret_id = "WEB_ENV"
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${data.google_project.default.number}@cloudbuild.gserviceaccount.com"
}
