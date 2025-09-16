resource "aws_iam_role" "kubectl_access_role" {
  name = "${local.name}-kubectl-access-role"

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

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "kubectl_access_ssm_policy" {
  role       = aws_iam_role.kubectl_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_policy" "kubectl_access_eks_policy" {
  name        = "${local.name}-kubectl-access-eks-policy"
  description = "Policy for kubectl access to EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = module.eks.cluster_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.artifact_bucket}/${var.artifact_prefix}/*"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "kubectl_access_eks_policy_attachment" {
  role       = aws_iam_role.kubectl_access_role.name
  policy_arn = aws_iam_policy.kubectl_access_eks_policy.arn
}

resource "aws_iam_instance_profile" "kubectl_access_profile" {
  name = "${local.name}-kubectl-access-profile"
  role = aws_iam_role.kubectl_access_role.name

  tags = local.tags
}
