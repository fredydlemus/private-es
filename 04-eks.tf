#EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.11"

  cluster_name    = local.name
  cluster_version = "1.31"

  enable_cluster_creator_admin_permissions = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    workers = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 5
      desired_size = 3
    }
  }

  cluster_security_group_additional_rules = {
    ingress_bastion_https = {
      description              = "Allow bastion to access EKS cluster"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = module.kubectl_access_sg.security_group_id
    }
  }

  tags = local.tags
}