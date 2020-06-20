resource "google_firebase_project" "default" {
  provider = google-beta
}

resource "google_firebase_web_app" "default" {
  provider = google-beta
  display_name = var.web_app_nickname
}

data "google_firebase_web_app_config" "default" {
  provider = google-beta
  web_app_id = google_firebase_web_app.default.app_id
}

# resource "google_storage_bucket" "default" {
#   provider = google-beta
#   name = "${data.google_project.default.project_id}-${var.web_app_nickname}"
#   location = var.storage_region
# }

# resource "google_storage_bucket_object" "default" {
#   provider = google-beta
#   bucket = google_storage_bucket.default.name
#   name = "firebase-config.json"

#   content = jsonencode({
#     projectId = data.google_project.default.project_id
#     appId = google_firebase_web_app.default.app_id
#     apiKey = data.google_firebase_web_app_config.default.api_key
#     authDomain = data.google_firebase_web_app_config.default.auth_domain
#     databaseURL = lookup(data.google_firebase_web_app_config.default, "database_url", "")
#     storageBucket = lookup(data.google_firebase_web_app_config.default, "storage_bucket", "")
#     messagingSenderId = lookup(data.google_firebase_web_app_config.default, "messaging_sender_id", "")
#     measurementId = lookup(data.google_firebase_web_app_config.default, "measurement_id", "")
#   })
# }
