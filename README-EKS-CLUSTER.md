# EKS Cluster Configuration

This document covers the infrastructure configuration and deployment of a private Amazon EKS (Elastic Kubernetes Service) cluster.

## 🏗️ Architecture Overview

This project creates a fully private EKS cluster with the following components:

- **VPC**: Custom Virtual Private Cloud with private subnets across 3 Availability Zones
- **EKS Cluster**: Private Kubernetes cluster (version 1.31) with no public endpoint access
- **VPC Endpoints**: Gateway and Interface endpoints for secure AWS service access
- **Node Groups**: Managed EKS node groups with auto-scaling capabilities
- **Security Groups**: Properly configured security groups for VPC endpoint access

### Infrastructure Components

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   AZ-1a     │  │   AZ-1b     │  │   AZ-1c     │        │
│  │ 10.0.1.0/24 │  │ 10.0.2.0/24 │  │ 10.0.3.0/24 │        │
│  │             │  │             │  │             │        │
│  │ EKS Nodes   │  │ EKS Nodes   │  │ EKS Nodes   │        │
│  │ VPC Endpts  │  │ VPC Endpts  │  │ VPC Endpts  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              VPC Endpoints (Gateway)                   │ │
│  │                    S3 Gateway                          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │            VPC Endpoints (Interface)                   │ │
│  │ ECR, EKS, EC2, ELB, STS, KMS, CloudWatch, SSM         │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Features

- **Private EKS Cluster**: No public endpoint access for enhanced security
- **Multi-AZ Deployment**: High availability across 3 availability zones
- **VPC Endpoints**: Secure access to AWS services without internet gateway
- **Auto-scaling**: EKS managed node groups with configurable scaling
- **Security Groups**: Properly configured network security
- **Terraform Modules**: Uses official AWS Terraform modules for best practices

## 📋 Prerequisites

Before deploying this infrastructure, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account with permissions to create:
  - VPC and networking resources
  - EKS clusters and node groups
  - IAM roles and policies
  - VPC endpoints
- S3 bucket for Terraform state storage (configure in `backend.tf`)

## 🛠️ Configuration

### Local Variables

The project uses the following default configuration in `locals.tf`:

```hcl
locals {
  region = "us-east-1"
  name = "private-eks"
  vpc_cidr = "10.0.0.0/16"
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  tags = {
    Environment = "dev"
    Project = "private-eks-demo"
    Terraform = true
  }
}
```

### Backend Configuration

Update `backend.tf` with your S3 bucket details:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```

## 🚀 Deployment

### Step 1: Initialize Terraform

```bash
terraform init
```

### Step 2: Review the Plan

```bash
terraform plan
```

### Step 3: Deploy Infrastructure

```bash
terraform apply
```

## 📁 Project Structure

```
eks-demo/
├── 01-vpc.tf                    # VPC configuration
├── 02-vpc-endpoints-sg.tf       # Security groups for VPC endpoints
├── 03-vpc-endpoints.tf          # VPC endpoints configuration
├── 04-eks.tf                    # EKS cluster and node groups
├── 05-iam-kubectl-access.tf     # IAM roles and policies for kubectl access
├── 06-kubectl-access-sg.tf      # Security group for kubectl access instance
├── 07-kubectl-access-instance.tf # EC2 instance for kubectl access
├── 08-outputs.tf                # Terraform outputs
├── user_data.sh                 # User data script for kubectl setup
├── backend.tf                   # Terraform backend configuration
├── locals.tf                    # Local variables and tags
├── versions.tf                  # Terraform and provider versions
└── README.md                    # Main documentation
```

## 🔧 Configuration Details

### VPC Configuration (`01-vpc.tf`)

- **CIDR**: 10.0.0.0/16
- **Subnets**: 3 private subnets across different AZs
- **NAT Gateway**: Disabled (private cluster)
- **Tags**: Properly tagged for Kubernetes integration

### VPC Endpoints (`03-vpc-endpoints.tf`)

**Gateway Endpoints:**
- S3 (for container images and logs)

**Interface Endpoints:**
- ECR API and DKR (container registry)
- EKS (Kubernetes API)
- EC2 and EC2 Messages
- Elastic Load Balancing
- STS (security token service)
- KMS (key management)
- CloudWatch Logs
- SSM and SSM Messages

### EKS Configuration (`04-eks.tf`)

- **Kubernetes Version**: 1.31
- **Node Groups**: t3.medium instances
- **Scaling**: 1-5 nodes (desired: 3)
- **Add-ons**: CoreDNS, kube-proxy, VPC CNI

## 🔒 Security Features

- **Private Cluster**: No public API endpoint access
- **Private Subnets**: All resources in private subnets
- **VPC Endpoints**: Secure AWS service access without internet
- **Security Groups**: Restrictive ingress/egress rules
- **IAM Integration**: Proper role-based access control

## 🗑️ Cleanup

To destroy all resources:

```bash
terraform destroy
```

**⚠️ Warning**: This will permanently delete all resources. Make sure to backup any important data.

## 📊 Cost Considerations

This setup includes:
- EKS cluster (fixed cost)
- EC2 instances (t3.medium)
- VPC endpoints (per endpoint)
- NAT Gateway (if enabled)
- Data transfer costs

Estimated monthly cost: ~$100-200 (depending on usage)

## 🔧 Customization

### Scaling Configuration

Modify node group settings in `04-eks.tf`:

```hcl
eks_managed_node_groups = {
  workers = {
    instance_types = ["t3.large"]  # Change instance type
    min_size     = 2               # Minimum nodes
    max_size     = 10              # Maximum nodes
    desired_size = 5               # Desired nodes
  }
}
```

### Adding VPC Endpoints

Add more endpoints in `03-vpc-endpoints.tf`:

```hcl
endpoints = merge({
  # ... existing endpoints ...
  new-service = {
    service             = "new-service"
    subnet_ids          = module.vpc.private_subnets
    private_dns_enabled = true
    tags                = { Name = "${local.name}-new-service" }
  }
})
```

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [VPC Endpoints Guide](https://docs.aws.amazon.com/vpc/latest/privatelink/)

---

**Note**: This is a demo project for educational purposes. For production use, consider additional security measures, monitoring, and backup strategies.
