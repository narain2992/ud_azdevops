variable "packer_resource_group_name" {
   description = "Name of the resource group in which the Packer image will be created"
   default     = "azProjectResourceGroup"
}

variable "packer_image_name" {
   description = "Name of the Packer image"
   default     = "azPrjImage"
}

variable "main_resource_group_name" {
   description = "Name of the resource group in which the Packer image  will be created"
   default     = "azProjectResourceGroup"
}

variable "resource_group_name" {
   description = "Name of the resource group in which the resources will be created"
   default     = "azProjectResource"
}

variable "location" {
   default = "West US 3"
   description = "Location where resources will be created"
}

variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type        = map(string)
   default = {
      dept = "Azure Dev Ops"
      task = "Image deployment"
      environment = "Production"
  }
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   default     = "robrertnick04"
}

variable "admin_password" {
   description = "Default password for admin account"
}

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "azProjectResource"
}

variable "node_count" {
  description = "The number of virtual machines to be created. Number should be minimum of 2 and max of 5."
  default     = 2
}


