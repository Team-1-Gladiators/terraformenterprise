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
/*
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
*/
resource "aws_subnet" "project-2" {
  vpc_id     = aws_vpc.project.id
  cidr_block = "10.158.16.128/26"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-project-2"
  }
}
/*
  resource "aws_route_table_association" "project" {
  subnet_id      = aws_subnet.project-0.id
  route_table_id = aws_route_table.project.id
}
*/

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
resource "aws_instance" "project0" {
  ami           = "ami-00dfe2c7ce89a450b" 
  instance_type = "t2.micro"
  subnet_id = aws_subnet.project-0.id
  security_groups = [aws_security_group.project.id]
  depends_on = [aws_internet_gateway.project]
  availability_zone = "us-east-2a"
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash 
             yum update –y 
             amazon-linux-extras install nginx1.12
             nginx -v
             systemctl start nginx
             systemctl enable nginx
             chmod 2775 /usr/share/nginx/html 
             find /usr/share/nginx/html -type d -exec chmod 2775 {} \;
             find /usr/share/nginx/html -type f -exec chmod 0664 {} \;
             echo "<h3> "Hello from Kecy Nji 1a"</h3>" > /usr/share/nginx/html/index.html
     EOF

tags = {
    Name = "webserver"
  }
}
resource "aws_instance" "project1" {
  ami           = "ami-00dfe2c7ce89a450b" 
  instance_type = "t2.micro"
  subnet_id = aws_subnet.project-1.id
  security_groups = [aws_security_group.project.id]
  depends_on = [aws_internet_gateway.project]
  availability_zone = "us-east-2b"
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash 
             yum update –y 
             amazon-linux-extras install nginx1.12
             nginx -v
             systemctl start nginx
             systemctl enable nginx
             chmod 2775 /usr/share/nginx/html 
             find /usr/share/nginx/html -type d -exec chmod 2775 {} \;
             find /usr/share/nginx/html -type f -exec chmod 0664 {} \;
             echo "<h3> "Hello from Kecy Nji 1b"</h3>" > /usr/share/nginx/html/index.html
     EOF

tags = {
    Name = "webserver"
  }
}
resource "aws_security_group" "project-lb" {
  name        = "alb-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.project.id

  ingress {
      description      = "http from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      
    }

  egress{
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      
    }
  

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "project" {
  name               = "project-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project-lb.id,aws_security_group.project.id]
  
  enable_deletion_protection = false

  subnet_mapping {
    subnet_id     = aws_subnet.project-0.id
   }
  subnet_mapping {
    subnet_id     = aws_subnet.project-1.id
    
  }

  tags = {
    name = "project-load-balancer"
  }
}

resource "aws_lb_target_group" "project" {
  name     = "webserver"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.project.id
  health_check {
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 20
    matcher = "200,302"
    path = "/"
    port = "traffic-port"
     
  }

}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.project.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project.arn
  }
}

resource "aws_lb_target_group_attachment" "project0" {
  target_group_arn = aws_lb_target_group.project.arn
  target_id        = aws_instance.project0.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "project1" {
  target_group_arn = aws_lb_target_group.project.arn
  target_id        = aws_instance.project1.id
  port             = 80
}
