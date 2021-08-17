variable "ACCESS_KEY" {
  type        = string
  default     = ""
  description = "AWS accesskey as defined by Environment var TF_VAR_ACCESS_KEY"
}

variable "SECRET_KEY" {
  type        = string
  default     = ""
  description = "AWS secret as defined by Environment var TF_VAR_SECRET_KEY"
}

variable "REGION" {

  type        = string
  default     = "eu-central-1a"
  description = "AWS secret as defined by Environment var TF_VAR_SECRET_KEY"
}

variable "vpc_names" {
    description = "VPC Names"
}

variable "subnet_names" {
    description = "Submnet Names"
}

variable "cidr_blocks" {
    description = "CIDR blocks"
}
variable "private_ips" {
    description = "Private IPs"
}