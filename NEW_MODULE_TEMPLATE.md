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

## 6. data.tf Template

```
# =============================================================================
# DATA SOURCES CONFIGURATION
# =============================================================================
#
# This file defines data sources that retrieve information about existing 
# Azure resources. Data sources are read-only and allow modules to reference
# resources that already exist in your Azure environment.
#
# PURPOSE:
# --------
# - Retrieve information about existing Azure resources
# - Access current Azure client configuration and permissions
# - Reference existing infrastructure components (VNets, subnets, RGs)
# - Gather metadata and configuration from existing resources
# - Enable dynamic configuration based on current environment
#
# HOW IT WORKS:
# -------------
# 1. Data sources query Azure APIs to retrieve resource information
# 2. Information is made available to other resources in the module
# 3. Enables modules to integrate with existing infrastructure
# 4. Provides dynamic values that can't be hardcoded
#
# COMMON DATA SOURCES:
# -------------------
# - azurerm_client_config: Current Azure client and subscription info
# - azurerm_resource_group: Existing resource group details
# - azurerm_virtual_network: VNet information for networking
# - azurerm_subnet: Subnet details for resource placement
# - azurerm_subscription: Current subscription information
#
# BEST PRACTICES:
# ---------------
# - Use descriptive names that indicate what data is being retrieved
# - Add comments explaining why specific data sources are needed
# - Group related data sources together logically
# - Validate that referenced resources exist in target environment
# - Consider using locals.tf to process and transform data source outputs
#
# EXAMPLES:
# ---------
# data "azurerm_client_config" "current" {}
# 
# data "azurerm_resource_group" "existing" {
#   name = var.existing_resource_group_name
# }
#
# data "azurerm_virtual_network" "network" {
#   name                = var.vnet_name
#   resource_group_name = var.network_resource_group_name
# }
#
# =============================================================================

# Add your data sources here
# Example:
# data "azurerm_client_config" "current" {}

# Uncommon but useful data sources:
# data "azurerm_subscription" "current" {}
# data "azurerm_resource_group" "existing" {
#   name = var.existing_resource_group_name
# }
```

## 7. variables.tf Template

