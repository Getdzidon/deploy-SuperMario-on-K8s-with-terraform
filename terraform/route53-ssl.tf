# Route 53 DNS and SSL Certificate Configuration
# Uncomment the resources below to enable custom domain and SSL

# # Domain variables (add to terraform.tfvars when enabling)
# # domain_name = "yourdomain.com"
# # subdomain = "mario"
# # create_route53_zone = false  # Set to true if creating new hosted zone

# # Data source for existing hosted zone
# data "aws_route53_zone" "main" {
#   count = var.domain_name != "" ? 1 : 0
#   name  = var.domain_name
# }

# # Create hosted zone (only if create_route53_zone is true)
# resource "aws_route53_zone" "main" {
#   count = var.create_route53_zone ? 1 : 0
#   name  = var.domain_name

#   tags = {
#     Name        = var.domain_name
#     Environment = var.environment
#     Project     = "Super Mario EKS Deployment"
#   }
# }

# # Local to get the correct hosted zone
# locals {
#   hosted_zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : (
#     var.domain_name != "" ? data.aws_route53_zone.main[0].zone_id : ""
#   )
#   full_domain = var.domain_name != "" ? "${var.subdomain}.${var.domain_name}" : ""
# }

# # ACM Certificate for SSL
# resource "aws_acm_certificate" "app_cert" {
#   count           = var.domain_name != "" ? 1 : 0
#   domain_name     = local.full_domain
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "*.${local.full_domain}"
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name        = local.full_domain
#     Environment = var.environment
#     Project     = "Super Mario EKS Deployment"
#   }
# }

# # Certificate validation DNS records
# resource "aws_route53_record" "cert_validation" {
#   for_each = var.domain_name != "" ? {
#     for dvo in aws_acm_certificate.app_cert[0].domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   } : {}

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = local.hosted_zone_id
# }

# # Certificate validation
# resource "aws_acm_certificate_validation" "app_cert" {
#   count           = var.domain_name != "" ? 1 : 0
#   certificate_arn = aws_acm_certificate.app_cert[0].arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

#   timeouts {
#     create = "5m"
#   }
# }

# # Get ALB zone ID for alias record
# data "aws_elb_hosted_zone_id" "main" {
#   count = var.domain_name != "" ? 1 : 0
# }

# # A record pointing to the Application Load Balancer
# resource "aws_route53_record" "app" {
#   count   = var.domain_name != "" ? 1 : 0
#   zone_id = local.hosted_zone_id
#   name    = local.full_domain
#   type    = "A"

#   alias {
#     name                   = kubernetes_ingress_v1.app_ingress[0].status.0.load_balancer.0.ingress.0.hostname
#     zone_id                = data.aws_elb_hosted_zone_id.main[0].id
#     evaluate_target_health = true
#   }

#   depends_on = [kubernetes_ingress_v1.app_ingress]
# }

# # Kubernetes Ingress for Application Load Balancer
# resource "kubernetes_ingress_v1" "app_ingress" {
#   count = var.domain_name != "" ? 1 : 0

#   metadata {
#     name      = "mario-ingress"
#     namespace = "default"
#     annotations = {
#       "kubernetes.io/ingress.class"                    = "alb"
#       "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
#       "alb.ingress.kubernetes.io/target-type"          = "ip"
#       "alb.ingress.kubernetes.io/certificate-arn"      = aws_acm_certificate_validation.app_cert[0].certificate_arn
#       "alb.ingress.kubernetes.io/ssl-policy"           = "ELBSecurityPolicy-TLS-1-2-2017-01"
#       "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
#       "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
#       "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
#       "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
#     }
#   }

#   spec {
#     rule {
#       host = local.full_domain
#       http {
#         path {
#           path      = "/"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = "mario-service"
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [
#     aws_acm_certificate_validation.app_cert,
#     helm_release.aws_load_balancer_controller
#   ]
# }