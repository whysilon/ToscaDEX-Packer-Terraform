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
  default = "ToscaDEX_v4"
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

data "azurerm_virtual_network" "vn" {
  name                = "tosca-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = "tosca-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vn.name
}
# Add as many as you need
module "DEXAgent-1" {
	source = "./modules/DEXAgent"
	
	computer_name = "DEX-1"
	vm_name = "DEX-1"
	resource_group_name = data.azurerm_resource_group.rg.name
	location = data.azurerm_resource_group.rg.location
	subnet_id = data.azurerm_subnet.subnet.id
	password = var.password
	img_id = data.azurerm_image.dex_img.id
}

module "DEXAgent-2" {
	source = "./modules/DEXAgent"
	
	computer_name = "DEX-2"
	vm_name = "DEX-2"
	resource_group_name = data.azurerm_resource_group.rg.name
	location = data.azurerm_resource_group.rg.location
	subnet_id = data.azurerm_subnet.subnet.id
	password = var.password
	img_id = data.azurerm_image.dex_img.id
}
