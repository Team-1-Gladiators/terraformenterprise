resource "aws_vpc" "project" {
  cidr_block       = "10.158.16.0/24"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "mainvpc"
  }
}

  resource "aws_subnet" "project-0" {
  vpc_id     = aws_vpc.project.id
  cidr_block = "10.158.16.0/26"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-project-0"
  }
  }

  resource "aws_subnet" "project-1" {
  vpc_id     = aws_vpc.project.id
  cidr_block = "10.158.16.64/26"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-project-1"
  }
}

resource "aws_subnet" "project-2" {
  vpc_id     = aws_vpc.project.id
  cidr_block = "10.158.16.128/26"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-project-2"
  }
}

resource "aws_internet_gateway" "project" {
  vpc_id = aws_vpc.project.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "project" {
  vpc_id = aws_vpc.project.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project.id
  }

  tags = {
    Name = "Public-route"
  }
}
resource "aws_route_table_association" "project" {
  subnet_id      = aws_subnet.project-0.id
  route_table_id = aws_route_table.project.id
}
resource "aws_route_table_association" "project1" {
  subnet_id      = aws_subnet.project-1.id
  route_table_id = aws_route_table.project.id
}
resource "aws_security_group" "project" {
  name        = "Ec2-Security-group"
  description = "Allow  http inbound traffic"
  vpc_id      = aws_vpc.project.id

  ingress {
      description      = "Http from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups =  [aws_security_group.project-lb.id]
    }
  

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  
  tags = {
    Name = "Ec2-Security-group"
  }
}
