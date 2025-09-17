curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.4/2025-08-20/bin/linux/amd64/kubectl
aws s3 cp kubectl s3://${bucket}/${prefix}/kubectl --region ${region}