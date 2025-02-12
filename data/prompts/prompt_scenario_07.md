# Prompt Set (Multi-Environment Deployment Pipeline):

## Prompt 1 (General Setup and Objective):

You are tasked with creating a multi-environment infrastructure deployment pipeline using Terraform and GitHub Actions.
You will be focusing on the Terraform code as part of this project. 

Implement a GitOps-style workflow for automated infrastructure changes based on Git branches.
Utilize Terraform workspaces to manage infrastructure configurations for different environments (development, staging, production).
Create the following Terraform code to implement the infrastructure. 

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

## Prompt 3 (Terraform Workspace and Modules):

Building upon the previous steps:

Define a local variable environment to dynamically retrieve the current Terraform workspace name.
Utilize Terraform modules for reusability:
* Create a network module (network) located in ../modules/network.
* Create a compute module (compute) located in ../modules/compute.
* Create a compute module (database) located in ../modules/database.

Each module should receive the environment variable to configure infrastructure based on the environment.

## Prompt 4 (Network Module):

Building upon the previous steps:

This module should handle all networking components:

VPC:  
cidr_block: Use a variable and use 10.0.0.0/16.  
enable_dns_hostnames: true

Subnets (Public and Private):    
availability_zones: Use a variable and ensure you have at least two. Example: ["us-east-1a", "us-east-1b"].  
public_subnet_cidrs: Use a variable and use: ["10.0.1.0/24", "10.0.2.0/24"].  
private_subnet_cidrs: Use a variable and use: ["10.0.10.0/24", "10.0.11.0/24"].  
tags: Include tags for each subnet, differentiating between public and private.  

Security Groups:  
web_server_sg: Allows inbound HTTP/HTTPS from the load balancer security group and outbound to the database security group.  
database_sg: (Defined in the database module, but the network module should output its ID so it can be referenced). Allows inbound traffic on the database port (5432 for PostgreSQL) from the web_server_sg.  

Outputs:
* vpc_id
* public_subnet_ids
* private_subnet_ids
* web_server_sg_id
* database_sg*

## Prompt 5 (Compute Module):

Building upon the previous steps:

This module handles the compute resources.

Launch Template:  
* ami: Use a data source (aws_ami) to fetch the latest Amazon Linux 2 AMI ID.   
* instance_type: Use a variable and configure per environment: t3.micro (development), t3.medium (staging), t3.large (production).  

Auto Scaling Group (ASG):  
* desired_capacity, min_size, max_size: Use variables. desired_capacity = 2, min_size = 2, max_size = 5.  
* vpc_zone_identifier: Use the public_subnet_ids from the network module.    
* health_check_type: EC2     

Load Balancer (ALB):  
* subnets: Use the public_subnet_ids from the network module.  
* security_groups: Use the load_balancer_sg_id from the network module.  
* target_group: Create a target group and associate it with the ASG.  
* listener: Create a listener on port 443 for HTTPS and forward traffic to the target group. 

## Prompt 6 (Database Module):

Building upon the previous steps:

This module handles the database resources.  

The module should accept the following input variables:  
* environment (string): The name of the environment (e.g., "development", "staging", "production").  
* db_name (string): The name of the database.  
* db_username (string): The database username.  
* db_password (string): The database password (Store securely).  
* db_instance_class (string): The RDS instance class (e.g., "db.t3.micro"). Use different instance classes based on the environment variable (e.g., db.t3.micro for development, db.t3.medium for staging, db.m5.large for production).  
* db_allocated_storage (number): The allocated storage in GB.
* db_port (number): The database port (5432 for PostgreSQL).
* db_subnet_group_name (string): The name of the DB subnet group (defined in the network module)
* db_security_group_id (string): The ID of the database security group (defined in the network module).

Within the module, create the following resource:  
* aws_db_instance: Create the PostgreSQL RDS instance using the provided variables.  
Set the db_subnet_group_name and vpc_security_group_ids using the resources created within the module.  

The module should output the database endpoint (db_endpoint).

## Prompt 7 (IAM Roles):

Building upon the previous steps:

Create two IAM roles:
* db_admin_role: This role will be used by administrators to manage the database.  It should have full access to the RDS instance.  
* db_migration_role: This role will be used for database migrations.  It should have permissions to connect to the RDS instance and run SQL commands.  

Create IAM users or groups as needed and attach the appropriate roles to them.  For this exercise, you can assume that these roles are used by the deployment pipeline.  

Create any additional configuration files to complete the Terraform project structure.

[List of Scenarios](../scenarios.md)
