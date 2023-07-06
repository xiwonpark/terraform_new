variable "name" {
  description = "Default VPC Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "az" {
  description = "Available Zone List"
  type        = list(any)
}

variable "public_subnets" {
  description = "Public Subnets List"
  type        = list(any)
}

variable "private_subnets" {
  description = "Private Subnets List"
  type        = list(any)
}

variable "tags" {
  description = "VPC Module Default Tags"
  type        = map(any)
}

variable "bastion_id" {
  type = string
}