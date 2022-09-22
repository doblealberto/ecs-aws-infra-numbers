data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "bastion_key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "../sensitive/${var.project_name}-bastion-key"
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t2.micro"
  user_data            = file("${path.module}/scripts/docker-conf.sh")
  iam_instance_profile = var.instance_profile_bastion_name
  key_name             = "${var.project_name}-bastion-key"
  subnet_id            = var.public_a_subnet_id

  vpc_security_group_ids = [
      var.bastion_security_group_id,
  ]
}


