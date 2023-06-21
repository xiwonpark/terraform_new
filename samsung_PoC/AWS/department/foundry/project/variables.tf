variable "name" {
    description = "name"
    type = string
}

variable "foundry_01_sn" {
    description = "10.230.130.0/24"
    type = string
}

variable "sg" {
    description = "DEV SG"
    type = string
}

variable "instance_type"{
    description = "Instance Type For Foundry"
    type = list
}

variable "A_project_ip" {
    type = list
}

variable "A_project_hostname" {
    type = list
}

variable "test_project_ip" {
    type = list
}

variable "test_project_hostname" {
    type = list
}

variable "ami" {
    description = "AMI map"
    type = map
}

variable "tags" {
    description = "Foundry Tags"
    type = map
}
