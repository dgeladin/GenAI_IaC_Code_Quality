


# Workstation Setup

Install WSL from the command line. Open a PowerShell prompt as an Administrator and run:

``` 
wsl --install 
wsl --install -d Ubuntu-24.04
```

Run WSL command window and update the image:

``` 
sudo apt update 
sudo apt full-upgrade -y
sudo apt-get install build-essential curl file git unzip jq
/bin/bash -c "$(curl -fsSLk https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Execute the following commands to add Homebrew to your PATH

```
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
brew analytics off
```

Install Python3
```
brew install python3
```

Install rust as a dependancy for checkov
```
brew install rust
```
<br>
     
# Tool Installation

## asdf - [Docs](https://asdf-vm.com/guide/getting-started.html)

asdf is a version manager (not to be confused with brew which is a package manager). A version manager allows you to install multiple versions of the same program and easily switch between versions. We will use asdf to install most of the required tooling for terraform/tofu development. Run the following commands to install the asdf version manager.

```
brew install asdf
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bashrc
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc
```

asdf tool versions are defined in the .tool-versions configuration file.
This file is in the /scripts subdirectory to define the tool versions while running the static code analysis tools in this project. File located [here](./.tool-versions)

## opentofu - [Docs](https://opentofu.org/docs/)

Install OpenTofu using asdf.
```
asdf plugin add opentofu
asdf install opentofu 1.7.1
asdf global opentofu 1.7.1
```

## tflint - [Docs](https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md)
TFLint is a terraform linting tool for checking code quality and compliance with plugins for major cloud providers. While the tofu validate command will check for valid syntax, it is not capable of validating cloud-specific configurations such as EC2 instance types (i.e. is t8.xsmall a valid instance type?).

```
asdf plugin add tflint
asdf install tflint 0.51.1
asdf global tflint 0.51.1
```

## tfsec - [Docs](https://aquasecurity.github.io/tfsec/v1.20.0/guides/installation/)
tfsec is an open-source static code analysis tool for Terraform configurations that helps identify potential security issues and best practices violations, allowing Terraform developers and DevOps teams to improve the security and quality of their infrastructure-as-code (IaC) by scanning for vulnerabilities, checking against a set of best practices, and providing customizable rules and integrations with various development workflows and cloud security platforms, while generating detailed reports to guide remediation efforts.

```
asdf plugin add tfsec
asdf install tfsec 1.28.11
asdf global tfsec 1.28.11
```

## Checkov - [Docs](https://www.checkov.io/1.Welcome/Quick%20Start.html)
Checkov is an open-source static code analysis tool that scans infrastructure-as-code (IaC) configurations, such as Terraform, CloudFormation, Kubernetes, and more, to detect security and compliance issues early in the development process. It checks for misconfigurations, compliance violations, and best practices, providing detailed reports with recommendations to help developers and DevOps teams build secure and compliant cloud infrastructure, while supporting integration with various CI/CD pipelines, cloud security platforms, and code editors to seamlessly incorporate security into the development workflow.

```
asdf plugin add checkov
asdf install checkov 3.2.381
asdf global checkov 3.2.381
```