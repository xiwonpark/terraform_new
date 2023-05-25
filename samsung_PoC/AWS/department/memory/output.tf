output "Memory_Instance_ALL" {
  description = "Instance IDs"
  value = concat(
    module.memory.instance_ids_B,
    module.memory.instance_ids_C  )
}

output "Memory_instance_project_B" {
  description = "project_B_instance_ids"
  value = module.memory.instance_ids_B
}

output "Memory_Instance_project_C" {
  description = "project_C_instance_ids"
  value = module.memory.instance_ids_C
}
