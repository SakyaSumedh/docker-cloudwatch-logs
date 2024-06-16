# Set the required provider and versions
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "sumedh-org"

    workspaces {
      name = "docker-cloudwatch"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
}
