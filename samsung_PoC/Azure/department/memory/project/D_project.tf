resource "azurerm_virtual_machine" "D_Project" {
  count = length(var.D_project_ip)

  name                             = var.D_project_hostname[count.index]
  location                         = var.location_kc
  resource_group_name              = var.poc_rg
  vm_size                          = var.vm_size[0]
  network_interface_ids            = [azurerm_network_interface.D_project_NIC[count.index].id]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "/subscriptions/5e22e437-d178-4e96-b21e-2a21eaac3e1f/resourceGroups/samsung_poc_rg/providers/Microsoft.Compute/galleries/test/images/test/versions/0.0.1"
  }

  storage_os_disk {
    name              = "${var.D_project_hostname[count.index]}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.D_project_hostname[count.index]
    admin_username = "swpark"
    admin_password = "AzureTest2023!!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_network_interface" "D_project_NIC" {
  count                     = length(var.D_project_ip)

  name                      = "${var.D_project_hostname[count.index]}-nic"
  location                  = var.location_kc
  resource_group_name       = var.poc_rg

  ip_configuration {
    name                          = "${var.D_project_hostname[count.index]}-nic-config"
    subnet_id                     = var.memory_03_sn
    private_ip_address_allocation = "Static"
    private_ip_address            = var.D_project_ip[count.index]
  }
}

