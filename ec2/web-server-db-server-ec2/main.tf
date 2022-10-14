terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"
    }
  }

  required_version = ">= 1.3.2"
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









# Create VPC
# terraform aws create vpc

resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc-cidr}"
    instance_tenancy = "default"
    enable_dns_hostnames = true
        tags = {
            Name = "Test_VPC"
            }
}

# Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway


resource "aws_internet_gateway" "internet-gateway" {
    vpc_id    = aws_vpc.vpc.id
    tags = {
        Name    = "internet_gateway"
        }
}

# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.vpc.id
    
    cidr_block = "${var.Public_Subnet_1}"
    availability_zone = "eu-west-3a"
    map_public_ip_on_launch = true
    tags = {
        Name    = "public-subnet-1"
        }
}



# Create Route Table and Add Public Route
# terraform aws create route table


resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
    }
        tags = {
            Name     = "Public Route Table"
            } 
}


/* Associate Public Subnet 1 to "Public Route Table"
   terraform aws associate subnet with route table */


   resource "aws_route_table_association" "public-subnet-1-route-table-association" {
    subnet_id           = aws_subnet.public-subnet-1.id
    route_table_id      = aws_route_table.public-route-table.id
    }




# Create Private Subnet 1
# terraform aws create subnet


resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "${var.Private_Subnet_1}"
    availability_zone = "eu-west-3b"
    map_public_ip_on_launch  = false
    tags      = {
        Name    = "private-subnet-1"}
    }

  # Create Security Group for the Bastion Host aka Jump Box
  # terraform aws create security group


  resource "aws_security_group" "ssh-security-group" {
    name  = "SSH Security Group"
    description = "Enable SSH access on Port 22"
    vpc_id= aws_vpc.vpc.id
    
      ingress {

            description = "SSH Access"
            from_port= 22
            to_port= 22
            protocol = "tcp"
            cidr_blocks = ["${var.ssh-location}"]
        }

      egress {

            from_port= 0
            to_port= 0
            protocol = "-1"
            cidr_blocks      = ["0.0.0.0/0"]
        }

      tags = {
            Name = "SSH Security Group"
        }
    }


# Create Security Group for the Web Server
# terraform aws create security group

resource "aws_security_group" "webserver-security-group" {
    name        = "Web Server Security Group"
    description = "Enable HTTP/HTTPS access on Port 80/443 via ALB and SSH access on Port 22 via SSH SG"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description      = "SSH Access"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        security_groups  = ["${aws_security_group.ssh-security-group.id}"]
        }


    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        }

    tags   = {
        Name = "Web Server Security Group"
        }
    }



#Create a new EC2 launch configuration

resource "aws_instance" "ec2_public" {
    ami                    = "ami-0042da0ea9ad6dd83"
    instance_type               = "${var.instance_type}"
    key_name                    = "${var.key_name}"
    security_groups             = ["${aws_security_group.ssh-security-group.id}"]
    subnet_id                   = "${aws_subnet.public-subnet-1.id}"
    associate_public_ip_address = true    

    #user_data ="${data.template_file.provision.rendered}"
    
    #iam_instance_profile = "${aws_iam_instance_profile.some_profile.id}"
    
    lifecycle {
        create_before_destroy = true
        }
        
        tags = { 
            Name = "public-ec2"
            }

    # Copies the ssh key file to home dir
    # Copies the ssh key file to home dir


    provisioner "file" {
        
        source = "./${var.key_name}.pem"
        destination = "/home/ubuntu/${var.key_name}.pem"
        
        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = file("${var.key_name}.pem")
            host        = self.public_ip
        }
    }

    //chmod key 400 on EC2 instance

    provisioner "remote-exec" {
         inline = ["chmod 400 ~/${var.key_name}.pem"]
        connection {
          type        = "ssh"
          user        = "ubuntu"
          private_key = file("${var.key_name}.pem")
          host        = self.public_ip
              }
        
          }
    }

#Create a new EC2 launch configuration

resource "aws_instance" "ec2_private" {
    #name_prefix = "terraform-example-web-instance"
    ami                    = "ami-0042da0ea9ad6dd83"
    instance_type               = "${var.instance_type}"
    key_name                    = "${var.key_name}"
    security_groups             = ["${aws_security_group.webserver-security-group.id}"]
    subnet_id                   = "${aws_subnet.private-subnet-1.id}"
    associate_public_ip_address = false
    #user_data = "${data.template_file.provision.rendered}"
    #iam_instance_profile = "${aws_iam_instance_profile.some_profile.id}"

    lifecycle {
    create_before_destroy = true
    }
    
    tags = {
        Name = "private-ec2"
        }
    }