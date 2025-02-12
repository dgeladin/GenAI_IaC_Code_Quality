# Prompt Set (Automating Serverless Application Deployment):

## Prompt 1 (General Setup and Objective):

You are a DevOps engineer tasked with creating a Terraform configuration to automate the deployment of a serverless application on AWS.

Focus on deploying a simple Lambda function triggered by an API Gateway request.
Leverage Terraform to manage the entire infrastructure stack, including IAM roles, Lambda function, API Gateway resources, and permissions.
Use a Node.js Lambda function.

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

## Prompt 3 (IAM Role for Lambda and Permissions):

Building upon the previous steps:

Create an IAM role named serverless_lambda_role with an appropriate assume role policy.  
This policy allows the Lambda service to assume the role for execution.  
Attach the AWSLambdaBasicExecutionRole managed policy to the IAM role using aws_iam_role_policy_attachment to grant basic execution permissions.  

## Prompt 4 (Lambda Function Configuration):

Building upon the previous steps:

Specify the function name (example_lambda_function), runtime (nodejs14.x), and the role it should use (aws_iam_role.lambda_exec.arn).  
Set the handler (index.handler) to the exported function within the Lambda code. 
Use the filename argument to reference the ZIP archive containing the Lambda function code (lambda_function.zip).  
Calculate the source code hash (source_code_hash) using filebase64sha256 to ensure deployment only occurs if the code changes.  

## Prompt 5 (API Gateway Setup):

Building upon the previous steps:  

Create an API Gateway REST API named example_api with a descriptive name.  
Create an API Gateway resource (example) with a specific path part (example).    
Define an API Gateway method (example) within the resource for the HTTP method (GET) and configure it to use NONE for authorization.
Create an API Gateway integration (example) to connect the API Gateway resource and method to the Lambda function.    
Set the integration type to AWS_PROXY to allow the Lambda function to handle the request and response.  
Use the Lambda function's invoke_arn to specify the integration target.

## Prompt 6 (API Gateway Deployment and Permissions):

Building upon the previous steps:

Create an API Gateway deployment (example) with a stage name (prod) to expose the API publicly.   
Ensure the deployment depends on the integration creation (aws_api_gateway_integration.example) for proper order.  
Define a Lambda permission (apigw_lambda) allowing API Gateway to invoke the Lambda function.  
Specify the source Lambda ARN using to restrict invocation only from the specific API Gateway resource and method.

## Prompt 7 (Output):

Building upon the previous steps:
  
Use an output variable named api_url to construct the API Gateway URL by combining the deployment invoke URL and resource path.  
Create any additional configuration files to complete the Terraform project structure.

[List of Scenarios](../scenarios.md)
