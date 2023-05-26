terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

resource "aws_s3_bucket" "backend_s3" {
  bucket = "swtf-tfstate-s3"
}

resource "aws_s3_bucket_acl" "backend_s3_acl" {
  bucket = aws_s3_bucket.backend_s3.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "backend_s3_versioning" {
  bucket = aws_s3_bucket.backend_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "tfstate-lock"
  hash_key       = "LockID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
