terraform {
  backend "s3" {
    bucket  = "mario12-tfstate-bucket"
    key     = "eks/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
    
    # Optional: Use DynamoDB for state locking
    # dynamodb_table = "terraform-lock"
  }
}