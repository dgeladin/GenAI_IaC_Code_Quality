# Prompt Set (Automating Disaster Recovery with Terraform):

## Prompt 1 (General Setup):

You are an experienced DevOps engineer specializing in Infrastructure as Code (IaC). 

Utilize Terraform to automate the provisioning and configuration of key resources for DR.  
Leverage Terraform providers for both the primary region (us-west-2) and the disaster recovery (DR) region (us-east-1).  
Implement a comprehensive approach involving data backup, replication, and failover mechanisms.  

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

## Prompt 3 (Secure S3 Bucket for Backups):

Building upon the previous steps:

Create a secure S3 bucket for storing backups in the DR region:

Define an S3 bucket named example-dr-backup-bucket with private access control (ACL).  
Enable versioning for the bucket to maintain historical backups and prevent accidental data loss.  
Configure a lifecycle rule for the bucket to automatically transition data to cost-effective Glacier storage after 30 days and permanently delete backups after 90 days.  

## Prompt 4 (Primary Instance and Data Volume):

Building upon the previous steps:

Define the resources for the primary site:  

Create an EC2 instance (primary) with a specific AMI (ami-0c55b159cbfafe1f0) and instance type (t3.micro) in the primary region.  
Provision an EBS volume (primary_data) with desired size (100 GiB) and type (gp3) in the same availability zone as the instance.  
Attach the EBS volume to the EC2 instance (primary_data_attachment) for data persistence.  

## Prompt 5 (AWS Elastic Disaster Recovery (DRS) Configuration):

Building upon the previous steps:

Utilize AWS DRS to replicate the primary instance and volume to the DR region:  
 
Define a DRS replication configuration template (example) with the following details:  
Specify the source server attributes like instance type (t3.micro) and tags for identification.  
Configure EBS encryption within the template using a KMS key to ensure data security during replication.  

## Prompt 6 (KMS Key for DR Encryption):

Building upon the previous steps:

Create a KMS key (dr_key) for encrypting data replicated to the DR region:  

Set a descriptive name for the KMS key and configure a 10-day deletion window for potential recovery in case of accidental deletion.  
Enable automatic key rotation to maintain long-term data security.  

## Prompt 7 (CloudWatch Event Rule for DR Failover):

Building upon the previous steps:

Automate DR failover triggered by specific events:  

Define a CloudWatch event rule (dr_failover) with a descriptive name and purpose.  
Use a JSON-encoded event pattern to trigger the rule based on AWS Health events:  
Specify the event source as aws.health and event type as AWS Health Event.  
Filter events for EC2 service within the primary region (us-west-2) and events categorized as issues.  

## Prompt 8 (Lambda Function for DR Failover Process):

Building upon the previous steps:

Develop a Lambda function (dr_failover) to handle DR failover upon receiving the CloudWatch event:  
Initiate DRS failover execution and notify administrators that it has executed.  
Provide the Lambda function code in a ZIP file (dr_failover_function.zip).  
Define the function name, IAM role, handler, and runtime environment (Node.js 14.2).  
Set an environment variable named DR_CONFIGURATION_ID within the function to access the DRS replication configuration template ID.  

## Prompt 9 (IAM Role for Lambda Function):

Building upon the previous steps:

Create an IAM role (dr_lambda_role) to grant necessary permissions to the Lambda function:  
Set an appropriate role name and define an assume role policy to allow Lambda service to assume this role for execution.  

## Prompt 10 (CloudWatch Event Target for Lambda Function):

Building upon the previous steps:

Integrate the CloudWatch event rule and Lambda function for automated response:  
Define a CloudWatch event target that connects the dr_failover rule to the dr_failover Lambda function.  

[List of Scenarios](../scenarios.md)
