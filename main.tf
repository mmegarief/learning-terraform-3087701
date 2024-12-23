data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true  
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # in the course example this was deleted to kept only public subnets
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_nat_gateway = true # won't be using this
  # enable_vpn_gateway = true # won't be using this

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "blog" {
  ami                             = data.aws_ami.app_ami.id
  instance_type                   = var.instance_type
  vpc_security_group_ids          = [module.blog_sg.vpc_security_group_ids]

  subnet_id = module.blog.vpc.public_subnets[0]

  tags = {
    Name = "Learning Terraform"
    # Name = "HelloWorld" 
  }
}

modeule "blog_sg" {
  source = "terraform-aws-modules/security-vpc_security_group/aws"
  version ="4.13.0"

  vpc_id =data.blog_vpc_vpc_id
  name   ="blog"
  ingress_rules = ["http-443-tcp","http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  egress_cidr_blocks = [0.0.0.0/0]
}