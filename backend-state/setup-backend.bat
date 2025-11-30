@echo off
REM Configuration
set BUCKET_NAME=mario12-tfstate-bucket
REM set DYNAMODB_TABLE=terraform-lock
set REGION=eu-central-1

echo Creating S3 bucket for Terraform state...
aws s3api create-bucket --bucket %BUCKET_NAME% --region %REGION% --create-bucket-configuration LocationConstraint=%REGION%

echo Enabling versioning on S3 bucket...
aws s3api put-bucket-versioning --bucket %BUCKET_NAME% --versioning-configuration Status=Enabled

echo Enabling server-side encryption on S3 bucket...
aws s3api put-bucket-encryption --bucket %BUCKET_NAME% --server-side-encryption-configuration "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}"

REM Uncomment below to create DynamoDB table for state locking (optional)
REM echo Creating DynamoDB table for state locking...
REM aws dynamodb create-table --table-name %DYNAMODB_TABLE% --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region %REGION%

echo Backend resources created successfully!
echo Bucket: %BUCKET_NAME%
REM echo DynamoDB Table: %DYNAMODB_TABLE%