# Prompt Set (Blue/Green Deployments):

## Prompt 1 (General Setup):

You are a DevOps engineer tasked with creating a Terraform configuration to implement blue/green deployments for a web application on AWS.
Your task is to create a blue and green environment for application version transitions.

Use AWS as the resource provider.
Use us-east-1 as the default resource region.
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

## Prompt 3 (VPC and Security Group):

Create a VPC with private and public subnets using a pre-built module (consider terraform-aws-modules/vpc/aws) or define them manually.  
Configure two security groups:
* app_sg for the application instances: Allow inbound traffic on port 80 (HTTP) from the lb_sg security group. Allow outbound traffic on all ports and protocols 0.0.0.0/0 for demonstration purposes only. In a real-world scenario, restrict outbound traffic as much as possible.
* lb_sg for the load balancer: Allow inbound traffic on port 80 (HTTP) from 0.0.0.0/0. Allow outbound traffic to the app_sg on port 80."

## Prompt 4 (Launch Templates for Blue/Green):

Building upon the previous steps:

Create separate launch templates for the blue and green environments (aws_launch_template).
Specify a Amazon Linux AMI, instance type (e.g., t3.micro), and security group association with app_sg.
Use user data scripts for each template to demonstrate basic functionality.
Use distinct user data scripts to differentiate the environments:
* Blue: #!/bin/bash\necho "Hello from Blue Environment" > index.html\nsudo yum install -y python3 && nohup python3 -m http.server 80 &
* Green: #!/bin/bash\necho "Hello from Green Environment" > index.html\nsudo yum install -y python3 && nohup python3 -m http.server 80 &
Add tags to the launch templates to easily identify them (e.g., Environment: blue or Environment: green)."

## Prompt 5 (Auto Scaling Groups):

Building upon the previous steps:

Introduce Auto Scaling Groups (ASGs) for each environment:

Create ASGs named blue-asg and green-asg with desired capacity, minimum of 2 and maximum size of 5.
Associate each ASG with its corresponding launch template version (using $Latest).
Connect each ASG to its respective target group using target_group_arns.
Configure health checks for the ASGs to monitor instance health on port 80."

## Prompt 6 (Application Load Balancer):

Building upon the previous steps:

Implement the load balancing component for blue/green deployment:

Create an Application Load Balancer (app_lb) with appropriate security group association and public subnets.
Define separate target groups named blue-tg and green-tg for each environment, specifying port and protocol (HTTP) within the VPC.

## Prompt 7 (Listener Rule and Output):

Building upon the previous steps:

Configure the listener for blue/green deployment:

Create a listener rule (front_end) on the load balancer (using aws_lb_listener) to route traffic initially to the blue environment by default.  
Set the listener port to 80 (HTTP) and use a forward action that points to the blue-tg target group.  
Output the load balancer's DNS name for easy access to the deployed application.  

[List of Scenarios](../scenarios.md)

