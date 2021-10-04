provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name                        = "${var.prefix}-resources"
  location                    = var.location
  tags = var.tags
}

resource "azurerm_network_security_group" "main" {
  name                        = "${var.prefix}-nsg"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  tags                        = var.tags
}

# allow inbound traffic within VNET
resource "azurerm_network_security_rule" "vnet" {
  name                        = "AllowTrafficWithinVNET"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.4.0.0/16"
  destination_address_prefix  = "10.4.0.0/16"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# block inbound traffic from internet
resource "azurerm_network_security_rule" "blockinternet" {
  name                        = "BlockAllInternet"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.4.0.0/22"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags = var.tags
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.4.0.0/24"]
}

resource "azurerm_network_interface" "main" {
  count               = "${var.node_count}"
  name                = "${var.prefix}-${format("%02d", count.index)}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  ip_configuration {
    name                          ="${var.prefix}-network"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-backendpool"
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public_ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  tags = var.tags
}


resource "azurerm_lb" "main" {
  name                = "AZProj02LoadBalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-lbfrontend"
    public_ip_address_id = azurerm_public_ip.main.id
  }
  tags = var.tags
}

resource "azurerm_lb_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "${var.prefix}-lbrule"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.prefix}-lbfrontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
}

data "azurerm_resource_group" "image" {
  name                = var.packer_resource_group_name
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = "${var.node_count}"
  name                            = "${var.prefix}-vm-${format("%02d", count.index)}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.admin_user}"
  admin_password                  = "${var.admin_password}"
  disable_password_authentication = false
  availability_set_id             = azurerm_availability_set.main.id
  source_image_id                 = data.azurerm_image.image.id
  network_interface_ids = [
    element(azurerm_network_interface.main.*.id, count.index)
  ]

  os_disk {
    name                 = "${var.prefix}-osdisk-${count.index}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = var.tags
}

resource "azurerm_managed_disk" "main" {
  count                           = "${var.node_count}"
  name                            = "${var.prefix}-datadisk-${count.index}"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.main.name
  storage_account_type            = "Standard_LRS"
  create_option                   = "Empty"
  disk_size_gb                    = 5
  tags                            = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count                           = "${var.node_count}"
  managed_disk_id                 = element(azurerm_managed_disk.main.*.id, count.index)
  virtual_machine_id              = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  lun                             = "0"
  caching                         = "ReadWrite"
}

resource "azurerm_availability_set" "main" {
  name                = "azPrj_availability_set"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags = var.tags
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = "${var.node_count}"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
  ip_configuration_name   = "${var.prefix}-network"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_network_interface_security_group_association" "main" {
  count                     = "${var.node_count}"
  network_interface_id      = element(azurerm_network_interface.main.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.main.id
}
