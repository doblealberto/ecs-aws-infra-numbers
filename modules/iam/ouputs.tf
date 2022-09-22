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
