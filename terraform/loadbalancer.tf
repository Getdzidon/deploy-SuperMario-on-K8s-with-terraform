# Optional: AWS Load Balancer Controller for EKS
# Uncomment the resources below to deploy AWS Load Balancer Controller
# This enables automatic provisioning of ALB/NLB when using LoadBalancer services

# # IAM Role for AWS Load Balancer Controller
# resource "aws_iam_role" "aws_load_balancer_controller" {
#   name = "${var.cluster_name}-aws-load-balancer-controller"
# 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.eks.arn
#         }
#         Condition = {
#           StringEquals = {
#             "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
#             "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud": "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
# }
# 
# # IAM Policy for AWS Load Balancer Controller
# resource "aws_iam_policy" "aws_load_balancer_controller" {
#   name        = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
#   description = "IAM policy for AWS Load Balancer Controller"
# 
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "iam:CreateServiceLinkedRole",
#           "ec2:DescribeAccountAttributes",
#           "ec2:DescribeAddresses",
#           "ec2:DescribeAvailabilityZones",
#           "ec2:DescribeInternetGateways",
#           "ec2:DescribeVpcs",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeInstances",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DescribeTags",
#           "ec2:GetCoipPoolUsage",
#           "ec2:DescribeCoipPools",
#           "elasticloadbalancing:DescribeLoadBalancers",
#           "elasticloadbalancing:DescribeLoadBalancerAttributes",
#           "elasticloadbalancing:DescribeListeners",
#           "elasticloadbalancing:DescribeListenerCertificates",
#           "elasticloadbalancing:DescribeSSLPolicies",
#           "elasticloadbalancing:DescribeRules",
#           "elasticloadbalancing:DescribeTargetGroups",
#           "elasticloadbalancing:DescribeTargetGroupAttributes",
#           "elasticloadbalancing:DescribeTargetHealth",
#           "elasticloadbalancing:DescribeTags"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "cognito-idp:DescribeUserPoolClient",
#           "acm:ListCertificates",
#           "acm:DescribeCertificate",
#           "iam:ListServerCertificates",
#           "iam:GetServerCertificate",
#           "waf-regional:GetWebACL",
#           "waf-regional:GetWebACLForResource",
#           "waf-regional:AssociateWebACL",
#           "waf-regional:DisassociateWebACL",
#           "wafv2:GetWebACL",
#           "wafv2:GetWebACLForResource",
#           "wafv2:AssociateWebACL",
#           "wafv2:DisassociateWebACL",
#           "shield:DescribeProtection",
#           "shield:GetSubscriptionState",
#           "shield:DescribeSubscription",
#           "shield:CreateProtection",
#           "shield:DeleteProtection"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:CreateSecurityGroup",
#           "ec2:CreateTags"
#         ]
#         Resource = "arn:aws:ec2:*:*:security-group/*"
#         Condition = {
#           StringEquals = {
#             "ec2:CreateAction" = "CreateSecurityGroup"
#           }
#           Null = {
#             "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
#           }
#         }
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:CreateLoadBalancer",
#           "elasticloadbalancing:CreateTargetGroup"
#         ]
#         Resource = "*"
#         Condition = {
#           Null = {
#             "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
#           }
#         }
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:CreateListener",
#           "elasticloadbalancing:DeleteListener",
#           "elasticloadbalancing:CreateRule",
#           "elasticloadbalancing:DeleteRule"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:AddTags",
#           "elasticloadbalancing:RemoveTags"
#         ]
#         Resource = [
#           "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
#           "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
#           "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
#         ]
#         Condition = {
#           Null = {
#             "aws:RequestTag/elbv2.k8s.aws/cluster" = "true"
#             "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
#           }
#         }
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:AddTags",
#           "elasticloadbalancing:RemoveTags"
#         ]
#         Resource = [
#           "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
#           "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
#           "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
#           "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:ModifyLoadBalancerAttributes",
#           "elasticloadbalancing:SetIpAddressType",
#           "elasticloadbalancing:SetSecurityGroups",
#           "elasticloadbalancing:SetSubnets",
#           "elasticloadbalancing:DeleteLoadBalancer",
#           "elasticloadbalancing:ModifyTargetGroup",
#           "elasticloadbalancing:ModifyTargetGroupAttributes",
#           "elasticloadbalancing:DeleteTargetGroup"
#         ]
#         Resource = "*"
#         Condition = {
#           Null = {
#             "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
#           }
#         }
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:RegisterTargets",
#           "elasticloadbalancing:DeregisterTargets"
#         ]
#         Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:SetWebAcl",
#           "elasticloadbalancing:ModifyListener",
#           "elasticloadbalancing:AddListenerCertificates",
#           "elasticloadbalancing:RemoveListenerCertificates",
#           "elasticloadbalancing:ModifyRule"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
# 
# # Attach policy to role
# resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
#   policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
#   role       = aws_iam_role.aws_load_balancer_controller.name
# }
# 
# # OIDC Provider for EKS
# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# }
# 
# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# 
#   tags = {
#     Name = "${var.cluster_name}-eks-irsa"
#   }
# }
# 
# # Helm provider for installing AWS Load Balancer Controller
# # Note: Requires helm provider configuration in provider.tf
# # resource "helm_release" "aws_load_balancer_controller" {
# #   name       = "aws-load-balancer-controller"
# #   repository = "https://aws.github.io/eks-charts"
# #   chart      = "aws-load-balancer-controller"
# #   namespace  = "kube-system"
# #   version    = "1.4.4"
# # 
# #   set {
# #     name  = "clusterName"
# #     value = aws_eks_cluster.eks_cluster.name
# #   }
# # 
# #   set {
# #     name  = "serviceAccount.create"
# #     value = "true"
# #   }
# # 
# #   set {
# #     name  = "serviceAccount.name"
# #     value = "aws-load-balancer-controller"
# #   }
# # 
# #   set {
# #     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
# #     value = aws_iam_role.aws_load_balancer_controller.arn
# #   }
# # 
# #   depends_on = [
# #     aws_eks_node_group.eks_node_group,
# #     aws_iam_role_policy_attachment.aws_load_balancer_controller,
# #   ]
# # }