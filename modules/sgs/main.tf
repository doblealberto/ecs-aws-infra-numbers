###############################################
#### DB #######################################
###############################################
resource "aws_security_group" "rds" {
  description = "Allow access to the RDS database instance"
  name        = "${var.project_name}-rds-inbound-access"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432

    security_groups = [
      aws_security_group.bastion.id,
      aws_security_group.ecs_service.id,
    ]
  }

}

###############################################
#### Bastion ##################################
###############################################
resource "aws_security_group" "bastion" {
  description = "Control bastion inbound and outbound access"
  name        = "${var.project_name}-bastion"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.subnet_private_a_cidr_block,
      var.subnet_private_b_cidr_block
    ]
  }
}

###############################################
#### ECS ######################################
###############################################
resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS Service"
  name        = "${var.project_name}-ecs-service"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.subnet_private_a_cidr_block,
      var.subnet_private_b_cidr_block
    ]
  }

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
  }

}

###############################################
#### ALB ######################################
###############################################
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