```
# =============================================================================
# INPUT VARIABLES CONFIGURATION
# =============================================================================
#
# This file defines all input variables for the Terraform module. Variables
# allow users to customize module behavior and provide required values for
# resource creation without modifying the module's core logic.
#
# PURPOSE:
# --------
# - Define customizable parameters for module users
# - Establish type constraints and validation rules
# - Provide default values where appropriate
# - Document expected inputs and their purposes
# - Enable reusable and flexible module design
#
# VARIABLE STRUCTURE:
# ------------------
# variable "variable_name" {
#   description = "Clear description of the variable's purpose"
#   type        = variable_type (string, number, bool, list, map, object)
#   default     = default_value (optional)
#   sensitive   = true/false (optional, for sensitive data)
#   nullable    = true/false (optional, allows null values)
#   
#   validation {
#     condition     = validation_expression
#     error_message = "Human-readable error message"
#   }
# }
#
# NAMING CONVENTIONS:
# ------------------
# - Use snake_case for variable names
# - Use descriptive names that clearly indicate purpose
# - Prefix related variables with common identifier
# - Avoid abbreviations unless widely understood
#
# TYPE CONSTRAINTS:
# ----------------
# - string: Text values
# - number: Numeric values (int or float)
# - bool: Boolean true/false values
# - list(type): Ordered collection of values
# - map(type): Key-value pairs
# - set(type): Unordered collection of unique values
# - object({...}): Structured data with defined attributes
# - any: Accept any type (use sparingly)
#
# VALIDATION BEST PRACTICES:
# --------------------------
# - Validate string lengths and patterns
# - Check numeric ranges and constraints
# - Ensure required object attributes are present
# - Validate against Azure naming conventions
# - Provide clear, actionable error messages
#
# COMMON PATTERNS:
# ---------------
# - Required variables: No default value, must be provided
# - Optional variables: Include sensible default values
# - Feature toggles: Boolean variables to enable/disable features
# - Configuration objects: Complex structured inputs
# - Resource identifiers: Names, IDs, and references
#
# =============================================================================

# Required Variables
# ==================

variable "name" {
  description = "The name of the resource. Must comply with Azure naming conventions."
  type        = string
  
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 50
    error_message = "Name must be between 1 and 50 characters."
  }
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "Name can only contain letters, numbers, hyphens, and underscores."
  }
}

variable "location" {
  description = "The Azure region where the resource should be created. See: https://azure.microsoft.com/en-us/global-infrastructure/locations/"
  type        = string
  
  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resource"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

# Optional Variables
# ==================

variable "tags" {
  description = "A mapping of tags to assign to the resource. Tags are key-value pairs used for resource organization and cost tracking."
  type        = map(string)
  default     = {}
  
  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags allowed per resource."
  }
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod). Used for resource naming and tagging."
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

# Feature Toggle Variables
# ========================

variable "enable_monitoring" {
  description = "Whether to enable monitoring and diagnostic settings for the resource"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Whether to enable backup configuration for the resource"
  type        = bool
  default     = false
}

# Complex Configuration Variables
# ===============================

variable "network_config" {
  description = "Network configuration settings for the resource"
  type = object({
    subnet_id                     = string
    private_endpoint_enabled      = optional(bool, false)
    public_access_enabled         = optional(bool, true)
    allowed_ip_ranges            = optional(list(string), [])
  })
  default = null
  nullable = true
}

variable "security_config" {
  description = "Security configuration settings for the resource"
  type = object({
    identity_type                = optional(string, "SystemAssigned")
    key_vault_key_id            = optional(string, null)
    encryption_enabled          = optional(bool, true)
    public_network_access       = optional(string, "Enabled")
  })
  default = {}
}

# Example Sensitive Variable
# ==========================

variable "admin_password" {
  description = "The administrator password for the resource. If not provided, a random password will be generated."
  type        = string
  default     = null
  sensitive   = true
  nullable    = true
  
  validation {
    condition = var.admin_password == null || (
      length(var.admin_password) >= 8 &&
      can(regex("[A-Z]", var.admin_password)) &&
      can(regex("[a-z]", var.admin_password)) &&
      can(regex("[0-9]", var.admin_password))
    )
    error_message = "Password must be at least 8 characters long and contain uppercase, lowercase, and numeric characters."
  }
}
```

## 8. outputs.tf Template

