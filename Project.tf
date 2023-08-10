# AWS provider configuration
provider "aws" {
  region = "us-west-2"  # Update with your desired AWS region
}

# VPC creation
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnet creation
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

# Load Balancer creation
resource "aws_lb" "public" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
}

# Compute instances creation
resource "aws_instance" "web" {
  ami           = "ami-0c94855ba95c71c99"  # Update with your desired AWS AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
}

resource "aws_instance" "app" {
  ami           = "ami-0c94855ba95c71c99"  # Update with your desired AWS AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
}

# Security Group configuration
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web instances"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security group for app instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Outputs
output "public_lb_dns" {
  value       = aws_lb.public.dns_name
  description = "DNS name of the public load balancer"
}

output "web_instance_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP address of the web instance"
}

output "app_instance_ip" {
  value       = aws_instance.app.public_ip
  description = "Public IP address of the app instance"
}
