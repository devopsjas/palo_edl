provider "aws" {
  region = "us-east-1"  # 🔹 AWS Region
}

# 🔹 Security Group (Allow HTTP & SSH)
resource "aws_security_group" "edl_sg" {
  name        = "edl-security-group"
  description = "Allow HTTP & SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 EC2 Instance for Web Server
resource "aws_instance" "edl_server" {
  ami           = "ami-053a45fff0a704a47"  # 🔹 Correct AMI ID daalo
  instance_type = "t2.micro"
  key_name      = "your-key"      # 🔹 Apna SSH key name
  security_groups = [aws_security_group.edl_sg.name]

  tags = {
    Name = "EDL-WebServer"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    echo "EDL Web Server Running" > /var/www/html/index.html
    systemctl restart nginx
  EOF
}

# 🔹 ELB (Elastic Load Balancer)
resource "aws_lb" "edl_elb" {
  name               = "edl-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.edl_sg.id]
  subnets           = ["subnet-0d60562a801b9cb62", "subnet-01a4be781eb547c6a"]  # 🔹 Correct Subnet IDs

  tags = {
    Name = "EDL-LoadBalancer"
  }
}

# 🔹 Target Group (For ELB)
resource "aws_lb_target_group" "edl_tg" {
  name     = "edl-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0a15483bed89c80bc"  # 🔹 Correct VPC ID
}

# 🔹 Attach EC2 to Target Group
resource "aws_lb_target_group_attachment" "edl_attach" {
  target_group_arn = aws_lb_target_group.edl_tg.arn
  target_id        = aws_instance.edl_server.id
  port            = 80
}

# 🔹 ELB Listener
resource "aws_lb_listener" "edl_listener" {
  load_balancer_arn = aws_lb.edl_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.edl_tg.arn
  }
}
