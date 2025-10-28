# =============================================================================
# Flarum Core Infrastructure Configuration
# =============================================================================

# =============================================================================
# Public Subnets for EC2 and Load Balancer
# =============================================================================
resource "aws_subnet" "public_1" {
  vpc_id                  = data.aws_vpc.flarum.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-flarum-public-1"
    Service     = "Subnet"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = data.aws_vpc.flarum.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-flarum-public-2"
    Service     = "Subnet"
    Environment = var.environment
  }
}

# =============================================================================
# Internet Gateway and Route Table
# =============================================================================
resource "aws_internet_gateway" "flarum" {
  vpc_id = data.aws_vpc.flarum.id

  tags = {
    Name        = "${var.project_name}-flarum-igw"
    Service     = "IGW"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.flarum.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.flarum.id
  }

  tags = {
    Name        = "${var.project_name}-flarum-public-rt"
    Service     = "VPC"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Private Subnets for RDS
# =============================================================================
resource "aws_subnet" "private_1" {
  vpc_id                  = data.aws_vpc.flarum.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-flarum-private-1"
    Service     = "Subnet"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = data.aws_vpc.flarum.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-flarum-private-2"
    Service     = "Subnet"
    Environment = var.environment
  }
}

# =============================================================================
# EC2 Instance for Flarum
# =============================================================================
resource "aws_instance" "flarum" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t3.micro"

  key_name = aws_key_pair.flarum.key_name

  vpc_security_group_ids = [aws_security_group.flarum_web.id]
  subnet_id              = aws_subnet.public_1.id
  iam_instance_profile   = aws_iam_instance_profile.flarum.name

  # Using minimal user-data for FAST deployment (2-3 minutes instead of 15-20 minutes)
  user_data = base64encode(file("${path.module}/user-data-minimal.sh"))
  
  # Force replacement of EC2 instance to apply new user-data
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-flarum-core"
    Service     = "Flarum"
    Environment = var.environment
  }
}

# =============================================================================
# Key Pair for EC2 Access
# =============================================================================
resource "tls_private_key" "flarum" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "flarum" {
  key_name   = "${var.project_name}-flarum-key"
  public_key = tls_private_key.flarum.public_key_openssh

  tags = {
    Name        = "${var.project_name}-flarum-key"
    Service     = "EC2"
    Environment = var.environment
  }
}

# Save the private key locally (for SSH access)
resource "local_file" "private_key" {
  content         = tls_private_key.flarum.private_key_pem
  filename        = "${path.module}/${var.project_name}-flarum-key.pem"
  file_permission = "0600"
}

# =============================================================================
# Security Group for Flarum Web Server
# =============================================================================
resource "aws_security_group" "flarum_web" {
  name_prefix = "${var.project_name}-flarum-web-"
  vpc_id      = data.aws_vpc.flarum.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-flarum-web-sg"
    Service     = "Flarum"
    Environment = var.environment
  }
}

# =============================================================================
# Application Load Balancer
# =============================================================================
resource "aws_lb" "flarum" {
  name               = "${var.project_name}-flarum-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.flarum_web.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-flarum-alb"
    Service     = "ALB"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "flarum" {
  name     = "${var.project_name}-flarum-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.flarum.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-flarum-tg"
    Service     = "ALB"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "flarum" {
  target_group_arn = aws_lb_target_group.flarum.arn
  target_id        = aws_instance.flarum.id
  port             = 80
}

resource "aws_lb_listener" "flarum" {
  load_balancer_arn = aws_lb.flarum.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flarum.arn
  }
}

# =============================================================================
# IAM Role for EC2 Instance
# =============================================================================
resource "aws_iam_role" "flarum_instance" {
  name = "${var.project_name}-flarum-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-flarum-instance-role"
    Service     = "IAM"
    Environment = var.environment
  }
}

resource "aws_iam_instance_profile" "flarum" {
  name = "${var.project_name}-flarum-instance-profile"
  role = aws_iam_role.flarum_instance.name

  tags = {
    Name        = "${var.project_name}-flarum-instance-profile"
    Service     = "IAM"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "flarum_ssm" {
  role       = aws_iam_role.flarum_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "flarum_s3" {
  name = "${var.project_name}-flarum-s3-policy"
  role = aws_iam_role.flarum_instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.flarum_files.arn,
          "${aws_s3_bucket.flarum_files.arn}/*"
        ]
      }
    ]
  })
}

# =============================================================================
# Outputs
# =============================================================================
# All outputs moved to outputs.tf to avoid duplication
