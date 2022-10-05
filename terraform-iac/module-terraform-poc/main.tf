# Binds the variable to the value of var.main_region.
variable "main_region" {
  type    = string
  default = "us-east-1"
}
# Binds the value of the variable to the AWS region.
provider "aws" {
  region = var.main_region
}
# Calls the code in the vpc module you created earlier.
module "vpc" {
  source = "./modules/vpc"
  region = var.main_region
}
resource "aws_instance" "my-instance" {
  # Binds the value of the ami variable to the AMI id in this module.
  ami = module.vpc.ami_id
  # Binds the value of the subnet id to the subnet id in the module.
  subnet_id = module.vpc.subnet_id
  # Binds the value of instance type to t2.micro.
  instance_type = "t2.micro"
}
