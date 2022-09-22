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