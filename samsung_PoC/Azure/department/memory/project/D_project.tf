resource "azurerm_linux_virtual_machine" "D_Project" {
  count = length(var.D_project_ip)

  name                             = var.D_project_hostname[count.index]
  location                         = var.location_kc
  resource_group_name              = var.poc_rg
  size                             = var.vm_size[0]
  network_interface_ids            = [azurerm_network_interface.D_project_NIC[count.index].id]
  source_image_id = lookup(var.image, "RHEL79")
  plan {
    publisher = "procomputers"
    product   = "redhat-7-9-gen2"
    name      = "redhat-7-9-gen2"
  }

  disable_password_authentication = false
  admin_username = "ezadmin"
  admin_password = "AzureTest2023!!"

  os_disk {
    name              = "${var.D_project_hostname[count.index]}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"

    disk_encryption_set_id = var.disk_encryption
  }

  user_data = filebase64("./project/bootstrap.sh")
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

