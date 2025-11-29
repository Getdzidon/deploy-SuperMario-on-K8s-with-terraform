# 🛠️ AWS CLI Setup & IAM User Configuration

Complete guide for setting up AWS CLI and creating the necessary IAM user for this EKS deployment.

## 📋 Prerequisites

- AWS Account with administrative access
- Internet connection for downloading AWS CLI

## 🔐 Step 1: Create IAM User for Terraform

### Method 1: AWS Console (Recommended)

**1. Access IAM Console:**
- Go to [AWS Console](https://console.aws.amazon.com/) → **IAM** → **Users** → **Create User**

**2. User Configuration:**
- **Username**: `terraform-user`
- **Access type**: ✅ **Programmatic access** (API access keys)
- **Console access**: ❌ Not needed

**3. Attach Required Policies:**
Select **Attach policies directly** and add these managed policies:

| Policy Name | Purpose |
|-------------|---------|
| `AmazonEKSClusterPolicy` | EKS cluster management |
| `AmazonEKSWorkerNodePolicy` | Worker node management |
| `AmazonEKS_CNI_Policy` | Container networking |
| `AmazonEC2ContainerRegistryReadOnly` | Pull container images |
| `AmazonEC2FullAccess` | EC2 instance management |
| `IAMFullAccess` | Create/manage IAM roles |
| `AmazonS3FullAccess` | Terraform state storage |
| `ElasticLoadBalancingFullAccess` | Load balancer management |

**4. Download Credentials:**
- **Important**: Download the CSV file with Access Key ID and Secret Access Key
- **Security**: Store this file securely and delete after configuration

### Method 2: AWS CLI (Alternative)

If you already have AWS CLI configured with admin access:

```bash
# Create IAM user
aws iam create-user --user-name terraform-user

# Attach required policies
aws iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
aws iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess

# Create access keys
aws iam create-access-key --user-name terraform-user
```

## 💻 Step 2: Install AWS CLI

### Windows Installation

**Option 1: MSI Installer (Recommended)**
1. Download from: https://aws.amazon.com/cli/
2. Run the installer
3. Restart command prompt/PowerShell

**Option 2: Chocolatey**
```cmd
choco install awscli
```

**Option 3: Winget**
```cmd
winget install Amazon.AWSCLI
```

### Linux Installation

**Ubuntu/Debian:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Amazon Linux/CentOS/RHEL:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Using Package Manager:**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install awscli

# CentOS/RHEL
sudo yum install awscli
```

### macOS Installation

**Option 1: Homebrew (Recommended)**
```bash
brew install awscli
```

**Option 2: Official Installer**
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

## ⚙️ Step 3: Configure AWS CLI

### Basic Configuration
```bash
aws configure
```

**Enter the following information:**
```
AWS Access Key ID [None]: AKIA****************  # From downloaded CSV
AWS Secret Access Key [None]: **********************  # From downloaded CSV
Default region name [None]: eu-central-1  # Or your preferred region
Default output format [None]: json
```

### Alternative: Environment Variables
```bash
# Linux/Mac
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="eu-central-1"

# Windows (PowerShell)
$env:AWS_ACCESS_KEY_ID="your-access-key-id"
$env:AWS_SECRET_ACCESS_KEY="your-secret-access-key"
$env:AWS_DEFAULT_REGION="eu-central-1"
```

### Using AWS Profiles (Multiple Accounts)
```bash
# Configure named profile
aws configure --profile terraform-user

# Use specific profile
aws sts get-caller-identity --profile terraform-user

# Set default profile
export AWS_PROFILE=terraform-user
```

## ✅ Step 4: Verify Configuration

### Test AWS CLI Access
```bash
# Check current user identity
aws sts get-caller-identity

# Expected output:
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

### Test Required Permissions
```bash
# Test EKS access
aws eks list-clusters --region eu-central-1

# Test EC2 access
aws ec2 describe-regions

# Test S3 access
aws s3 ls

# Test IAM access
aws iam get-user --user-name terraform-user
```

## 🔒 Security Best Practices

### 1. Credential Security
- **Never commit** AWS credentials to version control
- **Use IAM roles** in production environments when possible
- **Rotate access keys** regularly (every 90 days)
- **Delete unused** access keys immediately

### 2. Principle of Least Privilege
- **Review policies** periodically
- **Remove unused** permissions
- **Use temporary credentials** when possible
- **Monitor usage** with CloudTrail

### 3. Multi-Factor Authentication
```bash
# Enable MFA for IAM user (optional but recommended)
aws iam enable-mfa-device --user-name terraform-user --serial-number arn:aws:iam::123456789012:mfa/terraform-user --authentication-code1 123456 --authentication-code2 654321
```

## 🚨 Troubleshooting

### Common Issues

**1. "Unable to locate credentials"**
```bash
# Check configuration
aws configure list

# Reconfigure if needed
aws configure
```

**2. "Access Denied" errors**
```bash
# Verify user permissions
aws iam list-attached-user-policies --user-name terraform-user

# Check if policies are attached correctly
aws iam get-user --user-name terraform-user
```

**3. "Region not found"**
```bash
# List available regions
aws ec2 describe-regions --output table

# Update region
aws configure set region eu-central-1
```

**4. SSL Certificate errors**
```bash
# Update certificates (Linux)
sudo apt-get update && sudo apt-get install ca-certificates

# Skip SSL verification (not recommended for production)
aws configure set default.s3.signature_version s3v4
```

### Getting Help
```bash
# AWS CLI help
aws help

# Service-specific help
aws eks help

# Command-specific help
aws eks create-cluster help
```

## 📚 Additional Resources

- [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Security Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)

---

**Next Steps**: Return to the main [README.md](./README.md) to continue with the EKS deployment setup.