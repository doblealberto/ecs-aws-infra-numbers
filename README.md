# SIMPLE NUMBER STORAGE ARCHITECTURE

Its an app running on ECS the architecture of the app is described bellow.
TEST IT YOURSELF: https://dev.numbersappecs.tk/
APPLICATION CODE AT:  https://github.com/doblealberto/numbers-app

![Example Image](https://drive.google.com/uc?id=1-yYZxwOJv__fl8nYLs_LWUPnNJcMgATM)

As we can see we use `ECS` and `ECR` to provision and orchestrate our docker images, we got three images one is `proxy` which is in charge of serving as a reverse proxy for our api and client this enhace security as our clients never get to access both the `backend` and `frontend` of our application.


## AMAZON VPC
Provides a custom space to develop our infrastructure as its stated in the image above we created a total of 4 subnets
in two different availability zones, this architectural design decision helped us to guaranted more `resilience` in our application. `CIDR` block for the vpc is  `10.0.1.0/16` which is kind of and standard value when developing vpc.
## INTERNET GATEWAY
Allows to ingress our resources from the internet.
## NAT GATEWAY
Allows our resources to pull images from our ecr repository and provides `outbound` access for our resources inside 
the vpc. 
## SECURITY GROUPS
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

## ECR 
Makes the fucntion of our private docker images repository which allows to save our images in a secure way, in order to make it easie to reutilize the image uris we created a module inside the `modules` folder

## ECS MODULE
Allow us to manage our docker images in a simple way at the same time while making the right tweeking it could saves us
some money. Ecs allow us to manage our docker images via `tasks definitions` we created a template file that shows the three containers of this specific application, the content of the file is not hard to understand as long as you have some little experience working with docker or k8s.

MODULE OUTPUTS:
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
## CLOUDWATCH
Allows us to provide some `monitoring` and `alerting` to our platfform. in this sense we added a log group for our resources.
```
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-api"

  tags = local.common_tags
}
```
## CI CD AND GITOPS
In this sense we managed it with terraform and `github actions` and `terraform important parts to notice at the workflows are:

```
 - name: Terraform Plan
      id: plan
      env:
        db_username: ${{ secrets.TF_VAR_DB_USERNAME }}
        db_password: ${{ secrets.TF_VAR_DB_PASSWORD }}
        run: |
         terraform workspace ${{ github.ref_name }} || terraform workspace new ${{ github.ref_name }}
         terraform plan -var="db_username=${{ secrets.TF_VAR_DB_USERNAME }}" -var="db_password=${{ secrets.TF_VAR_DB_PASSWORD }}" 
        continue-on-error: true
```
which allows us to define our secrets for our database a better implentation of this could have be to use `vault` or any other secret management tool. At the same time `terraform` allows us to manage `multienvironment` management as stated in the challenge.

A complementary workflow that helps us automate everything is at your dispossal in: https://github.com/doblealberto/numbers-app

```
# ################################################################
# ###################### BUILD and push image ####################
# ################################################################
       - name: Push client frontend
         uses: actions/checkout@v3
         id: push-client-frontend 
         env:
          ECR_REGISTRY: "${{ steps.login-ecr.outputs.registry }}"
          ECR_REPOSITORY: "finalproject-${{ github.ref_name }}-frontend-image"
          IMAGE_TAG: ${{ steps.generate_sha.outputs.sha }}
         run: |
          docker build .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY::latest
```
the most important part in that workflow is maybe this snippet which sends our images to `ECR` in their correct environment and container.


