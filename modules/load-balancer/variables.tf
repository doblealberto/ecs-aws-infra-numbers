variable public_a_subnet_id {
    type = string
    description = "Public a subnet id"
} 
variable public_b_subnet_id {
    type = string
    description = "Placeholder description"
} 
variable security_groups_lb_id {
    type = string
    description = "Placeholder description"
} 
variable project_name {
    type = string
    description = "Name of the project"
}

variable vpc_id {
    type = string
    description = "Name of the vpc"
}


# module "load-balancer" {
#     # Modules it depends on.
#     # Networking
#     # vars.
#     # private_a_subnet_id
#     # private_b_subnet_id
#     # security_groups_lb_id
# }
