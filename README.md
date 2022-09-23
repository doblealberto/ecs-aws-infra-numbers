# SIMPLE NUMBER STORAGE ARCHITECTURE

Its an app running on ECS the architecture of the app is described bellow.
TEST IT YOURSELF: https://dev.numbersappecs.tk/
APPLICATION CODE AT:  https://github.com/doblealberto/numbers-app

![Example Image](https://drive.google.com/uc?id=1-yYZxwOJv__fl8nYLs_LWUPnNJcMgATM)

As we can see we use `ECS` and `ECR` to provision and orchestrate our docker images, we got three images one is `proxy` which is in charge of serving as a reverse proxy for our api and client this enhace security as our clients never get to access both the `backend` and `frontend` of our application.


## IAM MODULE
## MODULE OUTPUTS
```
output ecs_execution_role_arn {
value = aws_iam_role.task_execution_role.arn
}      

output task_role_arn {
value = aws_iam_role.app_iam_role.arn
}

output bastion_role_arn {
value = aws_iam_role.bastion.arn
}

output instance_profile_bastion_name {
value = aws_iam_instance_profile.bastion.name
}

output ecs_auto_scaling_role_arn {
value = aws_iam_role.ecs-autoscale-role.arn
}
```
## DNS MODULE 
To pair our application load balancer dns with our domain `numbersappecs.tk` we have previously created a hosted zone in aws and register our name servers in the domain provider, the final subdomain varies according with de environment we are using we perform a terraform `lookup` function to determine the right prefix for our subdomain 
```
data "aws_route53_zone" "zone" {
  name         = "${var.domain_name}."
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${lookup(var.subdomain, terraform.workspace)}.${data.aws_route53_zone.zone.name}"
  type    = "CNAME"
  ttl     = "60"

  records = [var.lb_dns_name]
}
```
### OUPUTS OF DNS MODULE:
```

output "validated_certificate_arn" {
    value =  aws_acm_certificate_validation.cert.certificate_arn
}
output "fqdn" {
    value = aws_route53_record.app.fqdn
}
```
## SGS MODULE
Control rules for the resources,  in case of an atack this groups will make the potential resources available for our atacker less in number. In this sense here is a look of one of the `security groups` for the `load balancer resource`


```
resource "aws_security_group" "lb" {
  description = "Allow access to Application Load Balancer"
  name        = "${var.project_name}-lb"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  
   ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }

}
```
As we see we give our resource only the access that it needs no more no less.
### MODULE OUPUTS 
```
output rds_security_group_id {
    value = aws_security_group.rds.id
}
output bastion_security_group_id {
    value = aws_security_group.bastion.id
}
output ecs_service_security_group_id {
    value = aws_security_group.ecs_service.id
}

output security_groups_lb_id {
    value = aws_security_group.lb.id
}
```
## BASTION SERVER MODULE
Also known as `jump server` gives us the possibility to access our database via a command line interface.
```
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
```

## ECR MODULE
Creates the repositories for the three images of this project. 
### MODULE OUPUTS:
```
output "proxy_image_url" {
    value = aws_ecr_repository.proxy.repository_url
}

output "client_image_url" {
    value = aws_ecr_repository.frontend.repository_url
}

output "api_image_url" {
    value = aws_ecr_repository.backend.repository_url
}
```


## ECS MODULE
Allow us to manage our docker images in a simple way at the same time while making the right tweeking it could saves us
some money. Ecs allow us to manage our docker images via `tasks definitions` we created a template file that shows the three containers of this specific application, the content of the file is not hard to understand as long as you have some little experience working with docker or k8s.

```
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

    dns_name = module.dns.fqdn
    target_group_arn = module.load-balancer.target_group_arn


}

```
### ECS AUTOSCALING
Autoscaling solution has been performed taking two main metrics.
1. Cpu utilization. (target = 37.3)
2. Ram utilization. (target = 7.83)
Parameters have been set according to mean values of use and in case of a peak the tasks will increment to 5

```

resource "aws_appautoscaling_policy" "ecs_target_cpu" {
  name               = "application-scaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 37.3
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_policy" "ecs_target_memory" {
  name               = "application-scaling-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 7.83
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}
```
## CI CD AND GITOPS
In this sense we managed it with terraform and `github actions` and `terraform important parts to notice at the workflows are:

```
  - name: Terraform Plan
      id: plan
      run: |
        terraform workspace select ${{ github.ref_name }} || workspace new ${{ github.ref_name }}
        terraform plan -var="db_username=${{ secrets.TF_VAR_DB_USERNAME }}" -var="db_password=${{ secrets.TF_VAR_DB_PASSWORD }}"
      continue-on-error: true
      
    - name: Terraform Apply
      id: apply
      run: terraform apply -var="db_username=${{ secrets.TF_VAR_DB_USERNAME }}" -var="db_password=${{ secrets.TF_VAR_DB_PASSWORD }}" -auto-approve 
      continue-on-error: true
```
which allows us to define our secrets for our database a better implentation of this could have be to use `vault` or any other secret management tool. At the same time `terraform` allows us to manage `multienvironment` management as stated in the challenge.

