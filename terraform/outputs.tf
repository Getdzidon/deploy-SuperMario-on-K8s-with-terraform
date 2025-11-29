output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "node_group_arn" {
  description = "EKS node group ARN"
  value       = aws_eks_node_group.eks_node_group.arn
}

# DNS and SSL Outputs (Uncomment when DNS/SSL is enabled)
# output "domain_name" {
#   description = "Application domain name"
#   value       = var.domain_name != "" ? "${var.subdomain}.${var.domain_name}" : "Not configured"
# }
#
# output "certificate_arn" {
#   description = "ACM certificate ARN"
#   value       = var.domain_name != "" ? aws_acm_certificate.app_cert[0].arn : "Not created"
# }
#
# output "hosted_zone_id" {
#   description = "Route 53 hosted zone ID"
#   value       = var.domain_name != "" ? local.hosted_zone_id : "Not configured"
# }
#
# output "nameservers" {
#   description = "Route 53 nameservers (if zone was created)"
#   value       = var.create_route53_zone ? aws_route53_zone.main[0].name_servers : []
# }
#
# output "application_url" {
#   description = "Application URL with HTTPS"
#   value       = var.domain_name != "" ? "https://${var.subdomain}.${var.domain_name}" : "Use LoadBalancer URL"
# }