##########################################################
#### SGS #################################################
##########################################################
variable bastion_security_group_id {
    type = string
    description = "Variable to refer the security group id"
}
variable public_a_subnet_id {
    type = string
    description = "Variable to refer the security group id"
}

variable project_name {
    type = string
    description = "Name of the aws project"
}
##########################################################
#### IAM #################################################
##########################################################
variable instance_profile_bastion_name {
    type = string
    description = "Name of the aws project"
}

# module "bastion" {
#     # Modules it depends on: SGS, NETWORK
#     # Vars: 
#     # bastion_security_group_id
#     # public_a_subnet_id 
# }
