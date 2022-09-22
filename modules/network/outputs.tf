output subnetgroup_db_name {
    value = aws_db_subnet_group.main.name
}

output private_a_subnet_id{
    value = aws_subnet.private_a.id
}



output private_b_subnet_id{
    value = aws_subnet.private_b.id
}

output public_a_subnet_id{
    value = aws_subnet.public_a.id
}
output public_b_subnet_id{
    value = aws_subnet.public_b.id
}

output subnet_private_a_cidr_block{
    value = aws_subnet.private_a.cidr_block
}
output subnet_private_b_cidr_block{
    value = aws_subnet.private_b.cidr_block
}
output vpc_id {
    value = aws_vpc.main.id
}
