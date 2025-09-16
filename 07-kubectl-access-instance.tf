# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = local.name
    region       = local.region
    bucket       = var.s3_mirror_bucket
    prefix       = var.s3_mirror_prefix
  }))
}

resource "aws_instance" "kubectl_access" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [module.kubectl_access_sg.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.kubectl_access_profile.name

  user_data = local.user_data

  tags = merge(local.tags, {
    Name = "${local.name}-kubectl-access"
  })

  depends_on = [module.eks]
}
