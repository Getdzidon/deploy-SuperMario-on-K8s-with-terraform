# 🚀 Super Mario on AWS EKS with Terraform & GitHub Actions

Deploy the legendary Super Mario game on Amazon EKS using Infrastructure as Code (Terraform) and automated CI/CD with GitHub Actions.

![Super Mario](https://imgur.com/Njqsei9.gif)

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Manual Deployment](#-manual-deployment)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Configuration](#-configuration)
- [Monitoring & Troubleshooting](#-monitoring--troubleshooting)
- [Cleanup](#-cleanup)

## 🎯 Project Overview

This project demonstrates modern DevOps practices by deploying a containerized Super Mario game on AWS EKS using:

- **Infrastructure as Code**: Terraform for AWS resource provisioning
- **Container Orchestration**: Kubernetes on Amazon EKS
- **CI/CD Automation**: GitHub Actions for automated deployments
- **Best Practices**: Security, scalability, and monitoring

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions  │───▶│   AWS Account   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │    Terraform     │───▶│   EKS Cluster   │
                       │   (Infrastructure)│    │  (Kubernetes)   │
                       └──────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │  Super Mario    │
                                               │   Application   │
                                               └─────────────────┘
```

## 📁 Project Structure

```
deploy-SuperMario-on-K8s-with-terraform/
├── terraform/                    # Terraform infrastructure code
│   ├── main.tf                  # EKS cluster and node group
│   ├── provider.tf              # AWS provider configuration
│   ├── backend.tf               # S3 backend for state management
│   ├── variables.tf             # Input variables
│   └── outputs.tf               # Output values
├── k8s-manifests/               # Kubernetes deployment files
│   ├── deployment.yaml          # Super Mario deployment
│   └── service.yaml             # LoadBalancer service
├── .github/workflows/           # CI/CD pipeline
│   └── deploy.yml               # GitHub Actions workflow
└── README.md                    # Project documentation
```

## 📋 Prerequisites

### Required Tools
- **Terraform** >= 1.3.0
- **AWS CLI** >= 2.0
- **kubectl** >= 1.24
- **Git**

### AWS Requirements
- AWS Account with appropriate permissions
- S3 bucket for Terraform state (update `terraform/backend.tf`)
- DynamoDB table for state locking (optional but recommended)

### GitHub Secrets (for CI/CD)
Configure these secrets in your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/Getdzidon/deploy-SuperMario-on-K8s-with-terraform.git
cd deploy-SuperMario-on-K8s-with-terraform
```

### 2. Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

### 3. Update Backend Configuration
Edit `terraform/backend.tf` with your S3 bucket details:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "your-region"
  }
}
```

### 4. Deploy with GitHub Actions
Push to main branch to trigger automated deployment, or deploy manually (see below).

## 🛠️ Manual Deployment

### Step 1: Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Step 2: Configure kubectl
```bash
aws eks update-kubeconfig --name EKS_CLOUD --region ap-south-1
```

### Step 3: Deploy Application
```bash
kubectl apply -f k8s-manifests/deployment.yaml
kubectl apply -f k8s-manifests/service.yaml
```

### Step 4: Access Application
```bash
kubectl get service mario-service
# Use the EXTERNAL-IP to access Super Mario in your browser
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **Terraform Plan**: Validates infrastructure changes
2. **Terraform Apply**: Deploys infrastructure (on main branch)
3. **Kubernetes Deploy**: Applies K8s manifests
4. **Health Check**: Verifies deployment status

### Workflow Triggers
- Push to `main` branch (full deployment)
- Pull requests (plan only)
- Manual trigger via GitHub UI

## ⚙️ Configuration

### Terraform Variables
Customize deployment in `terraform/variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `ap-south-1` |
| `cluster_name` | EKS cluster name | `EKS_CLOUD` |
| `instance_types` | EC2 instance types | `["t3.medium"]` |
| `desired_capacity` | Desired worker nodes | `2` |
| `max_capacity` | Maximum worker nodes | `3` |
| `min_capacity` | Minimum worker nodes | `1` |

### Kubernetes Configuration
- **Replicas**: 3 pods for high availability
- **Resources**: CPU and memory limits configured
- **Health Checks**: Liveness and readiness probes
- **Load Balancer**: AWS Network Load Balancer

## 📊 Monitoring & Troubleshooting

### Check Cluster Status
```bash
kubectl get nodes
kubectl get pods
kubectl get services
```

### View Logs
```bash
kubectl logs -l app=mario
kubectl describe pod <pod-name>
```

### Common Issues
1. **Pods not starting**: Check resource limits and node capacity
2. **Service not accessible**: Verify security groups and NLB configuration
3. **Terraform errors**: Ensure AWS permissions and S3 bucket access

## 🧹 Cleanup

### Remove Kubernetes Resources
```bash
kubectl delete -f k8s-manifests/
```

### Destroy Infrastructure
```bash
cd terraform
terraform destroy
```

## 🔗 Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Getdzidon** - [GitHub](https://github.com/Getdzidon/) | [LinkedIn](https://www.linkedin.com/in/donatus-dziedzorm-d-64842941/)

---

⭐ **If you find this project helpful, please give it a star!**

---

### 📧 Connect with me:

[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/donatus-dziedzorm-d-64842941/) [![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Getdzidon/)