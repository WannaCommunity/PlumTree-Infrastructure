variable "gateway_service_names" {
  description = "(optionsl) A list of services to create gateway endpoints for"
  type = list(string)
  default = []
}

variable "interface_service_names" {
  description = "(optionsl) A list of services to create interface endpoints for"
  type = list(string)
  default = []
}

variable "route_table_ids" {
  description = "(optionsl) route tables for gateway endpoints"
  type = list(string)
  default = []
}

variable "subnet_ids" {
  description = "subnets the endpoints should be created in"
  type = list(string)
}
