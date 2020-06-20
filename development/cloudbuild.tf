resource "google_cloudbuild_trigger" "web_trigger" {
  name = "${var.web_repository_name}-${var.web_repository_branch}"
  provider = google-beta

  github {
    owner = var.web_repository_owner
    name = var.web_repository_name
    push {
      branch = var.web_repository_branch
    }
  }

  build {
    # See if node_modules cache helps once there are more packages installed
    # step {
    #   name = "google/cloud-sdk:alpine"
    #   id = "load-cache"
    #   entrypoint = "bash"
    #   args = [
    #     "-c",
    #     "gsutil cp gs://$PROJECT_ID/$REPO_NAME/package-lock.json previous-package-lock.json && cmp package-lock.json previous-package-lock.json && gsutil cp gs://$PROJECT_ID/$REPO_NAME/node-modules.tar.gz - | tar -xz || exit 0",
    #   ]
    # }
    step {
      name = "google/cloud-sdk:alpine"
      id = "load-secrets"
      wait_for = [
        "-",
      ]
      entrypoint = "bash"
      args = [
        "-c",
        "gcloud secrets versions access latest --secret WEB_ENV > .env && gcloud secrets versions access latest --secret FIREBASE_TOKEN > .FIREBASE_TOKEN",
      ]
    }
    step {
      name = "node:12-alpine"
      id = "install"
      wait_for = [
        "-",
      ]
      entrypoint = "npm"
      args = [
        "install",
      ]
    }
    step {
      name = "node:12-alpine"
      id = "test"
      wait_for = [
        "install",
      ]
      entrypoint = "npm"
      args = [
        "test",
      ]
    }
    step {
      name = "gcr.io/kaniko-project/executor:latest"
      id = "build-image"
      wait_for = [
        "load-secrets",
        # Potential issue when building Docker image while installing node_modules in /workspace
        # error building image: error building stage: lstat /workspace/node_modules/file-uri-to-path: no such file or directory
        # error building image: error building stage: failed to get files used from context: failed to resolve sources: resolving sources: lstat /workspace/node_modules/.staging/glob-630fb191: no such file or directory
        "install",
      ]
      args = [
        "--destination=gcr.io/$PROJECT_ID/$REPO_NAME:$SHORT_SHA",
        "--cache=true",
      ]
    }
    step {
      name = "google/cloud-sdk:alpine"
      id = "deploy-image"
      wait_for = [
        "test",
        "build-image",
      ]
      entrypoint = "gcloud"
      args = [
        "run",
        "deploy",
        "$REPO_NAME",
        "--image",
        "gcr.io/$PROJECT_ID/$REPO_NAME:$SHORT_SHA",
        "--region",
        var.run_region,
        "--platform",
        "managed",
        "--allow-unauthenticated",
      ]
    }
    step {
      name = "docker:stable"
      id = "prepare-hosting"
      wait_for = [
        "build-image",
      ]
      entrypoint = "sh"
      args = [
        "-c",
        "docker cp $(docker create gcr.io/$PROJECT_ID/$REPO_NAME:$SHORT_SHA):/usr/src/app/.next/static ./public/_next/",
      ]
    }
    step {
      name = "node:12-alpine"
      id = "deploy-hosting"
      wait_for = [
        "test",
        "prepare-hosting",
        "deploy-image",
      ]
      entrypoint = "sh"
      args = [
        "-c",
        "/workspace/node_modules/.bin/firebase deploy --project $PROJECT_ID --token $(cat .FIREBASE_TOKEN) --only hosting",
      ]
    }
    # See if node_modules cache helps once there are more packages installed
    # step {
    #   name = "google/cloud-sdk:alpine"
    #   id = "save-cache"
    #   entrypoint = "bash"
    #   args = [
    #     "-c",
    #     "gsutil cp package-lock.json gs://$PROJECT_ID/$REPO_NAME/package-lock.json && tar -cz node_modules | gsutil cp - gs://$PROJECT_ID/$REPO_NAME/node-modules.tar.gz",
    #   ]
    # }
  }
}
