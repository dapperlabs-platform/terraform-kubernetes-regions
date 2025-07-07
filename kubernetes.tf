locals {
  profiles = flatten([
    for namespace, service_accounts in var.workload_identity_profiles :
    [for config in service_accounts : {
      name : element(split("@", config.email), 0)
      email : config.email,
      automount_service_account_token : config.automount_service_account_token,
      create_service_account_token : config.create_service_account_token,
      namespace : namespace,
      project_id : element(split(".", element(split("@", config.email), 1)), 0)
    }]
  ])
  workload_identity_profiles = { for profile in local.profiles : "${profile.namespace}/${profile.email}" => profile }
}

# The namespaces to create
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(concat([
    "sre",
    "argocd",
    "cert-manager",
    "backend",
    "frontend",
    "kyverno",
    "policy-reporter",
    "goldilocks",
  ], var.namespaces))
  metadata {
    name        = each.value
    annotations = { "protected" = "yes" }
    labels = {
      "goldilocks.fairwinds.com/enabled" = "true"
    }
  }
}

# Service account tokens - if mounting is enabled -> should avoid this if possible
resource "kubernetes_secret_v1" "tokens" {
  depends_on = [
    kubernetes_service_account.service_accounts
  ]
  for_each = { for k, v in local.workload_identity_profiles : k => v if v.automount_service_account_token && v.create_service_account_token }

  metadata {
    name = "${each.value.name}-service-account-token"
    annotations = {
      "kubernetes.io/service-account.name" = each.value.name
    }
    namespace = each.value.namespace
  }

  type = "kubernetes.io/service-account-token"
}

# The Kubernetes service account with the WLI annotation to enable workload identity for the defined GCP service accounts
resource "kubernetes_service_account" "service_accounts" {
  depends_on = [
    kubernetes_namespace.namespaces,
  ]
  for_each = local.workload_identity_profiles

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = each.value.email
    }
  }

  automount_service_account_token = each.value.automount_service_account_token
}

# Storage classes
resource "kubernetes_storage_class" "filestore_storage_class" {
  count = var.filestore_storage_class ? 1 : 0

  metadata {
    name = "filestore"
  }
  storage_provisioner = "filestore.csi.storage.gke.io"
  parameters = {
    tier    = var.addons.gcp_filestore_csi_driver_config.tier
    network = "gke-application-cluster-vpc"
  }
}
