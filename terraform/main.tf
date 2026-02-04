terraform {
  backend "s3" {
    bucket         = "cv-challenge-phase3-terraform-state-12345" 
    key            = "phase3/terraform.tfstate"
    region         = "us-east-1"                          
    encrypt        = true
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_security_group.web_sg, aws_key_pair.generated_key]
  create_duration = "30s"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "web_sg" {
  name        = "phase3-web-sg"
  description = "Allow SSH, Web, and Traefik Dashboard"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Traefik Dashboard"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = "phase3-pipeline-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMqtfOQv2E/GRmrkBWUD3loXqCdLkd9N6aik+w82iqbqkrtxUogsA9aEELDaxhXY74Nm72KVE+EXrOWr2f3UQsuZKHKXeacbApctFOg9jNMd7QAEzPzlOhT9KMb5z1+hFkBvZdvyoxtULiZHsmP4U7JuLbkO1uuQhcolue+jtvymekx8GYpfGXR/Zcy2fQ1ot8Zm6tmYnoejGRMJkVGVjSFOpbC+1SmeolrFe5kHr0ILFRnclGP4K56Kc/y97TJzdZTfujKY9im00dheoXYxPRaudCiyGz4QOYwJhwre/MZVDWOzLyCqvJ7J456W+6NADoicNyM556mWeevIIbRxgjN1PHAg3GxOyfRs4OJCDrkM0okWBm1uB39uIyEOVx1HI8PKw/MaeqtQ7H2iIPLLgAOrWAf/c3b39rTK9Ka9IY8mOhoRllpzJDoZ+k90TT8O6hqJfMB9pRDGDHmzF0Qugh9pjzcqJSK6n4kjcPzpj/mBszbOfhNq2B2sh+oXBqdAc+Vs57qo5WZQnHb3UvsMfEaR6NlxYp4Ma96UfzwzLd9Nx1hBsq33ZGjk2WPH87WQqgMIz2yr653gMXIP0cLUGlZVRk1BQAmcWmy0Spvlp99HvAKWSwmZRwP8CUPALoawekSvXbj40loVlGm1m89ANG+twoIT8LVqgRYWkCFAviaw== codespace@codespaces-77bd5c"
}

resource "aws_instance" "app_server" {
  depends_on = [time_sleep.wait_30_seconds]  
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Ensure the disk is large enough for monitoring logs
  root_block_device {
    volume_size = 20
  }

  tags = {
    Name        = "Phase3-Server"
    Environment = "Dev"
    Project     = "CV-Challenge"
  }
}

resource "aws_eip" "static_ip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"
}