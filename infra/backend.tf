terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-tsofnat"
    key    = "smartmedia/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locking-user-tsofnat"
  }
}