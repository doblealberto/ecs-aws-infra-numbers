variable aws_region {
    type = string
    description = "Region of AWS"
}
variable project_name {
    type = string
    description = "Name of the aws project"
}

# module "network" {
#     # Modules it depends on: No one
#     # vars
#     # aws region
#     # project name
#     # outputs:
#     # subnetgroup_db_name
#     # private_a_subnet_id
#     # public_a_subnet_id
#     # private_b_subnet_id
#     # subnet_private_a_cidr_block
#     # subnet_private_b_cidr_block
# }
