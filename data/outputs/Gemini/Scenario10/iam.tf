# iam.tf

resource "aws_iam_role" "dr_lambda_role" {
  name = "dr-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "dr-lambda-role"
    Environment = "dr"
  }
}

resource "aws_iam_policy" "dr_lambda_policy" {
  name = "dr-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "drs:StartRecoveryInstances",
          "drs:DescribeRecoveryInstances",
          "drs:ListRecoveryPoints",
        ],
        Effect   = "Allow",
        Resource = [
           aws_drs_replication_configuration_template.drs_template.arn,
           "arn:aws:drs:us-east-1:123456789012:recovery-point/*" # Example: Replace with your account ID
           # ... other DRS ARNs as needed ...
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/lambda/dr-failover-function:*" # Example: Replace with your account ID and function name
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dr_lambda_policy_attachment" {
  role       = aws_iam_role.dr_lambda_role.name
  policy_arn = aws_iam_policy.dr_lambda_policy.arn
}