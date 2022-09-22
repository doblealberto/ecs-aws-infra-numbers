
# Configure the AWS Provider

provider "aws" {
  region = var.aws_region
}
locals {
  project_name = "${var.project_name}-${terraform.workspace}"

  common_tags = {
    Environment = terraform.workspace
    Project     = var.project_name
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}
module "network" {
    source = "./modules/network"

    aws_region = var.aws_region
    project_name = local.project_name

# outputs:
#   - subnetgroup_db_name
#   - private_a_subnet_id
#   - public_a_subnet_id
#   - private_b_subnet_id
#   - subnet_private_a_cidr_block
#   - subnet_private_b_cidr_block
#   - vpc_id
}

module "sgs" {
  source = "./modules/sgs"
  project_name = local.project_name
  vpc_id  = module.network.vpc_id
  subnet_private_a_cidr_block = module.network.subnet_private_a_cidr_block
  subnet_private_b_cidr_block = module.network.subnet_private_b_cidr_block
  depends_on = [
    module.network,
  ]

# outputs: 
#   - rds_security_group_id 
#   - bastion_security_group_id 
#   - ecs_service_security_group_id 

}

module "iam" {
    source = "./modules/iam"
    project_name = local.project_name
}



module "bastion" {
  source = "./modules/bastion"
  project_name = local.project_name

  bastion_security_group_id = module.sgs.bastion_security_group_id 
  public_a_subnet_id = module.network.public_a_subnet_id

  instance_profile_bastion_name = module.iam.instance_profile_bastion_name
  depends_on = [
    module.sgs,
    module.network 
  ]
}

module "database" { 
   source = "./modules/database"
   project_name = local.project_name
   rds_security_group_id  = module.sgs.rds_security_group_id 
   subnetgroup_db_name =  module.network.subnetgroup_db_name
   db_password = var.db_username
   db_username = var.db_password
   depends_on = [
      module.network, 
      module.sgs,
   ]
    


# outputs 
#   - db_host
#   - db_name
#   - db_user
#   - db_pass
#   - port
}

module "ecr" {
   source =  "./modules/ecr"
   project_name = local.project_name

#   outputs: 
#     - proxy_image_url
#     - client_image_url
#     - api_image_url

}


module "ecs" {
    source = "./modules/ecs"
    aws_region = var.aws_region
    project_name = local.project_name

    

    
    api_image_url = module.ecr.client_image_url
    proxy_image_url = module.ecr.proxy_image_url
    client_image_url = module.ecr.client_image_url

    db_host = module.database.db_host
    db_name = module.database.db_name 
    db_user = module.database.db_user
    db_pass = module.database.db_pass
    port = module.database.port

    private_a_subnet_id = module.network.private_a_subnet_id
    private_b_subnet_id = module.network.private_b_subnet_id

    ecs_service_security_group_id = module.sgs.ecs_service_security_group_id 

    ecs_execution_role_arn = module.iam.ecs_execution_role_arn 
    task_role_arn  = module.iam.task_role_arn
    ecs_auto_scaling_role_arn = module.iam.ecs_auto_scaling_role_arn

    dns_name = module.load-balancer.dns_name
    target_group_arn = module.load-balancer.target_group_arn


}

module "load-balancer" {
    source = "./modules/load-balancer"
    project_name = local.project_name
    
    vpc_id = module.network.vpc_id
    private_a_subnet_id = module.network.private_a_subnet_id
    private_b_subnet_id = module.network.private_b_subnet_id
    
    security_groups_lb_id = module.sgs.security_groups_lb_id

    depends_on = [
      module.sgs,
      module.network
    ]
}



# terraform {
#   backend "s3" {
#     bucket         = "final-project-challenge-number-app"
#     key            = "terraform.tfstate"
#     region         = "us-west-1"
#     dynamodb_table = "final-challenge-table"
#   }
#   required_version = ">= 0.13" 
# }








