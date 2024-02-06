variable "gcp_svc_key" {
  type    = string
  default = "$PATH" #IAM create user and key
}

variable "gcp_project" {
  type    = string
  default = "my-web"
}

variable "gcp_region" {
  type    = string
  default = "ASIA-SOUTHEAST1"
}
