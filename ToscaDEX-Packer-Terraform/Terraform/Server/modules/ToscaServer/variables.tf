variable "vm_name" {
	description = "Name of virtual machine"
	type = string
}

variable "resource_group_name" {
	description = "Name of resource group"
	type = string
}

variable "location" {
	description = "Name of location of the resouce group"
	type = string
}

variable "password" {
	description = "Password of the virtual machine"
	type = string
	sensitive = true
}

variable "img_id" {
	description = "ID of the DEX Agent image"
	type = string
}

variable "subnet_id" {
	description = "ID of the subnet the machine should be in"
	type = string
}