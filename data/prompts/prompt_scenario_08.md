# Prompt Set (Managing AWS Spot Instances):

## Prompt 1 (General Setup):

You are an experienced DevOps engineer specializing in Infrastructure as Code (IaC). 

Utilize Terraform to automate the provisioning and management of an Auto Scaling group (ASG) that utilizes a mix of On-Demand and Spot Instances.
Ensure the ASG maintains a desired level of availability and performance while taking advantage of Spot Instances' cost benefits.

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

## Prompt 3 (Launch Template for Common Configuration):

Building upon the previous steps:

Create a launch template named example-template.  
Specify the desired AMI (Amazon Linux 2 in this example, adjust as needed) and instance type (t3.micro).  
Remember to add additional configuration within the launch template as needed (security groups, IAM instance profile, etc.)  

## Prompt 4 (Auto Scaling Group with Mixed Instances):

Building upon the previous steps:

Define the Auto Scaling group (example-asg)  
Set the desired VPC subnets using vpc_zone_identifier.  
Configure minimum (min_size), maximum (max_size), and desired capacity (desired_capacity) for the ASG.  

## Prompt 5 (Mixed Instances Policy with Spot Optimization):

Building upon the previous steps:

Define a mixed instances policy to manage the mix of On-Demand and Spot Instances.

Utilize the mixed_instances_policy block to define the instance types and their weightings within the ASG.  
Use the launch template (aws_launch_template.example.id) as the base configuration for all instances.  
Specify overrides for two instance types (t3.micro and t3.small) with their respective weighted capacities (weighted_capacity). This defines the relative likelihood of each type being launched.  

## Prompt 6 (Instances Distribution and Spot Allocation Strategy):

Building upon the previous steps:

Configure the desired distribution of On-Demand and Spot Instances within the ASG.  

Define the instances_distribution block within the mixed instances policy.  
Set a base capacity of on-demand instances (on_demand_base_capacity) for guaranteed availability.  
Specify a percentage increase in on-demand instances above the base capacity (on_demand_percentage_above_base_capacity) to ensure some level of redundancy.
Choose a spot_allocation_strategy of capacity-optimized to prioritize filling the ASG with Spot Instances while maintaining overall capacity.  
Add scaling policies to the ASG to automatically adjust capacity based on low memory.  

## Prompt 7 (Tagging):

Building upon the previous steps:

Add a tag to all instances launched by the ASG.  
Define a tag named Name with the value ASG-Instance to easily identify these instances.  
Set propagate_at_launch to true to ensure the tag is applied when instances are launched.  

[List of Scenarios](../scenarios.md)
