output "proxy_image_url" {
    value = aws_ecr_repository.proxy.repository_url
}

output "client_image_url" {
    value = aws_ecr_repository.frontend.repository_url
}

output "api_image_url" {
    value = aws_ecr_repository.backend.repository_url
}

