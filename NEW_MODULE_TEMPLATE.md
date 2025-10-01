# New Terraform Module Template Files

## 1. .github/workflows/governance.yml

```
name: Terraform Module Governance

on:
  workflow_dispatch:
  push:
    paths:
      - '**/*.tf'
      - '**/*.tfvars'
      - '!tf-management/**'
  pull_request:
    paths:
      - '**/*.tf'
      - '**/*.tfvars'
      - '!tf-management/**'

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  terraform-governance:
    runs-on: ubuntu-latest
    name: 🚀 Terraform Module Governance

    steps:
      - name: 📥 Checkout repository
        uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          persist-credentials: true

      - name: 💾 Cache Terraform providers
        uses: grinntec-terraform-modules-azure/.github/.github/actions/cache-terraform-providers@main

      - name: 🔧 Format Terraform files
        uses: grinntec-terraform-modules-azure/.github/.github/actions/terraform-fmt@main

      - name: ✅ Validate Terraform configuration
        uses: grinntec-terraform-modules-azure/.github/.github/actions/terraform-validate@main

      - name: 🔍 Run TF-Lint
        uses: grinntec-terraform-modules-azure/.github/.github/actions/tf-lint@main

      - name: 🛡️ Security scan with Checkov
        uses: grinntec-terraform-modules-azure/.github/.github/actions/terraform-security-scan@main

      - name: 📚 Generate documentation
        uses: grinntec-terraform-modules-azure/.github/.github/actions/terraform-docs@main
        with:
          config_file: './tf-management/tf-docs/tf-docs.yaml'

      - name: 📤 Commit and push changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          
          git add README.md || true
          git add tf-management/tf-lint/results/ || true
          git add tf-management/checkov/module/ || true
          git add "*.tf" || true
          
          if [[ $(git status --porcelain) ]]; then
            git commit -m "docs: update terraform documentation and formatting [skip ci]"
            git push
            echo "✅ Changes committed and pushed"
          else
            echo "✅ No changes to commit"
          fi
        shell: bash
```

## 2. .tflint.hcl

```
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}
```


## 3. .gitignore

```
# Python
__pycache__/
*.py[cod]
*$py.class

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDE
.vscode/
*.code-workspace
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Terraform
*.tfstate
*.tfstate.*
*.tfstate.backup
*.tfstate.lock.info
.terraform/
.terraform.d/
*.tfplan
*.tfplan.*
crash.log
crash.*.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc

# Terraform provider cache and binaries
terraform-provider-*
*.zip
*.tar.gz
*.sha256
checksums.txt

# Tool downloads and binaries
tflint_*
terraform-docs-*
checkov-*

# CI/CD artifacts and logs
tflint-summary.md
workflow_log.txt

# License files from downloads
LICENSE.txt
```

## 4. tf-management/tf-docs/tf-docs.yaml

```
formatter: "markdown table"

header-from: main.tf
footer-from: ""

recursive:
  enabled: false

sections:
  hide: []
  show: []

content: |-
  # {{ .Header }}

  {{ .Description }}

  ## Usage

  ```hcl
  {{ include "example/main.tf" }}
  ```

  ## Examples

  - [**Basic Usage**](./example/) - Simple implementation example

  {{ .Requirements }}

  {{ .Providers }}

  {{ .Modules }}

  {{ .Resources }}

  {{ .Inputs }}

  {{ .Outputs }}

  ## Contributing

  Please read our [organization contributing guidelines](https://github.com/grinntec-terraform-modules-azure/.github#contributing) for details on our code of conduct and the process for submitting pull requests.

  ## License

  This module is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

  {{ .Footer }}

output:
  file: "README.md"
  mode: replace
  template: |-
    <!-- This file is auto-generated. Please do not edit manually. -->
    <!-- Run terraform-docs to regenerate this file. -->
    {{ .Content }}

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

## 5. providers.tf (or versions.tf)

```
# =============================================================================
# TERRAFORM PROVIDERS CONFIGURATION
# =============================================================================
#
# This file defines the required Terraform and provider versions for this
# Azure Terraform module. It ensures consistent behavior across all 
# environments and team members.
#
# PURPOSE:
# --------
# - Specifies minimum Terraform version required for compatibility
# - Defines Azure Resource Manager (AzureRM) provider for Azure resources
# - Includes additional providers as needed for module functionality
# - Establishes version constraints for reproducible deployments
#
# HOW IT WORKS:
# -------------
# 1. Terraform Version: Ensures compatibility with modern Terraform features
# 2. AzureRM Provider: Manages Azure resources and services
# 3. Additional Providers: Include other providers as needed (random, time, etc.)
# 4. Version Constraints: Uses semantic versioning to prevent breaking changes
#
# VERSION STRATEGY:
# -----------------
# - Terraform: ">= 1.5" - Minimum version for stability and features
# - AzureRM: "~> 3.0" - Major version 3.x with latest minor/patch updates
# - Other Providers: Pinned or constrained versions as appropriate
#
# NOTES:
# ------
# - This file is automatically validated by our CI/CD pipeline
# - Version updates should be tested in development environments first
# - The .terraform.lock.hcl file pins exact versions after 'terraform init'
# - Update provider versions carefully to avoid breaking changes
#
# =============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    # Add additional providers as needed for your module
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.0"
    # }
  }
}
```

## 6. variables.tf Template

```
variable "name" {
  description = "The name of the resource"
  type        = string
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 50
    error_message = "Name must be between 1 and 50 characters."
  }
}

variable "location" {
  description = "The Azure region where the resource should be created"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
```

## 7. outputs.tf Template

```
output "id" {
  description = "The ID of the created resource"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "The name of the created resource"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "The location of the created resource"
  value       = azurerm_resource_group.this.location
}
```

## 8. example/main.tf Template

```hcl
terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "example" {
  source = "../"

  name     = var.name
  location = var.location
  tags     = var.tags
}
```

## 9. example/variables.tf Template

```hcl
variable "name" {
  description = "The name of the resource"
  type        = string
  default     = "example"
}

variable "location" {
  description = "The Azure region where the resource should be created"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default = {
    Environment = "development"
    Purpose     = "example"
  }
}
```

## 10. example/terraform.tfvars Template

```hcl
name     = "my-example-resource"
location = "East US"

tags = {
  Environment = "development"
  Purpose     = "testing"
  Owner       = "platform-team"
}
```
