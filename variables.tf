variable "project_id" {
  description = "The project ID to deploy resources into"
  type = string
}

variable "region" {
  description = "The region to deploy resources into"
  type = string
}

variable "github_token" {
  description = "The GitHub token to use for Cloud Build"
  type = string
}

variable "secret_id" {
  description = "The secret ID for the GitHub token"
  type = string
  default = "github-token"
}


variable "installation_id" {
  description = "The GitHub App installation ID"
  type = number
}

variable "repository_name" {
  description = "The name of the repository to deploy"
  type = string
}

variable "repository_uri" {
  description = "The URI of the repository to deploy"
  type = string
}

variable "trigger_name" {
  description = "The name of the trigger to create"
  type = string
  default = "repository-trigger"
  
}

variable "github_organization" {
  description = "The GitHub organization"
  type = string
}

variable "gcp_service_list" {
  description = "The list of GCP services to enable"
  type = list(string)
  default=["secretmanager.googleapis.com", "logging.googleapis.com", "cloudfunctions.googleapis.com", "artifactregistry.googleapis.com", "cloudbuild.googleapis.com", "pubsub.googleapis.com", "iam.googleapis.com", "serviceusage.googleapis.com", "iamcredentials.googleapis.com", "cloudresourcemanager.googleapis.com"]
}