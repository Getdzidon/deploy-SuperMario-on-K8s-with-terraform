# 🚀 Super Mario on AWS EKS with Terraform & GitHub Actions

**By Donatus D. Dzissah**

> 🔄 **This repository can be used as a deployment template for any Docker image to AWS EKS**  
> 👉 See [TEMPLATE-USAGE.md](./TEMPLATE-USAGE.md) for detailed instructions

*Shout out to [sevenajay](https://hub.docker.com/u/sevenajay) for the Super Mario Docker image*

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

## 🔄 Use as Template for Any Application

**This setup is a reusable EKS deployment template!** You can deploy any Docker image or Kubernetes application with minimal modifications.

### 📖 Complete Template Guide
**👉 See [TEMPLATE-USAGE.md](./TEMPLATE-USAGE.md) for detailed instructions on:**
- What's reusable vs. what needs customization
- Step-by-step conversion guide for your application
- Examples for web apps, APIs, microservices, and databases
- Advanced configurations and multi-environment setups

### 🌐 DNS & SSL Setup
**👉 See [DNS-SSL-SETUP.md](./DNS-SSL-SETUP.md) for:**
- Custom domain configuration with Route 53
- SSL certificates with AWS Certificate Manager
- Application Load Balancer with Ingress
- HTTPS redirect and security best practices

### 🎯 Perfect For:
- **Web Applications** (React, Angular, Vue)
- **Backend APIs** (Node.js, Python, Java, Go)
- **Microservices** architectures
- **Databases** (PostgreSQL, MongoDB, Redis)
- **Any Dockerized Application**

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
│   └── mario-deployment.yml     # Single workflow for deploy/destroy
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

### 2. Setup AWS CLI and IAM User

**📖 Complete AWS Setup Guide**
**👉 See [AWS-SETUP.md](./AWS-SETUP.md) for detailed instructions on:**
- Creating IAM user with proper permissions
- Installing AWS CLI on Windows/Linux/Mac
- Configuring credentials and profiles
- Security best practices
- Troubleshooting common issues

**Quick Setup:**
```bash
# 1. Create IAM user 'terraform-user' via AWS Console
# 2. Install AWS CLI
# 3. Configure credentials
aws configure
# 4. Verify setup
aws sts get-caller-identity
```

### 3. **FIRST STEP: Create S3 Bucket for Terraform State**
⚠️ **This must be done before any Terraform operations!**

**Windows:**
```cmd
setup-backend.bat
```

**Linux/Mac:**
```bash
chmod +x setup-backend.sh
./setup-backend.sh
```

**Or create manually:**
```bash
aws s3api create-bucket --bucket mario12-tfstate-bucket --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
aws s3api put-bucket-versioning --bucket mario12-tfstate-bucket --versioning-configuration Status=Enabled
```

### 4. Deploy Super Mario
**Option 1 - Automatic:**
- Push to main branch → Auto-deploys everything

**Option 2 - Manual:**
- Go to GitHub Actions → "Super Mario Deployment"
- Choose "deploy" or "destroy" (type "DESTROY" to confirm)

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

### Single Workflow (`mario-deployment.yml`)
Handles complete deployment in sequence:
1. **Infrastructure**: Creates EKS cluster with Terraform
2. **Application**: Deploys Super Mario to Kubernetes
3. **Health Check**: Verifies deployment status

### Triggers
- **Automatic**: Push to main branch (full deploy)
- **Manual**: GitHub Actions with deploy/destroy options

### Deployment Time
- **Total**: ~15-20 minutes
- **EKS Cluster**: ~15 minutes
- **App Deployment**: ~2-3 minutes

## 🏗️ AWS Services Deployed

This Terraform configuration deploys the following AWS services:

### 1. Amazon EKS (Elastic Kubernetes Service)
- **Resource**: `aws_eks_cluster.eks_cluster`
- **Name**: `MARIO_EKS_CLOUD`
- **Purpose**: Managed Kubernetes control plane
- **Access**: AWS Console → EKS → Clusters → MARIO_EKS_CLOUD
- **Features**: Auto-scaling, security patches, high availability

### 2. EKS Node Group
- **Resource**: `aws_eks_node_group.eks_node_group`
- **Name**: `Node-cloud`
- **Purpose**: Managed worker nodes for running pods
- **Access**: AWS Console → EKS → Clusters → MARIO_EKS_CLOUD → Compute → Node groups
- **Instance Type**: t3.small (configurable)
- **Scaling**: 1-3 nodes (configurable)

### 3. EC2 Instances
- **Resource**: Auto-created by EKS Node Group
- **Type**: t3.small
- **Purpose**: Worker nodes running Kubernetes pods
- **Access**: AWS Console → EC2 → Instances
- **Tags**: kubernetes.io/cluster/MARIO_EKS_CLOUD

### 4. IAM Roles & Policies
- **EKS Cluster Role**: `MARIO_EKS_CLOUD-cluster-role`
  - Policy: AmazonEKSClusterPolicy
  - Access: AWS Console → IAM → Roles
- **Node Group Role**: `MARIO_EKS_CLOUD-node-group-role`
  - Policies: AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly
  - Access: AWS Console → IAM → Roles

### 5. VPC & Networking (Existing)
- **Resource**: Uses default VPC
- **Subnets**: Auto-discovered public subnets
- **Access**: AWS Console → VPC → Your VPCs
- **Security Groups**: Auto-created by EKS

### 6. Load Balancer (Created by Kubernetes)
- **Type**: Network Load Balancer (NLB)
- **Purpose**: External access to Super Mario application
- **Access**: AWS Console → EC2 → Load Balancers
- **Created by**: mario-service LoadBalancer type

### 7. S3 Bucket (Backend)
- **Name**: `mario12-tfstate-bucket`
- **Purpose**: Terraform state storage
- **Access**: AWS Console → S3 → Buckets
- **Features**: Versioning enabled, encryption

### 💰 Cost Estimation
| Service | Instance/Type | Monthly Cost (approx.) |
|---------|---------------|------------------------|
| EKS Cluster | Control Plane | $73 |
| EC2 Instance | t3.small | $15-20 |
| Load Balancer | NLB | $16-25 |
| S3 Storage | State files | <$1 |
| **Total** | | **~$105-120/month** |

### 🔍 Monitoring & Access

**View All Resources:**
```bash
# List EKS clusters
aws eks list-clusters --region eu-central-1

# Describe cluster
aws eks describe-cluster --name MARIO_EKS_CLOUD --region eu-central-1

# List EC2 instances
aws ec2 describe-instances --filters "Name=tag:kubernetes.io/cluster/MARIO_EKS_CLOUD,Values=owned" --region eu-central-1

# List load balancers
aws elbv2 describe-load-balancers --region eu-central-1
```

**AWS Console Navigation:**
1. **EKS**: Services → Elastic Kubernetes Service
2. **EC2**: Services → EC2 → Instances
3. **IAM**: Services → IAM → Roles
4. **VPC**: Services → VPC
5. **Load Balancers**: Services → EC2 → Load Balancers
6. **S3**: Services → S3

## ⚙️ Configuration

### Terraform Variables
Customize deployment in `terraform/variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `eu-central-1` |
| `cluster_name` | EKS cluster name | `Mario_EKS_CLOUD` |
| `instance_types` | EC2 instance types | `["t2.micro", "t3.medium"]` |
| `desired_capacity` | Desired worker nodes | `1` |
| `max_capacity` | Maximum worker nodes | `2` |
| `min_capacity` | Minimum worker nodes | `1` |

### Kubernetes Configuration
- **Replicas**: 3 pods for high availability
- **Resources**: CPU and memory limits configured
- **Health Checks**: Liveness and readiness probes
- **Load Balancer**: AWS Network Load Balancer

## 🌐 Accessing Super Mario Application

### After Deployment Completes:

1. **Get the LoadBalancer URL:**
```bash
aws eks update-kubeconfig --name MARIO_EKS_CLOUD --region eu-central-1
kubectl get service mario-service
```

2. **Find the EXTERNAL-IP:**
```
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                                   PORT(S)
mario-service   LoadBalancer   10.100.xx.xx    a1b2c3d4e5f6-123456789.eu-central-1.elb.amazonaws.com   80:30000/TCP
```

3. **Access Super Mario:**
- Copy the EXTERNAL-IP URL
- Open in your browser: `http://a1b2c3d4e5f6-123456789.eu-central-1.elb.amazonaws.com`
- Wait 2-3 minutes for LoadBalancer to be ready

### Alternative Access Methods:

**Quick Access (No LoadBalancer needed):**
```bash
# 1. Connect to EKS
aws eks update-kubeconfig --name MARIO_EKS_CLOUD --region eu-central-1

# 2. Check if pods are running
kubectl get pods -l app=mario

# 3. Port forward to access locally
kubectl port-forward service/mario-service 8080:80

# 4. Open browser to http://localhost:8080
```

**Direct Pod Access:**
```bash
# Get pod name and port forward directly
kubectl get pods -l app=mario
kubectl port-forward pod/mario-deployment-xxxxx 8080:80
```

**Using Lens IDE (Recommended):**
```bash
# 1. Connect to EKS cluster
aws eks update-kubeconfig --name MARIO_EKS_CLOUD --region eu-central-1

# 2. Open Lens IDE and connect to cluster
# 3. Navigate to: Networking >> Services >> mario-service
# 4. Click "Port Forward" button
# 5. Access Super Mario at http://localhost:8080
```

**NodePort Service (Alternative):**
```bash
# Change service to NodePort temporarily
kubectl patch service mario-service -p '{"spec":{"type":"NodePort"}}'
kubectl get service mario-service
kubectl get nodes -o wide
# Access via NodeIP:NodePort
```

**Check Application Status:**
```bash
kubectl get pods -l app=mario
kubectl logs -l app=mario
```

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
3. **LoadBalancer pending**: Wait 2-3 minutes for AWS to provision
4. **Terraform errors**: Ensure AWS permissions and S3 bucket access

## 🧹 Cleanup

### Option 1: GitHub Actions (Recommended)
1. Go to GitHub Actions
2. Run "Super Mario Deployment"
3. Choose "destroy"
4. Type "DESTROY" to confirm

### Option 2: Manual Cleanup
```bash
# Remove Kubernetes resources first
kubectl delete -f k8s-manifests/

# Then destroy infrastructure
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


## 👨‍💻 Author

**Getdzidon** - [GitHub](https://github.com/Getdzidon/) | [LinkedIn](https://www.linkedin.com/in/donatus-dziedzorm-d-64842941/)

---

⭐ **If you find this project helpful, please give it a star!**

---

### 📧 Connect with me:

[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/donatus-dziedzorm-d-64842941/) [![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Getdzidon/)