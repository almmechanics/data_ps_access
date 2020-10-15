variable "location" {
  description = "Common resource group to target"
  type        = string
  default     = "centralus"
}

variable "instance" {
  type    = number
  default = 0
}

variable "prefix" {
  type    = string
  default = "datainfra"
}

variable "suffix" {
  type    = string
  default = "aadtest"
}

variable "log_retention_days" {
  type    = number
  default = 365
}
