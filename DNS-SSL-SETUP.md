# 🌐 DNS & SSL Configuration with Route 53 and ACM

Complete guide for setting up custom domain names with Route 53 and SSL certificates using AWS Certificate Manager (ACM) for your EKS application.

## 📋 Prerequisites

- **Domain Name**: You own a domain (e.g., `example.com`)
- **AWS Route 53**: Domain can be managed by Route 53
- **EKS Cluster**: Already deployed using this template
- **AWS Load Balancer Controller**: Must be enabled (see steps below)

## 🎯 Overview

This setup provides:
- **Custom Domain**: `mario.example.com` instead of AWS LoadBalancer URL
- **SSL/TLS**: HTTPS encryption with valid certificates
- **Automatic Renewal**: ACM handles certificate renewal
- **DNS Management**: Route 53 for reliable DNS resolution

## 🔧 Step 1: Enable AWS Load Balancer Controller

### 1.1 Update Terraform Configuration

**File: `terraform/terraform.tfvars`**
```hcl
# Enable LoadBalancer Controller
enable_load_balancer_controller = true

# Domain Configuration (add these variables)
domain_name = "example.com"
subdomain = "mario"  # Will create mario.example.com
```

### 1.2 Add Domain Variables

**File: `terraform/variables.tf`**
```hcl
variable "domain_name" {
  description = "Root domain name (e.g., example.com)"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain for the application (e.g., mario)"
  type        = string
  default     = "app"
}

variable "create_route53_zone" {
  description = "Create Route 53 hosted zone for the domain"
  type        = bool
  default     = false
}
```

### 1.3 Uncomment LoadBalancer Resources

**File: `terraform/loadbalancer.tf`**
- Uncomment all resources in this file
- This enables the AWS Load Balancer Controller

**File: `terraform/provider.tf`**
- Uncomment the helm, kubernetes, and tls provider configurations

## 🏗️ Step 2: Add Route 53 and ACM Resources

### 2.1 Create Route 53 Configuration

**File: `terraform/route53.tf`**
```hcl
# Data source for existing hosted zone (if domain is already in Route 53)
data "aws_route53_zone" "main" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name
}

# Create hosted zone (only if create_route53_zone is true)
resource "aws_route53_zone" "main" {
  count = var.create_route53_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = var.domain_name
    Environment = var.environment
  }
}

# Local to get the correct hosted zone
locals {
  hosted_zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : (
    var.domain_name != "" ? data.aws_route53_zone.main[0].zone_id : ""
  )
}

# ACM Certificate
resource "aws_acm_certificate" "app_cert" {
  count           = var.domain_name != "" ? 1 : 0
  domain_name     = "${var.subdomain}.${var.domain_name}"
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.subdomain}.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.subdomain}.${var.domain_name}"
    Environment = var.environment
  }
}

# Certificate validation records
resource "aws_route53_record" "cert_validation" {
  for_each = var.domain_name != "" ? {
    for dvo in aws_acm_certificate.app_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.hosted_zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "app_cert" {
  count           = var.domain_name != "" ? 1 : 0
  certificate_arn = aws_acm_certificate.app_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}

# A record pointing to the ALB
resource "aws_route53_record" "app" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = local.hosted_zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = kubernetes_ingress_v1.app_ingress[0].status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [kubernetes_ingress_v1.app_ingress]
}

# Get ALB zone ID
data "aws_elb_hosted_zone_id" "main" {}
```

### 2.2 Add Outputs

**File: `terraform/outputs.tf`**
```hcl
output "domain_name" {
  description = "Application domain name"
  value       = var.domain_name != "" ? "${var.subdomain}.${var.domain_name}" : "Not configured"
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = var.domain_name != "" ? aws_acm_certificate.app_cert[0].arn : "Not created"
}

output "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = var.domain_name != "" ? local.hosted_zone_id : "Not configured"
}

output "nameservers" {
  description = "Route 53 nameservers (if zone was created)"
  value       = var.create_route53_zone ? aws_route53_zone.main[0].name_servers : []
}
```

## 🚀 Step 3: Update Kubernetes Manifests

### 3.1 Create Ingress Resource

**File: `k8s-manifests/ingress.yaml`**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mario-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: ${certificate_arn}
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-2-2017-01
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  rules:
  - host: ${domain_name}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mario-service
            port:
              number: 80
```

### 3.2 Update Service (Remove LoadBalancer)

**File: `k8s-manifests/service.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mario-service
  labels:
    app: mario
