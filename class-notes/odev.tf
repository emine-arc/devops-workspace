terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.56.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_instance" "tf-ec2" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  key_name      = "ec2_key"
  user_data = <<EOT
            #! /bin/bash
            sudo yum update -y
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
            sudo yum -y install terraform
  EOT
  tags = {
    "Name" = "created-by-tf"
  }
}


resource "aws_security_group" "default" {
  name        = "default"
  vpc_id      = aws_vpc.main.id
}