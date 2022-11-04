variable "resource_group_name" {
  description = "resource group name"
  type = string
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of resource group"
}

variable "vnet_name" {
  default     = "vnet"
  description = "Virtual Network name for weight tracker with load balancer and db vm project"
}

variable "resource_vm_count" {
  default     = 3
  description = "number of resources to be created"
}

variable "backendport" {
  default = 8080
  description = "Backend port of application"
}

variable "sshport" {
   default = 22
   description = "Port for ssh" 
}

variable "db_username" {
  description = "Managed postgres db username"
  type = string 
}

variable "db_password" {
  description = "Managed postgres db password"
  type = string
}

variable "admin_password" {
  description = "VM admin password"
  
}

variable "machine_type" {
  description = "Instance class used"
}

variable "postgres_server_sku" {
  description = "value of the postgres server sku"
}

variable "psqlservername" {
  description = "psql server name"
}