output "validated_certificate_arn" {
    value =  aws_acm_certificate_validation.cert.certificate_arn
}
output "fqdn" {
    value = aws_route53_record.app.fqdn
}
