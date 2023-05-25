output "Foundry_Instance_ALL" {
  description = "Instance IDs"
  value = concat(
    module.foundry.instance_ids_A
  )
}

output "Foundry_instance_project_A" {
  description = "project_A_instance_ids"
  value = module.foundry.instance_ids_A
}