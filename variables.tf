variable "tenancy_ocid" {
  type        = string
  description = "OCID of your tenancy. To get the value, see https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five"
}

variable "user_ocid" {
  type        = string
  description = "OCID of the user calling the API. To get the value, see https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five"
}

variable "private_key_path" {
  type        = string
  description = "The path (including filename) of the private key stored on your computer. Required if private_key is not defined. For details on how to create and configure keys see https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two and https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#three"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint for the key pair being used. To get the value, see https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#four"
}

variable "region" {
  type        = string
  description = "An OCI region. See https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#top"
}

variable "compartment_ocid" {
  type        = string
  description = "Compartment OCID"
}

variable "vcn_cidr_blocks" {
  type        = list(string)
  description = "VCN CIDR Blocks"
}

variable "subnet_cidr_block" {
  type        = string
  description = "Subnet CIDR Block"
}

variable "ssh_public_key" {
  type        = string
  description = "An SSH public key for use with a virtual machine."
}

variable "instance_shape" {
  type        = string
  description = "An OCI instance type."
}

variable "instance_ocpus" {
  type        = number
  description = "Number of vCPUs to use for a given instance."
}

variable "instance_shape_config_memory_in_gbs" {
  type        = number
  description = "RAM quantity to assign to a given instance."
}

variable "operating_system" {
  type        = string
  description = "Operating System"
}

variable "operating_system_version" {
  type        = string
  description = "8"
}


