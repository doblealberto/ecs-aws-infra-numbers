# SIMPLE NUMBER STORAGE

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
## ROUTE TABLES
Allows our subnets to comunicate between then while developing our infrastructure it is important that we define 
both `security groups` and `ingrees and egress` control rules for them in case of an atack it will make the potential resources available for our atacker less in number. In this sense here is a look of one of the `ingress rules` for our postgres database provisioned by managed database `rds`


```
ingress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432

    security_groups = [
      aws_security_group.bastion.id,
      aws_security_group.ecs_service.id,
    ]
```

As we see we give our resource only the access that it needs no more no less.
## Bastion server
Also known as `jump server` gives us the possibility to access our database via a command line interface.
```
resource "aws_key_pair" "bastion_key" {
  key_name   = "${local.prefix}-bastion-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "bastion_key" {
    content  = tls_private_key.rsa.private_key_pem
    filename =  "${local.prefix}-bastion-key"
}
```
in order to access our bastion server we first generated a key value pair that then let's us authenticate via asymetric
encrytion.
## ECR 
Makes the fucntion of our private docker images repository which allows to save our images in a secure way, in order to make it easie to reutilize the image uris we created a module inside the `modules` folder

## ECS
Allow us to manage our docker images in a simple way at the same time while making the right tweeking it could saves us
some money. Ecs allow us to manage our docker images via `tasks definitions` we created a template file that states our 3 resources the content of the file is similar to the following as you see with a little experience on containers its not
hard to understand:
```

[
    {
        "name": "api",
        "image": "${app_image}",
        "essential": true,
        "memoryReservation": 128,
        "environment": [
            {"name": "PG_HOST", "value": "${db_host}"},
            {"name": "PG_DATABASE", "value": "${db_name}"},
            {"name": "PG_USER", "value": "${db_user}"},
            {"name": "PG_PASSWORD", "value": "${db_pass}"},
            {"name": "PG_PORT", "value": "${port}"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "api"
            }
        },
        "portMappings": [
            {
                "containerPort": 5000,
                "hostPort": 5000
            }
        ],
        "mountPoints": [
        ]
    },
]
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


