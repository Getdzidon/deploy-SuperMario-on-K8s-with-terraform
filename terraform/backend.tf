terraform {
  backend "s3" {
    bucket  = "mario12-tfstate-bucket"
    key     = "eks/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
    use_lockfile = true  # S3 native state locking
    
    # Alternative: Use DynamoDB for state locking (comment out use_lockfile above)
    # dynamodb_table = "terraform-lock"
  }
}