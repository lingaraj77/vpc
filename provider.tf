terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.15.0"
    }
  }
backend "s3" {
    bucket   = "roboshop-remote-state-1"
    key = "vpc-demo"
    region = "us-east-1"
    dynamodb_table = "roboshop-locking-1"
  }
}
provider "aws" {
  # Configuration options
  region = "us-east-1"
}