data "template_file" "client_id" {
  template = file("/etc/.azure/client_id")
}

data "template_file" "tenant_id" {
  template = file("/etc/.azure/tenant_id")
}

data "template_file" "sub_id" {
  template = file("/etc/.azure/sub_id")
}

resource "aws_key_pair" "webserver-kp" {
  key_name   = "${trimspace(data.template_file.prefix.rendered)}-${var.name}-kp"
  public_key = file("~/.ssh/id_rsa.pub")
}



provider "azurerm" {
  features {}
  client_certificate_path = "/etc/.azure/mycert.pfx"
  subscription_id = "${trimspace(data.template_file.sub_id.rendered)}"
  client_id = "${trimspace(data.template_file.client_id.rendered)}"
  tenant_id = "${trimspace(data.template_file.tenant_id.rendered)}"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  provisioner "file" {
    source = "apache2.sh"
    destination = "/tmp/apache2.sh"
    connection {
      host     = self.public_ip_address
      user     = self.admin_username
      password = self.admin_password
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/apache2.sh",
      "/tmp/apache2.sh",
    ]
    connection {
      host     = self.public_ip_address
      user     = self.admin_username
      password = self.admin_password
    }
  }
}
