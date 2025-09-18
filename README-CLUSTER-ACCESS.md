# EKS Cluster Access Guide

This document covers how to securely access and manage your private EKS cluster using AWS SSM Session Manager and kubectl.

## 🔐 Overview

Since this is a private EKS cluster with no public endpoint access, you'll need to use AWS SSM Session Manager to access kubectl. The infrastructure includes a dedicated EC2 instance configured for kubectl access.

## 📋 Prerequisites for kubectl Access

1. **AWS CLI configured** with appropriate permissions
2. **AWS SSM Session Manager plugin** installed:

### Installing AWS SSM Session Manager Plugin

#### macOS
```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
unzip sessionmanager-bundle.zip
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
```

#### Linux
```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
```

#### Windows
Download and install from: [AWS Session Manager Plugin Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

## 🚀 Connecting to kubectl

### Step 1: Get the Connection Command

After deployment, use the output command to get the connection details:

```bash
# Get the connection command from Terraform outputs
terraform output kubectl_access_ssm_command
```

### Step 2: Connect to the Instance

```bash
# Connect directly (replace with your instance ID from the output)
aws ssm start-session --target i-1234567890abcdef0 --region us-east-1
```

### Step 3: Verify Connection

Once connected to the EC2 instance, verify your setup:

```bash
# Check if kubectl is available
kubectl version --client

# Check AWS CLI configuration
aws sts get-caller-identity

# View the helper script
./kubectl-helper.sh
```

## 🛠️ Using kubectl

### Basic Commands

```bash
# Test cluster connection
kubectl cluster-info

# List nodes
kubectl get nodes

# List all pods across all namespaces
kubectl get pods -A

# List namespaces
kubectl get namespaces

# Get cluster details
kubectl get nodes -o wide
```

### Advanced Operations

```bash
# View cluster details via AWS CLI
aws eks describe-cluster --name private-eks --region us-east-1

# List EKS node groups
aws eks list-nodegroups --cluster-name private-eks --region us-east-1

# Describe a specific node group
aws eks describe-nodegroup --cluster-name private-eks --nodegroup-name workers --region us-east-1
```

### Working with Applications

```bash
# Create a namespace
kubectl create namespace my-app

# Deploy a sample application
kubectl create deployment nginx --image=nginx --namespace=my-app

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=ClusterIP --namespace=my-app

# Check the service
kubectl get services --namespace=my-app

# View pod logs
kubectl logs -l app=nginx --namespace=my-app
```

## 🔧 What's Pre-installed

The kubectl access instance comes with:

- **AWS CLI v2**: Latest version for AWS service interaction
- **kubectl**: Kubernetes command-line tool
- **eksctl**: EKS command-line tool
- **Pre-configured kubeconfig**: Ready to use with your cluster
- **Helper scripts**: Convenient scripts for common operations

### Helper Scripts

The instance includes a `kubectl-helper.sh` script with useful functions:

```bash
# View available helper functions
./kubectl-helper.sh

# Common helper functions include:
# - Cluster status check
# - Node information
# - Pod management
# - Service discovery
```

## 🔒 Security Features

### Network Security
- The EC2 instance is in a private subnet with no public IP
- Access is only possible through AWS SSM Session Manager
- All network traffic goes through VPC endpoints

### IAM Security
- The instance has minimal IAM permissions (only EKS read access)
- Role-based access control through AWS IAM
- No long-term credentials stored on the instance

### Session Security
- All sessions are logged and auditable
- Session Manager provides encryption in transit
- No SSH keys or passwords required

## 🚨 Troubleshooting

### Common Issues

#### Cannot connect to the instance
```bash
# Check if the instance is running
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 --region us-east-1

# Verify SSM agent is running
aws ssm describe-instance-information --filters "Key=InstanceIds,Values=i-1234567890abcdef0" --region us-east-1
```

#### kubectl commands fail
```bash
# Check kubeconfig
kubectl config view

# Verify cluster connectivity
kubectl cluster-info

# Check AWS credentials
aws sts get-caller-identity
```

#### Permission denied errors
```bash
# Verify IAM role permissions
aws iam get-role --role-name private-eks-kubectl-access-role

# Check attached policies
aws iam list-attached-role-policies --role-name private-eks-kubectl-access-role
```

### Getting Help

```bash
# View instance logs
sudo journalctl -u amazon-ssm-agent

# Check kubectl configuration
kubectl config get-contexts

# View AWS configuration
aws configure list
```

## 📊 Monitoring and Logging

### CloudWatch Integration

The setup includes CloudWatch logging for:
- EKS cluster logs
- Application logs
- System logs from the access instance

### Viewing Logs

```bash
# View EKS cluster logs
aws logs describe-log-groups --log-group-name-prefix /aws/eks/private-eks

# Stream logs in real-time
aws logs tail /aws/eks/private-eks/cluster --follow
```

## 🔄 Maintenance

### Updating kubectl

```bash
# Update kubectl to latest version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### Updating AWS CLI

```bash
# Update AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
```

## 📚 Additional Resources

- [AWS SSM Session Manager Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

**Note**: This access method provides secure, auditable access to your private EKS cluster without compromising security by exposing public endpoints.
