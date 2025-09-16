REGION=<your-region>
BUCKET=<artifact-bucket>
PREFIX=tools

# AWS CLI v2
curl -fSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
aws s3 cp awscliv2.zip s3://$BUCKET/$PREFIX/awscliv2/awscli-exe-linux-x86_64.zip --region $REGION

# eksctl (pin a version you trust)
VER=0.190.0
curl -fSL https://github.com/weaveworks/eksctl/releases/download/v${VER}/eksctl_Linux_amd64.tar.gz -o eksctl.tar.gz
aws s3 cp eksctl.tar.gz s3://$BUCKET/$PREFIX/eksctl/eksctl_Linux_amd64.tar.gz --region $REGION
