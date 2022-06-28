# ---------------------------------------------------------------------------------------------------------------------
#   Public IPs // Interface --- Management
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_public_ip" "example" {
  name                = "mgmt-pip"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.resource_location
  allocation_method   = "Static"
  depends_on = [azurerm_resource_group.this]
  sku                 = "Standard"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "management" {
  for_each             = var.vmseries
  name                 = "${each.key}-nic-management"
  location             = var.resource_location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this["management"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.management_ip
    public_ip_address_id          = azurerm_public_ip.management[each.key].id
  }
  depends_on = [azurerm_resource_group.this]
}

# Network Security Group (Management)
resource "azurerm_network_interface_security_group_association" "management" {
  for_each                  = var.vmseries
  network_interface_id      = azurerm_network_interface.management[each.key].id
  network_security_group_id = azurerm_network_security_group.management[each.key].id
} 

#----------------------------------------------------------------------------------------------------------------------
# VM-Series - Ethernet0/1 Interface (Untrust)
#----------------------------------------------------------------------------------------------------------------------

resource "azurerm_public_ip" "ethernet_0_1" {
  name                = "nic-ethernet01-pip"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.resource_location
  allocation_method   = "Static"
  depends_on = [azurerm_resource_group.this]
  sku                 = "Standard"

  tags = {
    environment = "Production"
  }
}

# Network Interface
resource "azurerm_network_interface" "ethernet0_1" {
  for_each             = var.vmseries
  name                 = "${each.key}-nic-ethernet01"
  location             = var.resource_location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this["public"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.public_ip
    public_ip_address_id          = azurerm_public_ip.ethernet_0_1.id
  }
  depends_on = [azurerm_resource_group.this]
}

resource "azurerm_network_security_group" "data" {
  for_each            = var.vmseries
  name                = "${each.key}-nsg-allow-all"
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "data-inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "data-outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.this]

}

# Network Security Group (Data)
resource "azurerm_network_interface_security_group_association" "ethernet0_1" {
  for_each                  = var.vmseries
  network_interface_id      = azurerm_network_interface.ethernet0_1[each.key].id
  network_security_group_id = azurerm_network_security_group.data[each.key].id
}

#----------------------------------------------------------------------------------------------------------------------
# VM-Series - Ethernet0/2 Interface (Trust)
#----------------------------------------------------------------------------------------------------------------------

# Network Interface
resource "azurerm_network_interface" "ethernet0_2" {
  for_each             = var.vmseries
  name                 = "${each.key}-nic-ethernet02"
  location             = var.resource_location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = true


  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this["private"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip
  }
  depends_on = [azurerm_resource_group.this]
}

# Network Security Group (Data)
resource "azurerm_network_interface_security_group_association" "ethernet0_2" {
  for_each                  = var.vmseries
  network_interface_id      = azurerm_network_interface.ethernet0_2[each.key].id
  network_security_group_id = azurerm_network_security_group.data[each.key].id
}

#----------------------------------------------------------------------------------------------------------------------
# VM-Series - Virtual Machine
#----------------------------------------------------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "vmseries" {
  for_each = var.vmseries

  # Resource Group & Location:
  resource_group_name = var.resource_group_name
  location            = var.resource_location

  name = "${each.key}-vm"



  # Instance
  size = each.value.instance_size

  # Username and Password Authentication:
  disable_password_authentication = false
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password

  # Network Interfaces:
  network_interface_ids = [
    azurerm_network_interface.management[each.key].id,
    azurerm_network_interface.ethernet0_1[each.key].id,
    azurerm_network_interface.ethernet0_2[each.key].id,
  ]

  plan {
	name      = each.value.license
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = each.value.license
    version   = each.value.version
	#command = "az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan byol"
  }

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }



  # Dependencies:
  depends_on = [
    azurerm_network_interface.ethernet0_2,
    azurerm_network_interface.ethernet0_1,
    azurerm_network_interface.management,
  ]
}

output "vmseries0_management_ip" {
  value = azurerm_public_ip.management["vmseries0"].ip_address
}


