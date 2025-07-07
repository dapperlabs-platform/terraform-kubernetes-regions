variable "workload_identity_profiles" {
  description = "Profiles used to create kubernetes service accounts with accompanying workload identity labels."
  type = map(
    list(
      object(
        {
          email                           = string
          create_service_account_token    = optional(bool, false)
          automount_service_account_token = optional(bool, false)
        }
      )
    )
  )
  default = {}
}

variable "namespaces" {
  description = "Namespaces to create in the GKE cluster."
  type        = list(string)
  default     = []
}

variable "filestore_storage_class" {
  description = "Enable the GKE Filestore CSI driver."
  type        = bool
  default     = false
}

variable "filestore_tier" {
  description = "The tier of storage to use"
  type        = string
  default     = null
}

