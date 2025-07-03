
provider "aws" {
  region = "ap-south-1"
}
resource "aws_dynamodb_table" "state_locking" {
  hash_key = "LockID"
  name     = "dynamodb-state-locking"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}
terraform {
    backend "s3" {
        bucket = "smaranas3bucket"
        key    = "statefilesmarus3/terraform.tfstate"
        region     = "ap-south-1"
       dynamodb_table  = "dynamodb-state-locking"
    }
} 
