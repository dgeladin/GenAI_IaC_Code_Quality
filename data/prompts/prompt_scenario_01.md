# Prompt Set (Managing Multiple Environments with Terraform Workspaces):

## Prompt 1 (General Setup):

You are an experienced DevOps engineer specializing in Infrastructure as Code (IaC). 
Your task is to create Terraform code to provision resources in AWS.

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

## Prompt 3 (Workspaces and Basic Variables):

Using the style guide from the previous step, create Terraform code that utilizes Terraform workspaces to manage different environments.  

Define a variable named environment that defaults to the current Terraform workspace (terraform.workspace).  
Define a variable called instance_type that is a map of strings.   
The map should have default, dev, and prod keys with corresponding instance types: t2.micro (default), t2.small (dev), and t2.medium (prod).  
Define variables with ami_id for windows and AWS linux AMIs.  

## Prompt 4 (Resource Quantities):

Building upon the code from the previous steps:

Create one Windows aws_instance resources dev.  
Create two Windows aws_instance resoruces in prod.  
Create one AWS Linux aws_instance resource in dev.  
Create three AWS Linux aws_instance resources in prod. 

## Prompt 5 (Defining the Configuration)

The ami should be taken from the ami_id variables.  
The instance_types and quantity should be dynamically selected from the instance_type map based on the current Terraform workspace (using terraform.workspace).   
Add a tag to the aws_instance resource with the key Name.  
 The value of the tag should be a string that includes the instance name "example-instance-" followed by the current Terraform workspace (e.g., "example-instance-dev").  
Add a tag to the aws_instance resources for created_by, specifying Terraform as the creation tool.   


[List of Scenarios](../scenarios.md)
