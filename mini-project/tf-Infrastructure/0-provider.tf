# GCP Provider
provider "google" {
  credentials = file(var.gcp_svc_key)
  project     = var.gcp_project
  region      = var.gcp_region
}
# For single website
# Enabled identity and access Management API
# Enabled Cloud DNS API
# Enabled Compute Engine API
# Create account add role Basic Owner and create api key to use gcp svc key
