# Configuration
$BucketName = "mario12-tfstate-bucket"
# $DynamoTable = "terraform-lock"
$Region = "eu-central-1"

Write-Host "Creating S3 bucket for Terraform state..."
aws s3api create-bucket `
    --bucket $BucketName `
    --region $Region `
    --create-bucket-configuration LocationConstraint=$Region

Write-Host "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning `
    --bucket $BucketName `
    --versioning-configuration "Status=Enabled"

Write-Host "Enabling server-side encryption on S3 bucket..."
aws s3api put-bucket-encryption `
    --bucket $BucketName `
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Uncomment to create DynamoDB table for state locking
# Write-Host "Creating DynamoDB table for state locking..."
# aws dynamodb create-table `
#     --table-name $DynamoTable `
#     --attribute-definitions AttributeName=LockID,AttributeType=S `
#     --key-schema AttributeName=LockID,KeyType=HASH `
#     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 `
#     --region $Region

Write-Host "Backend resources created successfully!"
Write-Host "Bucket: $BucketName"
# Write-Host "DynamoDB Table: $DynamoTable"
