terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_reg
}

# --------------------------------------------------------------------------- TASK 1 ---------------------------------------------------------------------------

# create an IAM user
resource "aws_iam_user" "terraform_user" {
  name = "terraform-cs423-devops"   # the name of the IAM user
}

# provide admin policy to the IAM user
resource "aws_iam_user_policy_attachment" "admin_attachment" {
  user       = aws_iam_user.terraform_user.name # the name of the user
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # the security policy to provide to the user
}

# --------------------------------------------------------------------------- TASK 2 ---------------------------------------------------------------------------

# creation of a VPC
resource "aws_vpc" "devops_vpc" {
  cidr_block = var.vpc_cidr_block[0]    # the cidr block address
  enable_dns_hostnames =  true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = var.vpc_cidr_block[1]   # the name of the VPC
  }
}

# creation of internet gateway
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id
}

# creation of a public subnets
resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = var.public_sub_1[0]
  availability_zone = var.public_sub_1[1]
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_sub_1[2]
  }
}
resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = var.public_sub_2[0]
  availability_zone = var.public_sub_2[1]
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_sub_2[2]
  }
}

# creation of a private subnet
resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = var.private_sub_1[0]
  availability_zone = var.private_sub_1[1]
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_sub_1[2]
  }
}
resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = var.private_sub_2[0]
  availability_zone = var.private_sub_2[1]
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_sub_2[2]
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "${aws_vpc.devops_vpc.tags.Name}-private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_association_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "${aws_vpc.devops_vpc.tags.Name}-public-route-table"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_association_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_subnet_association_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}

# --------------------------------------------------------------------------- TASK 3 ---------------------------------------------------------------------------


# Create Security Group
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-security-group"
  description = "Security group for the web server EC2 instances"
  vpc_id      = aws_vpc.devops_vpc.id

  # Inbound rule for HTTP (Port 80) - web server
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule for SSH (Port 22) - SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# --------------------------------------------------------------------------- TASK 4 ---------------------------------------------------------------------------

# key pair generation
resource "aws_key_pair" "my_key_pair" {
  key_name   = "cs423-assignment4-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# --------------------------------------------------------------------------- TASK 5 ---------------------------------------------------------------------------

# Ubuntu 20.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Launch EC2 Instances
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az1.id
  key_name      = aws_key_pair.my_key_pair.key_name
  tags = {
    Name = "Assignment4-EC2-WebServer"
  }
  # Associate the security group with the EC2 instance
  vpc_security_group_ids = [
    aws_security_group.web_server_sg.id
  ]
}

# resource "aws_instance" "web_server" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.public_subnet_az1.id
#   key_name      = aws_key_pair.my_key_pair.key_name
# #   user_data     = file("path_to_web_server_user_data.sh")  # Path to user_data.sh script
#   tags = {
#     Name = "Assignment4-EC2-WebServer"
#   }
# }

# resource "aws_instance" "database_or_ml" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.private_subnet_az1.id
#   key_name      = aws_key_pair.my_key_pair.key_name
# #   user_data     = file("path_to_database_or_ml_user_data.sh")  # Path to user_data.sh script
#   tags = {
#     Name = "Assignment4-EC2-DatabaseOrML"
#   }
# }

resource "aws_instance" "database_or_ml" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az1.id
  key_name      = aws_key_pair.my_key_pair.key_name
  tags = {
    Name = "Assignment4-EC2-DatabaseOrML"
  }
  # Associate the security group with the EC2 instance
  vpc_security_group_ids = [
    aws_security_group.web_server_sg.id
  ]
}