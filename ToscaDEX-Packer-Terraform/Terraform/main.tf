# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

variable "resource_group_name" {
  default = "packerTerraform"
}

variable "location" {
  default = "southeastasia"
}

variable "dex_image_name" {
  default = "ToscaWin10_DEXv4_OnPrem"
}
variable "server_image_name" {
  default = "ToscaWin10_v2"
}

variable "password" {
  default   = "P@ssw0rd!1234!"
  sensitive = true
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_image" "dex_img" {
  name                = var.dex_image_name
  resource_group_name = "ToscaWin10"
}
data "azurerm_image" "server_img" {
  name                = var.server_image_name
  resource_group_name = "ToscaWin10"
}

resource "azurerm_virtual_network" "vn" {
  name                = "tosca-network"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "tosca-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

module "DEXAgent" {
	source = "./modules/DEXAgent"
	
	computer_name = "DEX-1"
	vm_name = "DEX"
	resource_group_name = data.azurerm_resource_group.rg.name
	location = data.azurerm_resource_group.rg.location
	subnet_id = azurerm_subnet.subnet.id
	password = var.password
	img_id = data.azurerm_image.dex_img.id
}

module "ToscaServer" {
	source = "./modules/ToscaServer"
	
	vm_name = "ToscaServer"
	resource_group_name = data.azurerm_resource_group.rg.name
	location = data.azurerm_resource_group.rg.location
	subnet_id = azurerm_subnet.subnet.id
	password = var.password
	img_id = data.azurerm_image.server_img.id	
}