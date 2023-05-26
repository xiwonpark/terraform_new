terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.57.0"
    }
  }
}

terraform {
    backend "s3" {
      bucket         = "swtf-tfstate-s3"
      key            = "samsung-poc/Azure/memory/terraform.tfstate"
      region         = "ap-northeast-2"
      encrypt        = true
      dynamodb_table = "tfstate-lock"
    }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true

  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
}

module "memory" {
  source       = "./project"
  name         = "rg-memory"
  memory_03_sn = "/subscriptions/5e22e437-d178-4e96-b21e-2a21eaac3e1f/resourceGroups/samsung_poc_rg/providers/Microsoft.Network/virtualNetworks/TF-PoC-samsung-vnet/subnets/memory_03_pool"
  location_kc  = "koreacentral"
  poc_rg       = "samsung_poc_rg"
  nsg          = "/subscriptions/5e22e437-d178-4e96-b21e-2a21eaac3e1f/resourceGroups/samsung_poc_rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg"

  vm_size = ["Standard_B1s", "Standard_B2s"]

  D_project_ip       = [for line in split("\n", file("./project/DNS/D_project_DNS.txt")) : split(" ", line)[0]]
  D_project_hostname = [for line in split("\n", file("./project/DNS/D_project_DNS.txt")) : split("   ", line)[1]]

  image = {
    RHEL79 = "/subscriptions/5e22e437-d178-4e96-b21e-2a21eaac3e1f/resourceGroups/samsung_poc_rg/providers/Microsoft.Compute/galleries/test/images/test/versions/0.0.1"
    RHEL83 = "TEMP"
  }

  tags = {
    ManagedByTerraform = "true"
    Creator            = "Siwon"
    Email              = "swpark@ezcom.co.kr"
    Module             = "memory"
    project            = "TF PoC"
  }
}
