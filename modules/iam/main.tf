
#############################################################
### ECS #####################################################
#############################################################
resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${var.project_name}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving of images and adding to logs"
  policy      = file("${path.module}/policies/task-exec-role.json")
}
resource "aws_iam_role" "task_execution_role" {
  name               = "${var.project_name}-task-exec-role"
  assume_role_policy = file("${path.module}/policies/assume-role-policy.json")
}
resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}
resource "aws_iam_role" "app_iam_role" {
  name               = "${var.project_name}-api-task"
  assume_role_policy = file("${path.module}/policies/assume-role-policy.json")
}

resource "aws_iam_role" "ecs-autoscale-role" {
  name = "${var.project_name}-ecs-scale-application"
  assume_role_policy = file("${path.module}/policies/ecs-auto-scaling-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-autoscale" {
  role = aws_iam_role.ecs-autoscale-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}


#############################################################
### BASTION #################################################
#############################################################

resource "aws_iam_role" "bastion" {
  name               = "${var.project_name}-bastion"
  assume_role_policy = file("${path.module}/policies/instance-profile-policy.json")
}

resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}