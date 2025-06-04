terraform {
  required_version = ">= 1.3.8"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6"
    }
  }
}
