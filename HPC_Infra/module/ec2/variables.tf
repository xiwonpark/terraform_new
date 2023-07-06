variable "name" {
  description = "Default EC2 Name"
  type        = string
}

variable "bastion_ip" {
  description = "Bastion Server Private IP"
  type        = string
}

variable "awx_controller_ip" {
  description = "AWX Controller IP"
  type        = string
}

variable "public_subnets_id_a" {
  description = "Public Subnet ID - AZ[a]"
  type        = string
}

variable "public_subnets_id_c" {
  description = "Public Subnet ID - AZ[c]"
  type        = string
}

variable "private_subnets_id_a" {
  description = "Private Subnet ID - AZ[a]"
  type        = string
}

variable "private_subnets_id_c" {
  description = "Private Subnet ID - AZ[c]"
  type        = string
}

variable "target_group_vnc" {
  description = "VNC Target Group arn"
  type        = string
}

variable "target_group_awx" {
  description = "AWX Target Group arn"
  type        = string
}

variable "instance_type" {
  description = "AMI List"
  type        = list(any)
}

variable "awx_nodes" {
  description = "AWX Nodes List"
  type        = list(any)
}

variable "awx_nodes_ip" {
  description = "AWX Nodes IP List"
  type        = list(any)
}

variable "ami" {
  description = "AMI Map"
  type        = map(any)
}

variable "tags" {
  description = "Default Tags"
  type        = map(any)
}

variable "sg" {
  description = "Default SG"
  type        = string
}