```
# =============================================================================
# OUTPUT VALUES CONFIGURATION
# =============================================================================
#
# This file defines output values that make information about created resources
# available to other Terraform configurations. Outputs are the return values
# of a Terraform module and are essential for module composition.
#
# PURPOSE:
# --------
# - Expose resource attributes to consuming modules/configurations
# - Enable module composition and data sharing between modules
# - Provide information needed for resource discovery and integration
# - Support debugging and operational visibility
# - Allow dependent resources to reference created infrastructure
#
# OUTPUT STRUCTURE:
# ----------------
# output "output_name" {
#   description = "Clear description of what this output provides"
#   value       = resource.resource_name.attribute
#   sensitive   = true/false (optional, for sensitive data)
#   depends_on  = [resource.name] (optional, explicit dependencies)
# }
#
# NAMING CONVENTIONS:
# ------------------
# - Use snake_case for output names
# - Use descriptive names that clearly indicate the data being output
# - Group related outputs with common prefixes
# - Be consistent with input variable naming where applicable
#
# TYPES OF OUTPUTS:
# ----------------
# - Resource IDs: Unique identifiers for created resources
# - Resource Names: Human-readable names of created resources
# - Connection Information: Endpoints, URLs, connection strings
# - Configuration Values: Settings that may be needed elsewhere
# - Metadata: Tags, regions, resource groups, etc.
# - Complex Objects: Full resource configurations for advanced use cases
#
# BEST PRACTICES:
# ---------------
# - Always include meaningful descriptions
# - Output all commonly needed resource attributes
# - Use consistent patterns across similar modules
# - Mark sensitive outputs appropriately
# - Consider the needs of consuming modules
# - Avoid outputting unnecessary internal details
# - Group related outputs logically
#
# SECURITY CONSIDERATIONS:
# -----------------------
# - Mark outputs containing secrets as sensitive = true
# - Be cautious with connection strings and credentials
# - Consider what information should be exposed vs. kept internal
# - Remember that outputs appear in Terraform state files
#
# =============================================================================

# Primary Resource Outputs
# ========================

output "id" {
  description = "The unique identifier of the created resource"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "The name of the created resource"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "The Azure region where the resource was created"
  value       = azurerm_resource_group.this.location
}

# Configuration Outputs
# =====================

output "resource_group_name" {
  description = "The name of the resource group containing the resource"
  value       = azurerm_resource_group.this.name
}

output "tags" {
  description = "The tags applied to the resource"
  value       = azurerm_resource_group.this.tags
}

output "environment" {
  description = "The environment name associated with the resource"
  value       = var.environment
}

# Connection Information
# =====================

output "endpoint" {
  description = "The primary endpoint URL for the resource (if applicable)"
  value       = try(azurerm_resource_group.this.endpoint, null)
}

output "fqdn" {
  description = "The fully qualified domain name of the resource (if applicable)"
  value       = try(azurerm_resource_group.this.fqdn, null)
}

# Security and Access Outputs
# ===========================

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity (if enabled)"
  value       = try(azurerm_resource_group.this.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The tenant ID of the system-assigned managed identity (if enabled)"
  value       = try(azurerm_resource_group.this.identity[0].tenant_id, null)
}

# Sensitive Outputs
# =================

output "connection_string" {
  description = "The connection string for the resource (sensitive)"
  value       = try(azurerm_resource_group.this.primary_connection_string, null)
  sensitive   = true
}

output "access_keys" {
  description = "The access keys for the resource (sensitive)"
  value       = try(azurerm_resource_group.this.primary_access_key, null)
  sensitive   = true
}

# Complex Object Outputs
# ======================

output "network_configuration" {
  description = "Complete network configuration details for the resource"
  value = {
    subnet_id                = try(azurerm_resource_group.this.subnet_id, null)
    private_endpoint_enabled = try(azurerm_resource_group.this.private_endpoint_enabled, false)
    public_access_enabled    = try(azurerm_resource_group.this.public_network_access_enabled, true)
    firewall_rules          = try(azurerm_resource_group.this.network_acls, [])
  }
}

output "security_configuration" {
  description = "Complete security configuration details for the resource"
  value = {
    identity_type        = try(azurerm_resource_group.this.identity[0].type, null)
    encryption_enabled   = try(azurerm_resource_group.this.encryption_enabled, false)
    key_vault_key_id    = try(azurerm_resource_group.this.key_vault_key_id, null)
    threat_protection   = try(azurerm_resource_group.this.threat_protection_enabled, false)
  }
}

# Operational Outputs
# ===================

output "monitoring_configuration" {
  description = "Monitoring and diagnostic configuration for the resource"
  value = {
    log_analytics_workspace_id = try(azurerm_resource_group.this.log_analytics_workspace_id, null)
    diagnostic_settings_enabled = var.enable_monitoring
    metrics_enabled            = try(azurerm_resource_group.this.metrics_enabled, false)
  }
}

# Module Metadata
# ===============

output "module_info" {
  description = "Information about the module and resource configuration"
  value = {
    module_version    = "1.0.0"  # Update this with each module version
    terraform_version = "~> 1.5"
    provider_version  = "~> 3.0"
    created_at       = timestamp()
    resource_type    = "azurerm_resource_group"  # Update based on your resource type
  }
}
```

## 9. example/main.tf Template

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

## 10. example/variables.tf Template

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

## 11. example/terraform.tfvars Template

```hcl
name     = "my-example-resource"
location = "East US"

tags = {
  Environment = "development"
  Purpose     = "testing"
  Owner       = "platform-team"
}
```
