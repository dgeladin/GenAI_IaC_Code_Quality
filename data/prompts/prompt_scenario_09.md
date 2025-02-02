# Prompt Set (Multicloud Monitoring with Datadog):

## Prompt 1 (General Setup):

You are an experienced DevOps engineer specializing in Infrastructure as Code (IaC). 

Configure Terraform providers for AWS, Azure, and Datadog.  
Deploy sample resources on both AWS (EC2 instance) and Azure (virtual machine).  
Utilize Datadog monitors to track CPU utilization on both cloud platforms and trigger alerts if thresholds are exceeded.  
Create a Datadog dashboard to visualize CPU usage across the AWS and Azure resources.  

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

## Prompt 3 (Configure Providers with Secrets):

Building upon the previous steps:

Define the providers for each cloud platform and Datadog:  

Set the AWS region (us-east-1) and leave the Azure provider configuration empty for now.  
Use Terraform variables (datadog_api_key and datadog_app_key) to store sensitive Datadog credentials securely using environment variables.  

## Prompt 4 (Sample Cloud Resources):

Building upon the previous steps:

Deploy example resources on both AWS and Azure:

On AWS, create an EC2 instance with a specific AMI (ami-0c55b159cbfafe1f0) and instance type (t3.micro).  
On Azure, create a resource group named example-resources and a virtual machine named example-vm with a desired size (Standard_DS1_v2).  

## Prompt 5 (Datadog Monitors for Cloud Resources):

Building upon the previous steps:

Define Datadog monitors to track CPU utilization:

Create separate monitors for AWS and Azure resources using the datadog_monitor resource.  
Set the monitor type to metric alert and define appropriate messages for each cloud platform.  
Utilize Datadog query language to target specific metrics:  
* For AWS, query the avg:aws.ec2.cpu metric for the specific instance ID obtained from Terraform (aws_instance.example.id).  
* For Azure, use the avg:azure.vm.percentage_cpu metric targeting the resource group and virtual machine names obtained from Terraform.  

Set a critical threshold of 80% CPU utilization for both monitors to trigger alerts.  

## Prompt 6 (Datadog Dashboard for Multi-Cloud Visibility):

Building upon the previous steps:

Create a Datadog dashboard named Multi-Cloud Overview to visualize CPU usage across both platforms:  
Define the dashboard title, description, and layout type (ordered).  

Utilize a timeseries widget with two data requests:  
Use the same Datadog queries used in the monitors to fetch CPU usage data for both the AWS and Azure resources.  
Set appropriate display types for each data request to visualize the data on a single chart.  

## Prompt 7 (Output Datadog Dashboard URL):

Building upon the previous steps:

Store the Datadog dashboard URL in a Terraform output variable:  

Use the Datadog dashboard ID retrieved from the datadog_dashboard resource to construct the complete URL.  
The output will provide a link to access the centralized dashboard for monitoring the multi-cloud resources.  

[List of Scenarios](../scenarios.md)
