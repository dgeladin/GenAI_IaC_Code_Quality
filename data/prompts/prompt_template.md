# Prompt X

## Prompt Description
Here is an example of a prompt that will be utilized to generate IaC code for a simple web server. 

## Prompt Input
```
You are an experienced DevOps engineer. Your task is to create Terraform code to provision the following resources.
- Use AWS as a resource provider.
- Use us-east-1 as the resource region.
- A Virtual Private Cloud with a public and private subnet in two Availability Zones
- A security group allowing HTTP (port 80) and SSH (port 22) access from only the 192.10 network
- An EC2 instance (t2.micro) in the public subnet running Amazon Linux 2 AMI
- Use the latest Amazon Linux 2 AMI for Ec2 Instances
- An Application Load Balancer in the public subnets
- An Auto Scaling group with a minimum of 2 instances (t2.micro) in the private subnets
- The instances should be part of a target group attached to the ALB
- Create an S3 bucket for storing logs with versioning enabled and lifecycle rules to transition objects to Glacier after 90 days
- Enable deletion protection for the S3 bucket. 

Additionally, adhere to the following IaC code style guide:

- Use descriptive and meaningful names for resources, variables, and outputs
- Follow a consistent naming convention. snake_case for resources and  PascalCase for data sources
- Group related resources together using modules or separate files
- Use consistent indentation and formatting 
- Add comments to explain complex or non-obvious code sections
- Separate resource declarations and meta-arguments using blank lines
- Use Terraform version 1.8
- Avoid hard-coding values. Use variables instead
- Validate input variables using type constraints and default values
```
