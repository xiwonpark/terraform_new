output "Memory_Instance_ALL" {
  description = "Instance IDs"
  value = concat(
    module.memory.instance_ids_D
  )
}

output "Memory_instance_project_D" {
  description = "project_D_instance_ids"
  value       = module.memory.instance_ids_D
}
