# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
  default_tags {
    tags = {
      Name        = "Jenkins"
      Environment = "Dev"
      Cost_Centre = "Tweakteck"

    }
  }
}