variable "prefix" {
  description = "Prefix to differentiate these nodes."
}

variable "resource-group" {
  description = "Resource Group where the nodes reside."

}

variable "node-count" {
  description = "Number of the nodes."
}

variable "address-starting-index" {
  description = "Offset for private addresses."
  type = number
}

variable "commandToExecute" {
  description = "Command added to the custom data to execute at setup time"
  type = string
  default = "sleep 0"
}

variable "subnet-id" {
  description = "Subnet where the nics are created."
}

variable "node-definition" {
  description = "ssh, size, os information for the nodes."

  default = {
    admin-username = "admin"
    ssh-keypath = "~/.ssh/id_rsa.pub"
    ssh-keypath_private = "~/.ssh/id_rsa"
    size = "Standard_D1_v2"
    disk-type = "Standard_LRS"
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
    docker-version = "18.09"
  }
}