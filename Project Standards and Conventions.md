Project Standards and Conventions
---------------------------------

1. General Principles
Infrastructure as Code (IaC): All infrastructure must be defined and managed using Terraform.
Version Control: All Terraform code, scripts, and documentation must be stored in Git.
Documentation: Document all resources, variables, and design decisions in a README.md file in each directory.

2. Directory Structure
Organize Terraform code into separate directories for each project or environment:

3. Use consistent file names:
main.tf: Main Terraform configuration.
variables.tf: Variable definitions.
terraform.tfvars: Variable values.
outputs.tf: Output definitions (if needed).

3. Naming Conventions
3.1. Resource Names
Use lowercase letters and hyphens (-) for resource names to ensure compatibility with Azure naming rules.
Include the project or application name as a prefix (e.g., wireapps-rg for Assignment 1, assignment2-rg for Assignment 2).
Append the resource type as a suffix (e.g., assignment2-vm for a virtual machine, assignment2-kv for a Key Vault).
        Examples:
              Resource Group: assignment2-rg
              Virtual Machine: assignment2-vm
              Key Vault: assignment2-kv
              Storage Account: tfstateindunil
3.2. Variable Names
Use snake_case for Terraform variable names (e.g., resource_group_name, admin_username).
Be descriptive and specific (e.g., postgres_admin_username instead of username).
        Examples:
                resource_group_name
                vm_name
                ssh_public_key
3.3. Terraform Resource and Data Source Names
Use the format <resource_type>_<descriptive_name> for resource and data source names in Terraform code.
          Examples:
                azurerm_resource_group.main
                azurerm_linux_virtual_machine.main
                data.azurerm_client_config.current

4. Variable Management
4.1. Defining Variables
Define all variables in variables.tf with:
description: A clear explanation of the variable’s purpose.
type: Specify the type (e.g., string, list(string)).
default: Provide a default value only for non-sensitive variables (e.g., location = "East US").

4.2. Sensitive Variables
Never hardcode sensitive data (e.g., passwords, API keys) in Terraform files.
Use Azure Key Vault to store sensitive data:
Store secrets like database credentials, or API keys in Key Vault.
Retrieve secrets in main.tf using azurerm_key_vault_secret resources.

4.3. Variable Files
Use terraform.tfvars for non-sensitive variable values (e.g., location, vm_name).
Exclude terraform.tfvars from Git by adding it to .gitignore (But here I have added it for evaluating purpose)

5. Resource Management
5.1. Resource Grouping
Group related resources in the same Terraform directory (e.g., all VM-related resources in assignment-2).
Use separate resource groups for different purposes:
Application infrastructure: wireapps-rg (Assignment 1), assignment2-rg (Assignment 2).
Terraform state storage: tfstate-rg (remote backend).

5.2. Tagging
Add tags to all resources for better organization and cost tracking:
project: The project name (e.g., wireapps).
environment: The environment (e.g., dev, prod).

5.3. Security
Use Azure Key Vault for all secrets (e.g: database credentials).
Configure access policies in Key Vault to limit access to authorized users or service principals.

5.4. Remote Backend
Use a remote backend for Terraform state storage to enable collaboration and state locking.
Store state files in Azure Blob Storage with a unique key for each project:
                                                  Assignment 1: terraform.tfstate
                                                  Assignment 2: assignment2.tfstate

6. CI/CD Pipelines
Use GitHub Actions for automation (e.g: deploy.yml in Assignment 1).
Store all credentials in GitHub Secrets:
AZURE_CREDENTIALS: For Azure authentication.
ARM_ACCESS_KEY: For remote backend access.

7. Documentation and Comments
Add comments in Terraform files to explain complex logic or design decisions.
Maintain a README.md in each directory with setup instructions, prerequisites, and usage examples.

8. Versioning
Pin Terraform provider versions in main.tf
Use Git tags to version releases (e.g., v1.0.0 for Assignment 1 completion)

9. Testing and Validation
Run terraform validate and terraform fmt before committing changes.
Test infrastructure changes in a dev branch before merging to main.
Verify deployments with curl commands or browser tests.
