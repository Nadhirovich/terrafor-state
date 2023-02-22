terraform {
  required_version = ">= 1.3.7, < 2.0.0"
  backend "s3" {
    # bucket name
    bucket = "my-test-backet-007"
    key = "terraform.tfstate"
    region = "eu-central-1"
    # DynamoDB table name
    dynamodb_table = "MyDynamoDB-Lock"
    encrypt = true

  }


}



provider "aws" {
  region = "eu-central-1"
  
  

}

resource "aws_s3_bucket" "terraform_state" {

  bucket = "my-test-backet-007"

  // Prevent accidental deletion of this S3 Bucket
  lifecycle {
    prevent_destroy = true
  }
  

  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "MyDynamoDB-Lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_arn" {
value = aws_s3_bucket.terraform_state.arn
description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
value = aws_dynamodb_table.terraform_locks.name
description = "The name of the DynamoDB table"
}

