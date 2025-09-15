
module "kubectl_access_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-kubectl-access"
  description = "Security group for kubectl access instance"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "HTTPS for SSM Session Manager"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp"
      description = "HTTP for SSM Session Manager"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "All outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.tags
}
