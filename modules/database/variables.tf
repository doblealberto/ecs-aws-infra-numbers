####################################
### Config #########################
####################################
variable db_password {
    description = "password for the db"
}
variable db_username {
    description = "username for the db"
}
variable project_name {
    type = string
    description = "name of the project"
}
###################################
##### SG ##########################
###################################
variable rds_security_group_id {
    type = string
    description = "Security group id for rds"
}
###################################
##### NETWORK #####################
###################################
variable subnetgroup_db_name {
    type = string
    description = "Subnet group for rds"
}


# module "database" {
#     # MODULES IT DEPENDS ON SG, NETWORK
#     # vars it depends on 
#     # project_name
#     # rds_security_group_id
#     # subnetgroup_db_name
# }
