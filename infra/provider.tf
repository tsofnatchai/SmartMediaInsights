provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
  required_version = ">= 1.3.0"
}