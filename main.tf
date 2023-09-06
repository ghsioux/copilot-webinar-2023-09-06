/*
I want to create a Linux Vitual Machine in Azure
This machine should:
- run the GitHub-Enterprise image;
- be reachable using a public IP address;
- have TCP/22 TCP/80 TCP/443 TCP/8080 TCP/8443 opened;
- have 4 CPU and 32 GB RAM
- have a data disk storage of 500GB
*/

// create the azure resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

// create the azure virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet"
    address_space       = ["10.0.0.0/8"]
    location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
}

// create the azure subnet
resource "azurerm_subnet" "subnet" {
    name                 = "subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

// create the azure public IP
resource "azurerm_public_ip" "publicip" {
    name                = "publicip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
}

// create the azure network interface
resource "azurerm_network_interface" "nic" {
    name                = "nic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "ipconfig"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicip.id
    }
}

// create the azure_linux_virtual_machine resource

resource "azurerm_linux_virtual_machine" "vm" {
    name                = "vm"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size                = "Standard_DS4_v2"
    admin_username      = "adminuser"
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]
    admin_ssh_key {
        username       = "adminuser"
        public_key     = file("~/.ssh/id_rsa.pub")
    }
    source_image_reference {
        publisher = "github"
        offer     = "github-enterprise"
        sku       = "github-enterprise"
        version   = "latest"
    }
    os_disk {
        name              = "osdisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }
}


// create the azure network security group
// add security rule to open port 80
resource "azurerm_network_security_group" "nsg" {
    name                = "nsg"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "http"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    // add rule for port 8080 with unique name
    security_rule {
        name                       = "http8080"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    // add rule for port 443 
    security_rule {
        name                       = "https"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    // add rule for port 8443
    security_rule {
        name                       = "https8443"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    // port 22
    security_rule {
        name                       = "ssh"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

// attach the network security group to the network interface
resource "azurerm_network_interface_security_group_association" "sg" {
    network_interface_id      = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

// create the azure managed disk
resource "azurerm_managed_disk" "disk" {
    name                 = "disk"
    location             = azurerm_resource_group.rg.location
    resource_group_name  = azurerm_resource_group.rg.name
    storage_account_type = "Premium_LRS"
    create_option        = "Empty"
    disk_size_gb         = 500
}

// attach the managed disk to the virtual machine
resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
    managed_disk_id    = azurerm_managed_disk.disk.id
    virtual_machine_id = azurerm_linux_virtual_machine.vm.id
    lun                = 0
    caching            = "ReadWrite"
}