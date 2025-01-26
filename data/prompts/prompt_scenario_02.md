# DONE
# Prompt Set (High Availability):

## Prompt 1 (General Setup):

You are an experienced DevOps engineer specializing in Infrastructure as Code (IaC). 
Your task is to create Terraform code to deploy a highly available web application across multiple regions in AWS.

Use Terraform with multiple AWS provider configurations for different regions.
Focus on high availability and fault tolerance.
Wait to provide any code until the requirements are provided.

## Prompt 2 (IaC Style Guide):

Adhere to the following IaC style guidelines:

* Use Terraform best practices including security best practices.
* Use descriptive and meaningful names for resources, variables, and outputs.
* Follow a consistent naming convention: snake_case for resources and PascalCase for data sources.
* Group related resources together using modules or separate files (if appropriate for the scale of this task).
* Use consistent indentation and formatting.
* Add comments to explain complex or non-obvious code sections.
* Separate resource declarations and meta-arguments using blank lines.
* Use Terraform version 1.8 or later if features are needed.
* Avoid hard-coding values. Use variables instead.
* Validate input variables using type constraints and default values.
* Assume the use of pre-built Terraform modules if available (e.g., terraform-aws-modules/vpc/aws).
* Ensure to list what the name of the terraform file is when generating the code.

Wait to provide any code until the requirements are provided.

## Prompt 3 (Multi-Region Providers and VPC Modules):

Using the style guide from the previous step:

Configure multiple AWS provider blocks with aliases for multiple regions. (us-east-1 and us-west-2)  
Utilize separate modules for VPC creation in each region (vpc module).  
Use 10.0.0.0/16 CIDR for the East region and 10.1.0.0/16 for the West region.  

## Prompt 4 (Auto Scaling Groups in Regions):

Building upon the previous steps:

Create another module (asg module) to define the Auto Scaling Groups.
Use this module to create Auto Scaling Groups in each region (e.g., asg_east and asg_west).
Pass required information to the ASG module, such as:
VPC ID (from VPC modules)
Public subnet IDs (from VPC modules)
Minimum, maximum, and desired capacity for instances (min 2, max 5, and desired capacity 2)
Instance type (t3.micro)
Application name (example-app in this case)

## Prompt 5 (Global Accelerator and Load Balancers):

Building upon the previous steps:

Create a global accelerator resource (aws_globalaccelerator_accelerator).  
Define a listener for the global accelerator with client affinity and TCP protocol for port 80.  
Introduce another resource, aws_globalaccelerator_endpoint_group, to attach regional load balancers to the global accelerator.  
Use the output (alb_arn) from the ASG module (presumably containing the regional load balancers) as the endpoint IDs for the global accelerator group.  
Set equal weights (e.g., 50) for each endpoint in the group.  

[List of Scenarios](../scenarios.md)
