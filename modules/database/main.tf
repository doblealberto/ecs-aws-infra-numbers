resource "aws_db_instance" "main" {
  identifier              = "${var.project_name}-db"
  name                    = "postgres"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "11.12"
  instance_class          = "db.t2.micro"
  db_subnet_group_name    = var.subnetgroup_db_name
  password                = var.db_password
  username                = var.db_username
  backup_retention_period = 0
  multi_az                = false
  skip_final_snapshot     = true
  vpc_security_group_ids  = [var.rds_security_group_id]
}
