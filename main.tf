terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.0.1"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
}

provider "github" {
  owner = var.github_organization
  token = var.github_token
}

resource "google_project_iam_custom_role" "cloud_build_deployer-role" {
  project = var.project_id
  role_id     = "cloud_build_deployer"
  title       = "Cloud Build Deployer Role"
  description = "Grants minimum necessary to deploy a function with Cloud Build"
  permissions = [
    "cloudbuild.builds.get", 
    "cloudfunctions.functions.create", 
    "cloudfunctions.functions.generateUploadUrl",
    "cloudfunctions.functions.get", 
    "cloudfunctions.functions.update", 
    "cloudfunctions.operations.get",
    "iam.serviceAccounts.actAs", 
    "logging.logEntries.create", 
    "logging.logEntries.route", 
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "run.services.getIamPolicy",
    "run.services.setIamPolicy"
  ]
}

resource "google_service_account" "service_account" {
  account_id   = "cloud-build-deployer"
  display_name = "Service Account for Cloud Build Deployer"
  project = var.project_id
}

resource "google_project_iam_member" "admin" {
  project = var.project_id
  role    = google_project_iam_custom_role.cloud_build_deployer-role.name
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_secret_manager_secret" "github_token_secret" {
    project =  var.project_id
    secret_id = var.secret_id

    replication {
      auto {}
    }
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
    secret = google_secret_manager_secret.github_token_secret.id
    secret_data = var.github_token
}


data "google_project" "my_project" {
  project_id = var.project_id
}

data "google_iam_policy" "serviceagent_secretAccessor" {
    binding {
        role = "roles/secretmanager.secretAccessor"
        members = ["serviceAccount:service-${data.google_project.my_project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
    }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  project = google_secret_manager_secret.github_token_secret.project
  secret_id = google_secret_manager_secret.github_token_secret.secret_id
  policy_data = data.google_iam_policy.serviceagent_secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "my_connection" {
    project = var.project_id
    location = var.region
    name = "github"

    github_config {
        app_installation_id = var.installation_id
        authorizer_credential {
            oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
        }
    }
    depends_on = [google_secret_manager_secret_iam_policy.policy]
}


resource "github_app_installation_repository" "some_app_repo" {
  installation_id    = var.installation_id
  repository         = var.repository_name
}

resource "google_cloudbuildv2_repository" "my_repository" {
  project = var.project_id
  location = var.region
  name = var.repository_name
  parent_connection = google_cloudbuildv2_connection.my_connection.name
  remote_uri = var.repository_uri
}

resource "google_cloudbuild_trigger" "repo-trigger" {
  name = var.trigger_name
  location = var.region

  repository_event_config {
    repository = google_cloudbuildv2_repository.my_repository.id
    push {
      branch = "^main$"
    }
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${google_service_account.service_account.email}"

  filename = "cloudbuild.yaml"
}