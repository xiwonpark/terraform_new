variable "name" {
    description = "name"
    type = string
}

variable "memory_01_sn" {
    description = "10.230.140.0/24"
    type = string
}

variable "memory_02_sn" {
    description = "10.230.141.0/24"
    type = string
}

variable "sg" {
    description = "DEV SG"
    type = string
}

variable "instance_type"{
    description = "Instance Type For Memory"
    type = list
}

variable "B_project_ip" {
    type = list
}

variable "B_project_hostname" {
    type = list
}

variable "C_project_ip" {
    type = list
}

variable "C_project_hostname" {
    type = list
}

variable "ami" {
    description = "AMI map"
    type = map
}

variable "tags" {
    description = "Memory Tags"
    type = map
}
