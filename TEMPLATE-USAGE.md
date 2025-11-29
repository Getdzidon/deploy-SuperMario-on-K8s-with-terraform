# 🔄 Using This Project as a Template

This EKS deployment setup is designed as a **reusable template** for deploying any containerized application on AWS EKS with Terraform and GitHub Actions.

## ✅ What's Already Configured (Reusable):

- **Complete EKS Infrastructure** (cluster, nodes, networking)
- **IAM Roles & Security Policies** (production-ready permissions)
- **CI/CD Pipeline** with GitHub Actions (automated deployment)
- **LoadBalancer Configuration** (AWS NLB integration)
- **Monitoring & Scaling** capabilities
- **Terraform State Management** (S3 backend)

## 🛠️ What to Customize for Your Application:

### 1. Update Docker Image & Application Settings

**File: `k8s-manifests/deployment.yaml`**
```yaml
containers:
- name: your-app-container
  image: your-docker-image:tag  # Replace with your Docker image
  ports:
  - containerPort: 8080         # Change to your application's port
  
  # Adjust resource limits for your app
  resources:
    requests:
      cpu: "200m"
      memory: "256Mi"
    limits:
      cpu: "500m"
      memory: "512Mi"
```

### 2. Update Service Configuration

**File: `k8s-manifests/service.yaml`**
```yaml
spec:
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 8080  # Match your container port
```

### 3. Update Cluster Names & Configuration

**File: `terraform/terraform.tfvars`**
```hcl
# AWS Configuration
aws_region = "eu-central-1"  # Your preferred region
environment = "production"

# EKS Cluster Configuration
cluster_name = "YOUR_APP_EKS_CLOUD"      # Change cluster name
node_group_name = "your-app-nodes"       # Change node group name

# Worker Node Configuration
instance_types = ["t3.small"]            # Adjust instance size
desired_capacity = 2                     # Number of nodes
max_capacity = 3
min_capacity = 1
```

### 4. Update GitHub Actions Workflow

**File: `.github/workflows/mario-deployment.yml`**
```yaml
env:
  AWS_REGION: eu-central-1
  EKS_CLUSTER_NAME: YOUR_APP_EKS_CLOUD  # Match your cluster name
```

### 5. Update S3 Backend Configuration

**File: `terraform/backend.tf`**
```hcl
terraform {
  backend "s3" {
    bucket  = "your-app-tfstate-bucket"  # Change bucket name
    key     = "eks/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
```

## 🎯 Perfect For Deploying:

### Web Applications
- **Frontend**: React, Angular, Vue.js, Static HTML/CSS/JS
- **Full-Stack**: Next.js, Nuxt.js, Django, Rails

### Backend APIs & Services
- **Node.js**: Express, Fastify, NestJS
- **Python**: Flask, Django, FastAPI
- **Java**: Spring Boot, Quarkus
- **Go**: Gin, Echo, Fiber
- **PHP**: Laravel, Symfony
- **Ruby**: Rails, Sinatra

### Databases & Data Services
- **SQL**: PostgreSQL, MySQL, MariaDB
- **NoSQL**: MongoDB, CouchDB
- **Cache**: Redis, Memcached
- **Search**: Elasticsearch, Solr

### Microservices Architecture
- Deploy multiple independent services
- Each service gets its own deployment
- Shared EKS infrastructure

## 📋 Quick Template Conversion Steps:

### Step 1: Fork/Clone Repository
```bash
git clone https://github.com/Getdzidon/deploy-SuperMario-on-K8s-with-terraform.git
cd deploy-SuperMario-on-K8s-with-terraform
```

### Step 2: Update Application Configuration
1. Replace `sevenajay/mario:latest` with your Docker image
2. Update container ports and resource limits
3. Modify service configuration if needed

### Step 3: Update Infrastructure Names
1. Change cluster name in `terraform.tfvars`
2. Update S3 bucket name in `backend.tf`
3. Update workflow environment variables

### Step 4: Test Locally (Optional)
```bash
# Deploy infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# Deploy application
kubectl apply -f k8s-manifests/
```

### Step 5: Setup CI/CD
1. Add AWS credentials to GitHub Secrets
2. Push changes to trigger automated deployment
3. Monitor deployment in GitHub Actions

## 🔧 Advanced Customizations:

### Multiple Applications
Deploy multiple apps by duplicating and modifying the k8s-manifests:
```
k8s-manifests/
├── frontend/
│   ├── deployment.yaml
│   └── service.yaml
├── backend/
│   ├── deployment.yaml
│   └── service.yaml
└── database/
    ├── deployment.yaml
    └── service.yaml
```

### Environment-Specific Deployments
Create separate configurations for different environments:
```
terraform/
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
```

### Custom Domain & SSL
**📖 Complete DNS & SSL Guide**
**👉 See [DNS-SSL-SETUP.md](./DNS-SSL-SETUP.md) for detailed instructions on:**
- Setting up Route 53 DNS with custom domains
- Configuring SSL certificates with AWS Certificate Manager
- Creating Application Load Balancer with Ingress
- Domain validation and troubleshooting

**Quick Setup:**
1. Enable LoadBalancer controller in `terraform.tfvars`
2. Add domain configuration variables
3. Deploy Route 53 and ACM resources
4. Create Kubernetes Ingress for your domain

## 🚀 Result

Following these steps gives you:
- **Production-ready EKS cluster** for your application
- **Automated CI/CD pipeline** with GitHub Actions
- **Scalable infrastructure** that grows with your needs
- **Security best practices** built-in
- **Cost-optimized** resource allocation

## 📚 Additional Resources

For detailed setup instructions, see the main [README.md](./README.md) file:
- AWS CLI setup and IAM user creation
- Prerequisites and tool installation
- Step-by-step deployment guide
- Troubleshooting and monitoring

---

**Need help?** Check the main README.md or open an issue in the repository!