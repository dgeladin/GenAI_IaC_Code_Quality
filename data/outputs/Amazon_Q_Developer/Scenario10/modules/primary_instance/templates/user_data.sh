#!/bin/bash
set -e

# Update system
yum update -y

# Install AWS CLI and SSM Agent
yum install -y aws-cli amazon-ssm-agent

# Start SSM Agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Configure instance
aws configure set region ${region}

# Tag volumes
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
VOLUMES=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$INSTANCE_ID --query 'Volumes[*].VolumeId' --output text)

for VOLUME_ID in $VOLUMES; do
  aws ec2 create-tags --resources $VOLUME_ID --tags Key=Environment,Value=${environment}
done

# Set up monitoring
yum install -y amazon-cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/AmazonCloudWatch-Config

# Log completion
echo "Instance initialization completed" | logger -t user-data
