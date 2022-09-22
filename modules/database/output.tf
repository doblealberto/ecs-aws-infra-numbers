output db_host {
    value = aws_db_instance.main.address
}          

output db_name {
    value = aws_db_instance.main.name
}          

output db_user {
    value = aws_db_instance.main.username
}          

output db_pass {
    value = aws_db_instance.main.password
}          

output port    {
    value = aws_db_instance.main.port
}          
