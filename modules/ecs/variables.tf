##################################################
####### GENERAL ##################################
##################################################
variable project_name {
    type = string
    description = "Name of the project"
}
variable aws_region {
    type = string
    description = "Region of AWS"
}
####################################################
####### ECS ########################################
####################################################

variable api_image_url {
    type = string
    description = "Placeholder description"
} 
variable proxy_image_url {
    type = string
    description = "Placeholder description"
} 
variable client_image_url {
    type = string
    description = "Placeholder description"
} 
#####################################################
####### RDS #########################################
#####################################################
variable db_host {
    type = string
    description = "Placeholder description"
} 
variable db_name {
    type = string
    description = "Placeholder description"
} 
variable db_user {
    type = string
    description = "Placeholder description"
} 
variable db_pass {
    type = string
    description = "Placeholder description"
} 
variable port {
    type = string
    description = "Placeholder description"
}
#####################################################
####### NETWORK #####################################
#####################################################
variable private_a_subnet_id {
    type = string
    description = "Placeholder description"
} 
variable private_b_subnet_id {
    type = string
    description = "Placeholder description"
} 

#####################################################
####### SGS #########################################
#####################################################
variable ecs_service_security_group_id {
    type = string
    description = "Placeholder description"
} 
#####################################################
####### IAM #########################################
#####################################################
variable ecs_execution_role_arn {
    type = string
    description = "Placeholder description"
} 
variable task_role_arn {
    type = string
    description = "Placeholder description"
}

######################################################
####### ALB ##########################################
######################################################

variable target_group_arn {
    type = string
    description = "arn of the alb target group"
}
variable dns_name {
    type = string
    description = "Name of the dns"
}

# module "ecs" {
#     # vars
#     # aws region
#     # project_name
#     # app_image
#     # proxy_image
#     # frontend_image
#     # db_host
#     # db_name
#     # db_user
#     # db_pass
#     # port
#     # private_a_subnet_id
#     # private_b_subnet_id
#     # ecs_service_security_group_id
#     # ecs_execution_role_arn
#     # task_role_arn
#     # project-name

#     # modules it depends on 
#     # ECS
#     # RDS
#     # NETWORK
#     # SGS
#     # IAM
# }

