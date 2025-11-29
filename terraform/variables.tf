variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "MARIO_EKS_CLOUD"
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
  default     = "Mario-Node-cloud"
}

variable "instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

# LoadBalancer Configuration (Optional)
variable "enable_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = false # Set to true to enable load balancer controller
}

variable "load_balancer_controller_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "1.4.4"
}

# DNS and SSL Configuration (Uncomment when needed)
# variable "domain_name" {
#   description = "Root domain name (e.g., example.com)"
#   type        = string
#   default     = ""
# }
#
# variable "subdomain" {
#   description = "Subdomain for the application (e.g., mario)"
#   type        = string
#   default     = "app"
# }
#
# variable "create_route53_zone" {
#   description = "Create Route 53 hosted zone for the domain"
#   type        = bool
#   default     = false
# }