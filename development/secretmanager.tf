locals {
  secrets = {
    web_env = var.web_env
    FIREBASE_CLIENT_EMAIL = var.FIREBASE_CLIENT_EMAIL
    FIREBASE_PRIVATE_KEY = var.FIREBASE_PRIVATE_KEY
    SESSION_SECRET_CURRENT = var.SESSION_SECRET_CURRENT
    SESSION_SECRET_PREVIOUS = var.SESSION_SECRET_PREVIOUS
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
