variable "my_access_key" {
  description = "Access-key-for-AWS"
  default = "no_access_key_value_found"
}
 
variable "my_secret_key" {
  description = "Secret-key-for-AWS"
  default = "no_secret_key_value_found"
}
 
provider "aws" {
	region = "eu-west-3"
  access_key = var.my_access_key
	secret_key = var.my_secret_key
        
}

resource "aws_instance" "t2micro" {
  ami           = "ami-0042da0ea9ad6dd83" // Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20 eu-west-3
  instance_type = "t2.micro"
  key_name = "t2micro-ubuntu-kp"

  /*network_interface {
    network_interface_id = aws_network_interface.te2micro_ni.id
    device_index         = 0
  }*/

  tags = {
		Name = "t2micro"
	}

  }

  output "public_ip" {
    value = aws_instance.t2micro.public_ip
  }
 
/*resource "aws_vpc" "t2micro_vpc" {
  cidr_block = "172.16.0.0/16"
  }
resource "aws_subnet" "t2micro_subnet" {
  vpc_id            = aws_vpc.t2micro_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "eu-west-3a"
}
resource "aws_internet_gateway" "t2micro_gateway" {
vpc_id = aws_vpc.t2micro_vpc.id
}
resource "aws_network_interface" "te2micro_ni" {
  subnet_id   = aws_subnet.t2micro_subnet.id
  private_ips = ["172.16.10.100"]
  tags = {
    Name = "primary_network_interface"
  }
}
resource "aws_eip" "t2micro_eip" {
vpc = true
}
resource "aws_eip_association" "t2micro_eip_assoc" {
instance_id   = aws_instance.foo.id
allocation_id = aws_eip.t2micro_eip.id
}*/







