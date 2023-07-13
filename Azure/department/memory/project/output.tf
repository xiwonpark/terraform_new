output "instance_ids_D" {
  description = "D_Project Instance ID"
  value       = azurerm_linux_virtual_machine.D_Project.*.id
}