spec:
  type: ClusterIP  # Changed from LoadBalancer
  selector:
    app: mario
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
```

### 3.3 Create Ingress Terraform Resource

**File: `terraform/ingress.tf`**
```hcl
# Kubernetes Ingress
resource "kubernetes_ingress_v1" "app_ingress" {
  count = var.domain_name != "" ? 1 : 0

  metadata {
    name      = "mario-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = aws_acm_certificate_validation.app_cert[0].certificate_arn
      "alb.ingress.kubernetes.io/ssl-policy"           = "ELBSecurityPolicy-TLS-1-2-2017-01"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
    }
  }

  spec {
    rule {
      host = "${var.subdomain}.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "mario-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    aws_acm_certificate_validation.app_cert,
    helm_release.aws_load_balancer_controller
  ]
}
```

## 🔧 Step 4: Domain Setup Options

### Option A: Domain Already in Route 53
If your domain is already managed by Route 53:

**File: `terraform/terraform.tfvars`**
```hcl
domain_name = "example.com"
subdomain = "mario"
create_route53_zone = false  # Use existing zone
```

### Option B: New Domain Setup
If you need to create a new hosted zone:

**File: `terraform/terraform.tfvars`**
```hcl
domain_name = "example.com"
subdomain = "mario"
create_route53_zone = true  # Create new zone
```

**Then update your domain registrar:**
1. Run `terraform apply`
2. Note the nameservers from output
3. Update your domain registrar to use Route 53 nameservers

### Option C: External DNS Management
If you manage DNS elsewhere, you'll need to:
1. Create a CNAME record pointing to the ALB hostname
2. Set `create_route53_zone = false`
3. Handle certificate validation manually

## 🚀 Step 5: Deploy with DNS & SSL

### 5.1 Update Terraform Configuration
```bash
cd terraform

# Update terraform.tfvars with your domain settings
# domain_name = "yourdomain.com"
# subdomain = "mario"
# enable_load_balancer_controller = true

terraform plan
terraform apply
```

### 5.2 Update Workflow (Optional)

**File: `.github/workflows/mario-deployment.yml`**
Add domain configuration step:
```yaml
- name: Deploy Ingress
  if: github.event_name == 'push' || github.event.inputs.action == 'deploy'
  run: |
    kubectl apply -f k8s-manifests/ingress.yaml
```

### 5.3 Verify Deployment
```bash
# Check certificate status
aws acm describe-certificate --certificate-arn $(terraform output -raw certificate_arn)

# Check ingress
kubectl get ingress mario-ingress

# Check ALB
kubectl describe ingress mario-ingress
```

## 🔍 Step 6: Testing & Verification

### 6.1 DNS Resolution
```bash
# Test DNS resolution
nslookup mario.yourdomain.com

# Test with dig
dig mario.yourdomain.com
```

### 6.2 SSL Certificate
```bash
# Test SSL certificate
curl -I https://mario.yourdomain.com

# Check certificate details
openssl s_client -connect mario.yourdomain.com:443 -servername mario.yourdomain.com
```

### 6.3 Application Access
- **HTTP**: `http://mario.yourdomain.com` (redirects to HTTPS)
- **HTTPS**: `https://mario.yourdomain.com` (secure access)

## 🛠️ Troubleshooting

### Common Issues

**1. Certificate Validation Timeout**
```bash
# Check validation records
aws route53 list-resource-record-sets --hosted-zone-id $(terraform output -raw hosted_zone_id)

# Check certificate status
aws acm describe-certificate --certificate-arn $(terraform output -raw certificate_arn)
```

**2. Ingress Not Creating ALB**
```bash
# Check AWS Load Balancer Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Check ingress events
kubectl describe ingress mario-ingress
```

**3. DNS Not Resolving**
```bash
# Check Route 53 records
aws route53 list-resource-record-sets --hosted-zone-id $(terraform output -raw hosted_zone_id)

# Verify nameservers
dig NS yourdomain.com
```

## 💰 Cost Considerations

| Service | Monthly Cost |
|---------|-------------|
| Route 53 Hosted Zone | $0.50 |
| Route 53 Queries | $0.40/million |
| ACM Certificate | Free |
| Application Load Balancer | $16-25 |

## 🔒 Security Best Practices

1. **Use Strong SSL Policies**: ELBSecurityPolicy-TLS-1-2-2017-01 or newer
2. **Enable SSL Redirect**: Force HTTPS for all traffic
3. **Certificate Monitoring**: Set up CloudWatch alarms for certificate expiry
4. **DNS Security**: Enable DNSSEC if supported by your registrar

## 📚 Additional Resources

- [AWS Certificate Manager User Guide](https://docs.aws.amazon.com/acm/)
- [Route 53 Developer Guide](https://docs.aws.amazon.com/route53/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

---

**Next Steps**: Your application will be accessible at `https://mario.yourdomain.com` with a valid SSL certificate!