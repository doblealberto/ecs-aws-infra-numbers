variable project_name {
  type        = string
  description = "Name of the project"
}
variable vpc_id {
  type = string
}

variable subnet_private_a_cidr_block{
    type = string
    description = "placeholder"
}
variable subnet_private_b_cidr_block{
    type = string
    description = "placeholder"
}



# module "sgs" {
#   # Modules it depends on NETWORKING
#   # Vars.
#   # project_name
#   # vpc_id 
# subnet_private_a_cidr_block
# subnet_private_b_cidr_block
# }
