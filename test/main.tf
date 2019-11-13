provider "azurestack" {
  # whilst the version attribute is optional, we recommend pinning the Provider version being used
  version = ">=0.9.0"
}

# Create a resource group
resource "azurestack_resource_group" "RDS-rg" {
  name     = "CIO-Validate-basicwindowsvm-rg"
  location = "ssccentral"
}

# Create a virtual network within the resource group
resource "azurestack_virtual_network" "RDS-vnet" {
  name                = "CIO-Validate-basicwindowsvm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurestack_resource_group.RDS-rg.location
  resource_group_name = azurestack_resource_group.RDS-rg.name
}

resource "azurestack_subnet" "paz-snet" {
  name                 = "paz-snet"
  virtual_network_name = azurestack_virtual_network.RDS-vnet.name
  resource_group_name  = azurestack_resource_group.RDS-rg.name
  address_prefix       = "10.0.1.0/24"
}

module "cio-cust" {
  source                       = "../."
  location                     = "ssccentral"
  name                         = "cio-rds01"
  resource_group_name          = azurestack_resource_group.RDS-rg.name
  admin_username               = "azureadmin"
  admin_password               = "Canada123!"
  vm_size                      = "Standard_F2"
  public_ip                    = true
  use_nic_nsg                  = false
  storage_image_reference      = {
    id = "/subscriptions/fa0607f6-0aa3-44b3-8a6f-fff871c65adc/resourceGroups/CIO-DevVMs-rg/providers/Microsoft.Compute/images/Win10InsiderPreview17093"
  }
  # custom_data                  = "${file("./custom.ps1")}"
  nic_subnetName               = azurestack_subnet.paz-snet.name
  nic_vnetName                 = azurestack_virtual_network.RDS-vnet.name
  nic_vnet_resource_group_name = azurestack_resource_group.RDS-rg.name
}
