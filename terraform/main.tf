# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block             = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block             = var.private_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-private-subnet"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name        = "${var.project_name}-nat-eip"
    Environment = var.environment
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name        = "${var.project_name}-nat"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "nginx" {
  name        = "${var.project_name}-nginx-sg"
  description = "Security group for Nginx load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-nginx-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "k3s" {
  name        = "${var.project_name}-k3s-sg"
  description = "Security group for K3s cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 30000
    to_port         = 30001
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-k3s-sg"
    Environment = var.environment
  }
}

# EC2 Instances
resource "aws_instance" "bastion" {
  ami                    = "ami-0261755bbcb8c4a84"  # Ubuntu 20.04 LTS
  instance_type          = var.instance_types["bastion"]
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name              = var.ssh_key_name

  tags = {
    Name        = "${var.project_name}-bastion"
    Environment = var.environment
  }
}

resource "aws_instance" "nginx" {
  ami                    = "ami-0261755bbcb8c4a84"  # Ubuntu 20.04 LTS
  instance_type          = var.instance_types["nginx"]
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.nginx.id]
  key_name              = var.ssh_key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              cat > /etc/nginx/conf.d/judgebox.conf <<'EOL'
              upstream nestjs_backend {
                  server ${aws_instance.k3s.private_ip}:30000;
              }

              upstream flask_judge {
                  server ${aws_instance.k3s.private_ip}:30001;
              }

              server {
                  listen 80;
                  server_name _;

                  location /api {
                      proxy_pass http://nestjs_backend;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                  }

                  location /judge {
                      proxy_pass http://flask_judge;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                  }
              }
              EOL
              systemctl restart nginx
              EOF

  tags = {
    Name        = "${var.project_name}-nginx"
    Environment = var.environment
  }
}

resource "aws_instance" "k3s" {
  ami                    = "ami-0261755bbcb8c4a84"  # Ubuntu 20.04 LTS
  instance_type          = var.instance_types["k3s"]
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name              = var.ssh_key_name

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              curl -sfL https://get.k3s.io | sh -
              EOF

  tags = {
    Name        = "${var.project_name}-k3s"
    Environment = var.environment
  }
}