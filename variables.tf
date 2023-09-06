# declare a variable for the resource group name
# default should be copilot-terraform-demo
variable "resource_group_name" {
  type    = string
  default = "copilot-terraform-demo"
}

# declare a variable for the location
# default should be westeurope
variable "location" {
  type    = string
  default = "westeurope"
}