output dns_name {
    value = aws_lb.api.dns_name
}
output target_group_arn {
    value = aws_lb_target_group.api.arn
}
output lb_arn {
    value = aws_lb.api.arn
}

