variable domain_name {
  description = "Domain name"
  default     = "numbersappecs.tk"
}
variable subdomain {
  description = "Subdomain per environment"
  type        = map(string)
  default = {
    prod       =      "prod"
    staging    = "staging"
    dev        = "dev"
  }
}

variable "lb_dns_name" {
   description = "Aplication load balancer dns name"
}

