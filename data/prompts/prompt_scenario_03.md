# DONE
# Scenario 3 Prompts (EKS Cluster)

## Prompt 1 (General Setup):

You are an experienced DevOps engineer specializing in Infrastructure as Code (IaC). 
Your task is to create Terraform code to provision a scalable Kubernetes cluster on AWS EKS.

Use AWS as the resource provider.
Use us-east-1 as the default resource region.
Follow the provided Terraform code structure and naming conventions.
Assume the use of pre-built Terraform modules for VPC and EKS cluster creation.
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

## Prompt 3 (VPC Module)

Building upon the previous steps:

Utilize the pre-built Terraform module (terraform-aws-modules/vpc/aws) for creating a VPC for the EKS cluster.
Specify the module source, version (3.14.0), and necessary configuration options:
* Name of the VPC (eks-vpc)
* CIDR (10.0.0.0/16)
* Availability zones (us-west-2a, us-west-2b, us-west-2c)
* Private and public subnet definitions
* Enable NAT gateway with single gateway configuration
* Tags for the VPC (including a Kubernetes cluster association)

## Prompt 4 (EKS Cluster Module):

Building upon the previous steps:

Introduce another pre-built Terraform module (terraform-aws-modules/eks/aws) for creating the EKS cluster.
Define the module source, version (20.24.0), and configuration options:
* Cluster name (my-eks-cluster)
* Desired Kubernetes version (1.31)
* VPC ID (reference output from the VPC module)
* Private subnet IDs (reference output from the VPC module)
* Define an EKS managed node group named general with:
* Desired, minimum, and maximum node count
* Instance types (e.g., t3.medium)
* Capacity type (ON_DEMAND)
* Tags for the EKS cluster (environment and application)

## Prompt 5 (Output Kubectl Configuration):

Building upon the previous steps:

Create an output variable named kubectl_config.  
Set the value of this output to the kubeconfig data retrieved from the EKS module (presumably containing the kubectl configuration for the cluster).  
Mark the output as sensitive due to security considerations.  

## Prompt 6 (Creating a Fargate Profile):

Building upon the previous steps:

Add a Fargate profile to enable running pods on Fargate:

Create an aws_eks_fargate_profile resource.  
Specify the cluster name (referencing the EKS module output).  
Define selectors to determine which namespaces and labels should be deployed on Fargate.  
Create a selector that matches pods in the default namespace.  
Ensure the Fargate profile is associated with the defined subnets.  

## Prompt 7 (Create Ingress Contoller):

Building upon the previous steps:

Deploy the Nginx Ingress Controller for LoadBalancer using Helm:

Utilize the kubernetes_helm_release resource to install the ingress-nginx chart from the https://kubernetes.github.io/ingress-nginx repository.  
Specify a release name (ingress-nginx).  
Configure the Helm chart values as needed.   
Ensure the Helm release depends on the EKS cluster creation (module.eks).  

## Prompt 8 (Securing API Endpoints): 

Building upon the previous steps:

Secure access to the applications running within the EKS cluster using an Ingress controller and TLS.

Using the previously defined Ingress Contoller secure the API enpoint. 
Configure TLS termination at the Ingress controller:
* Obtain a TLS certificate (e.g., from AWS Certificate Manager (ACM)).
* Reference the certificate ARN in the Ingress TLS configuration.
* Define hostnames and paths for your API endpoints and map them to the corresponding Kubernetes services running in your cluster.


[List of Scenarios](../scenarios.md)
