variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "webserver"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "ARM_SUBSCRIPTION_ID" {
  description = "Variable declaration to read from TF_VAR_ARM_SUBSCRIPTION_ID."
}

variable "ARM_CLIENT_ID" {
  description = "Variable declaration to read from TF_VAR_ARM_CLIENT_ID."
}

variable "ARM_TENANT_ID" {
  description = "Variable declaration to read from TF_VAR_ARM_TENANT_ID."
}
