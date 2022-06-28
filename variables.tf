# ---------------------------------------------------------------------------------------------------------------------
#   Virtual Network // Subnets
# ---------------------------------------------------------------------------------------------------------------------

variable "create_virtual_network" {
  description = "Terraform to create Virtual Network (true) or use an existing Virtual Networks (false)"
  default     = true
}

variable "virtual_network_name" {
  description = "Name of the Azure Virtual Network"
  default     = "prot-westus-vnet-networking00"
}

variable "virtual_network_cidr" {
  description = "Virtual Networks CIDR Block"
  default     = "10.161.88.0/22"
}

variable "create_virtual_network_subnets" {
  description = "Terraform to create Virtual Network subnets (true) or use existing subnets (false)"
  default     = true
}

variable "virtual_network_subnets" {
  description = "Subnet Map for Creation"
  default = {
    management = {
      address_prefixes = ["10.161.89.0/28"]
    },
    private = {
      address_prefixes = ["10.161.89.32/28"]
    },
    public = {
      address_prefixes = ["10.161.89.16/28"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
#   Location
# ---------------------------------------------------------------------------------------------------------------------

variable "resource_location" {
  description = "Location of all resources to be created"
  default     = "westus"
}

# ---------------------------------------------------------------------------------------------------------------------
#   Resource Group
# ---------------------------------------------------------------------------------------------------------------------

variable "create_resource_group" {
  description = "Do you want the Terraform to Create the Resource Group (true) or use an Existing Resource Group (false)"
  default     = true
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  default     = "prot-westus-rg-networking00"
}



# ---------------------------------------------------------------------------------------------------------------------
#   VMSeries - Variables
# ---------------------------------------------------------------------------------------------------------------------


variable "vmseries" {
  description = "Definition of the VM-Series deployments"
  default = {
    vmseries0 = {
      admin_username    = "protera"
      admin_password    = "Test1234!@#$"
      instance_size     = "Standard_DS3_v2"
      # License options "byol", "bundle1", "bundle2"
      license           = "byol"
      version           = "latest"
      management_ip     = "10.161.89.4"
      private_ip        = "10.161.89.36"
      public_ip         = "10.161.89.20"
      # If not licensing authcode is needed leave this set to a value of a space (ie " ")
      authcodes = " "
    }
   }
  }
  
  
 # ---------------------------------------------------------------------------------------------------------------------
#  NSGs
# ---------------------------------------------------------------------------------------------------------------------


    variable "inbound_tcp_ports" {
  default = [443, 80]
}

variable "inbound_udp_ports" {
  default = [500, 4500]
}
