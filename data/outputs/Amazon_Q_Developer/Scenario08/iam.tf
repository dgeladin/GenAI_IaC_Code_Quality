# IAM role for EC2 instances in the ASG
resource "aws_iam_role" "asg_role" {
  name = "${local.name_prefix}-asg-role"
  path = "/"

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

  tags = local.common_tags
}

# IAM instance profile for EC2 instances
resource "aws_iam_instance_profile" "asg_profile" {
  name = "${local.name_prefix}-asg-profile"
  role = aws_iam_role.asg_role.name

  tags = local.common_tags
}

# Basic policy for EC2 instances
resource "aws_iam_role_policy" "asg_policy" {
  name = "${local.name_prefix}-asg-policy"
  role = aws_iam_role.asg_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

# SSM policy attachment for instance management
resource "aws_iam_role_policy_attachment" "asg_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.asg_role.name
}

# CloudWatch agent policy attachment for metrics
resource "aws_iam_role_policy_attachment" "asg_cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.asg_role.name
}
