# Prompt Set (RDS Instances and Security Groups):

## Prompt 1 (General Setup):

You are an experienced DevOps engineer specializing in Infrastructure as Code (IaC). 
Your task is to create RDS Instances and Security Groups in AWS.

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

## Prompt 3 (RDS Instance and Security Group):

Building upon the previous steps:

Define an RDS instance named example-db with the following specifications:
* engine (mysql) 
* engine version (8.0)
* instance class (db.t3.micro)
* allocated_storage = 20
* db_name = myapp  
Use Terraform variables for the following sensitive data:  
* username 
* password  

Associate the RDS instance with a DB subnet group and the security group (to be defined in the next step).    

## Prompt 4 (Security Group and DB Subnet Group):

Building upon the previous steps:

Create a security group named db_sg specifically for the RDS instance. 

Allow inbound traffic only on port 3306 (MySQL) using the TCP protocol.  
Restrict access to the security group by specifying a CIDR block that matches the VPC CIDR (10.0.0.0/16).  

Define a DB subnet group:
* Create a DB subnet group named example-db-subnet-group.  
* Reference existing subnet IDs stored in Terraform variables (e.g., var.private_subnet_ids). 

## Prompt 5 (Database Migration Script):

Building upon the previous steps:

Utilize the template_file data source to read the initial schema creation script (V1__initial_schema.sql) from a specific location within the Terraform module directory.  
Ensure the script path is relative to the module location using ${path.module}.

## Prompt 6 (Executing the Migration Script):

Building upon the previous steps:

Create a null_resource named db_migration with a trigger based on the SHA256 hash of the migration script (using data.template_file.migration_script.rendered).  
This ensures the migration runs only if the script content changes.  
Define a local-exec provisioner within the null resource to execute a shell command.  
The command should use mysql cli and connect to the RDS instance endpoint, username, and password (reference Terraform variables).  
Pipe the rendered migration script content ({path.module}/migrations/V1__initial_schema.sql) to the mysql command for execution.  
Make sure the null resource depends on the RDS instance creation (aws_db_instance.example) to ensure the database exists before migration.  

## Prompt 7 (Output and Considerations):

Building upon the previous steps:

Output the RDS instance endpoint for connection purposes.
Define an output variable named db_endpoint referencing the endpoint of the aws_db_instance.example resource.
Create any additional configuration files to complete the Terraform project structure.

[List of Scenarios](../scenarios.md)
