curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-05-08/bin/linux/amd64/kubectl
aws s3 cp kubectl s3://${bucket}/${prefix}/kubectl --region ${region}