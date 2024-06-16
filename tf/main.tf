resource "aws_key_pair" "public_key" {
  public_key = var.public_ssh_key
}

resource "aws_security_group" "ec2_sg" {
  name        = local.name
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # not sure where to lock
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # assuming need to access intenet while using vpn
  }

  tags = {
    Name = local.name
  }
  vpc_id = var.VPC_ID

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_role" "ec2" {
  name = local.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  inline_policy {
    name   = "${local.name}-policy"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = local.name
  role = aws_iam_role.ec2.name
}

# enter into instance via ssm
resource "aws_iam_role_policy_attachment" "policy-AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.ec2.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = local.name
  retention_in_days = 3
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ami.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2.id
  subnet_id                   = var.VPC_PUBLIC_SUBNETS[0]
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.public_key.id

  tags = {
    Name = local.name
  }
  # user_data = data.template_file.userdata_script.rendered
  volume_tags = {
    Name = local.name
  }
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}