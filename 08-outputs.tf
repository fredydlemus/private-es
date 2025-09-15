output "kubectl_access_instance_id" {
  description = "ID of the EC2 instance for kubectl access"
  value       = aws_instance.kubectl_access.id
}

output "kubectl_access_instance_private_ip" {
  description = "Private IP of the kubectl access instance"
  value       = aws_instance.kubectl_access.private_ip
}

output "kubectl_access_ssm_command" {
  description = "AWS CLI command to start SSM session for kubectl access"
  value       = "aws ssm start-session --target ${aws_instance.kubectl_access.id} --region ${local.region}"
}

output "kubectl_access_instructions" {
  description = "Instructions for accessing kubectl"
  value       = <<-EOT
    To access your private EKS cluster via kubectl:
    
    1. Start an SSM session:
       aws ssm start-session --target ${aws_instance.kubectl_access.id} --region ${local.region}
    
    2. Once connected, run the helper script:
       ./kubectl-helper.sh
    
    3. Test the connection:
       kubectl cluster-info
       kubectl get nodes
    
    4. View the welcome message:
       cat welcome.txt
    
    Note: Make sure you have AWS CLI configured with appropriate permissions
    and the AWS SSM plugin installed for session manager.
  EOT
}

output "eks_cluster_info" {
  description = "EKS cluster information"
  value = {
    cluster_name              = module.eks.cluster_name
    cluster_arn               = module.eks.cluster_arn
    cluster_endpoint          = module.eks.cluster_endpoint
    cluster_security_group_id = module.eks.cluster_security_group_id
  }
}
