terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"
    }
  }

  required_version = ">= 1.1.2"
}



variable "my_access_key" {
  description = "Access-key-for-AWS"
  default = "no_access_key_value_found"
}
 
variable "my_secret_key" {
  description = "Secret-key-for-AWS"
  default = "no_secret_key_value_found"
}


 
provider "aws" {
	region = "eu-west-3" //Paris
  access_key = var.my_access_key
	secret_key = var.my_secret_key
        
}



resource "aws_instance" "web_server" {
  ami = "ami-0042da0ea9ad6dd83" // Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20 eu-west-3
  instance_type = "t2.micro"
  key_name= "ssh_test_kp"
  
  tags = {
		Name = "web_server"
	}

  }

resource "aws_vpc" "web_server_vpc" {
  cidr_block = "172.16.0.0/16"
  }

  
resource "aws_subnet" "web_server_subnet" {
  vpc_id            = aws_vpc.web_server_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "eu-west-3a"
}
resource "aws_internet_gateway" "web_server_gateway" {
vpc_id = aws_vpc.web_server_vpc.id
}
resource "aws_network_interface" "web_server_ni" {
  subnet_id   = aws_subnet.web_server_subnet.id
  private_ips = ["172.16.10.100"]
  tags = {
    Name = "primary_network_interface"
  }
}
resource "aws_eip" "web_server_eip" {
vpc = true
}
resource "aws_eip_association" "web_server_eip_assoc" {
instance_id   = aws_instance.web_server.id
allocation_id = aws_eip.web_server_eip.id
}



output "public_ip" {
    value = aws_instance.web_server.public_ip
  }





