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

variable "filestore" {
  description = "The tier of storage to use"
  type = object({
    enabled = optional(bool, false)
    tier    = optional(string, "standard")
  })
  default = {}
}

