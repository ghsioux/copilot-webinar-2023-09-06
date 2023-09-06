# my-terraform-project

This project contains Terraform code for setting up infrastructure. It uses a dedicated provider file and does not use state files or .vscode.

## Usage

1. Clone the repository.
2. Navigate to the project directory.
3. Run `terraform init` to initialize the project.
4. Run `terraform workspace new copilot-webinar-2023-09-06` to create a new workspace.
5. Run `terraform apply` to apply the changes.

## Files

### `provider.tf`

This file contains the configuration for the Terraform provider.

### `main.tf`

This file contains the main Terraform code for setting up infrastructure.

### `variables.tf`

This file contains the input variables for the Terraform code.

### `outputs.tf`

This file contains the output variables for the Terraform code.

### `README.md`

This file contains information about the project and how to use it.