#!/bin/bash

# Install AWS CLI v2
aws s3 cp "s3://${artifact_bucket}/${artifact_prefix}/awscliv2/awscli-exe-linux-x86_64.zip" awscliv2.zip
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install kubectl
curl -o kubectl https://s3.us-east-1.amazonaws.com/amazon-eks/1.31.0/2024-05-08/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin

# Install eksctl
aws s3 cp "s3://${artifact_bucket}/${artifact_prefix}/eksctl/eksctl_Linux_amd64.tar.gz" /tmp/eksctl.tar.gz
tar -xzf /tmp/eksctl.tar.gz -C /tmp
mv /tmp/eksctl /usr/local/bin
rm -rf /tmp/eksctl.tar.gz

# Configure AWS CLI region
aws configure set region ${region}

# Update kubeconfig for the EKS cluster
aws eks update-kubeconfig --region ${region} --name ${cluster_name}

# Create a simple script for easy kubectl access
cat > /home/ec2-user/kubectl-helper.sh << 'EOF'
#!/bin/bash
echo "EKS Cluster: ${cluster_name}"
echo "Region: ${region}"
echo ""
echo "Available kubectl commands:"
echo "  kubectl get nodes"
echo "  kubectl get pods -A"
echo "  kubectl get services -A"
echo "  kubectl get namespaces"
echo ""
echo "To check cluster connection:"
echo "  kubectl cluster-info"
echo ""
echo "To get cluster details:"
echo "  aws eks describe-cluster --name ${cluster_name} --region ${region}"
EOF

chmod +x /home/ec2-user/kubectl-helper.sh
chown ec2-user:ec2-user /home/ec2-user/kubectl-helper.sh

# Create a welcome message
cat > /home/ec2-user/welcome.txt << 'EOF'
========================================
EKS Kubectl Access Instance
========================================

This instance is configured for kubectl access to your private EKS cluster.

To get started:
1. Run: ./kubectl-helper.sh
2. Test connection: kubectl cluster-info
3. List nodes: kubectl get nodes

The instance has the following tools installed:
- AWS CLI v2
- kubectl
- eksctl

Cluster: ${cluster_name}
Region: ${region}
========================================
EOF

chown ec2-user:ec2-user /home/ec2-user/welcome.txt

# Signal that the instance is ready
/opt/aws/bin/cfn-signal -e $? --stack ${cluster_name}-kubectl-access --resource EC2Instance --region ${region} || true
