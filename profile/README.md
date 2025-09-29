# Grinntec Terraform Modules for Azure 🚀

Welcome to the **Grinntec Terraform Modules for Azure** organization! This repository contains a comprehensive collection of enterprise-grade Terraform modules designed specifically for Azure cloud infrastructure.

## 🌟 **Organization Overview**

This organization provides:
- **🏗️ Production-ready Terraform modules** for Azure services
- **🔄 Centralized CI/CD infrastructure** with automated governance
- **📚 Comprehensive documentation** and examples
- **🛡️ Security-first approach** with automated scanning
- **⚡ Consistent quality standards** across all modules

## 📦 **Available Modules**

| Module | Description | Status | Version |
|--------|-------------|--------|---------|
| [`terraform-azurerm-resource_group`](https://github.com/grinntec-terraform-modules-azure/terraform-azurerm-resource_group) | Azure Resource Group with standardized naming and tagging | ✅ Active | Latest |

*More modules coming soon!*

## 🎯 **Quick Start**

### **Using a Module**

```hcl
module "resource_group" {
  source = "github.com/grinntec-terraform-modules-azure/terraform-azurerm-resource_group"
  
  name     = "my-application"
  location = "East US"
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}
```

### **Module Development**

All modules follow our standardized structure and use centralized CI/CD:

```
terraform-module/
├── main.tf                    # Main module logic
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Terraform version constraints
├── README.md                  # Module documentation
├── example/                   # Usage examples
│   ├── main.tf
│   └── terraform.tfvars
└── tf-management/             # Governance and quality
    ├── tf-docs/
    ├── tf-lint/
    └── checkov/
```

## 🔧 **Centralized Infrastructure**

Our organization uses a **centralized GitHub Actions infrastructure** that provides:

### **🚀 Automated Governance Pipeline**

Every module automatically gets:

1. **🔧 Terraform Formatting** - Auto-format with `terraform fmt`
2. **✅ Configuration Validation** - Verify syntax with `terraform validate`  
3. **🔍 Code Linting** - TFLint with Azure-specific rules
4. **🛡️ Security Scanning** - Checkov security analysis
5. **📚 Documentation Generation** - Auto-update README with terraform-docs
6. **📤 Auto-commit** - Automatically commit improvements

### **⚙️ Centralized Actions**

All workflows use actions from our central [`.github`](https://github.com/grinntec-terraform-modules-azure/.github) repository:

- **`cache-terraform-providers`** - Optimized provider caching
- **`terraform-fmt`** - Consistent formatting
- **`terraform-validate`** - Configuration validation
- **`tf-lint`** - Advanced linting with Azure rules
- **`terraform-security-scan`** - Comprehensive security analysis
- **`terraform-docs`** - Automated documentation

## 📋 **Module Standards**

### **🏷️ Naming Convention**

```
terraform-azurerm-{service}
```

Examples:
- `terraform-azurerm-resource_group`
- `terraform-azurerm-virtual_network`
- `terraform-azurerm-storage_account`

### **📁 Required Files**

Every module must include:

- **`main.tf`** - Core module logic
- **`variables.tf`** - All input variables with descriptions
- **`outputs.tf`** - All outputs with descriptions  
- **`versions.tf`** - Terraform and provider version constraints
- **`README.md`** - Comprehensive documentation (auto-generated)
- **`example/`** - Working usage examples
- **`.tflint.hcl`** - TFLint configuration
- **`tf-management/tf-docs/tf-docs.yaml`** - Documentation config

### **🔄 Workflow Integration**

Add this workflow to any new module:

```yaml
# .github/workflows/governance.yml
name: Terraform Module Governance

on:
  workflow_dispatch:
  push:
    paths: ['**/*.tf', '**/*.tfvars']
  pull_request:
    paths: ['**/*.tf', '**/*.tfvars']

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

## 🛡️ **Security & Quality**

### **Security Scanning**

Every module is automatically scanned with:
- **Checkov** - Infrastructure security analysis
- **TFLint** - Terraform best practices
- **Azure-specific rules** - Cloud provider security policies

### **Quality Standards**

All modules maintain:
- ✅ **100% documentation coverage** - All variables and outputs documented
- ✅ **Working examples** - Tested usage scenarios
- ✅ **Security compliance** - No critical security issues
- ✅ **Terraform best practices** - Following official guidelines
- ✅ **Consistent formatting** - Auto-formatted code

## 📚 **Documentation**

### **Module Documentation**

Each module includes:
- **Usage examples** with real-world scenarios
- **Variable documentation** with types and descriptions
- **Output documentation** with use cases
- **Security considerations** and best practices
- **Compliance information** where applicable

### **Generated Documentation**

Documentation is automatically generated and updated using:
- **terraform-docs** - Variable and output documentation
- **Quality reports** - Linting and validation results
- **Security reports** - Checkov scan results

## 🤝 **Contributing**

### **Creating a New Module**

1. **Create repository** following naming convention
2. **Use module template** with required structure
3. **Add governance workflow** from template above
4. **Write comprehensive tests** in `example/` directory
5. **Submit pull request** for review

### **Module Guidelines**

- **Follow Terraform best practices** - Use official style guide
- **Provide working examples** - Include `terraform.tfvars`
- **Document everything** - Variables, outputs, and usage
- **Test thoroughly** - Ensure examples work
- **Security first** - No hardcoded secrets or insecure defaults

### **Code Review Process**

1. **Automated checks** - All governance tools must pass
2. **Peer review** - At least one team member approval
3. **Documentation review** - Ensure completeness
4. **Security review** - No critical findings
5. **Example testing** - Verify examples work

## 🔗 **Related Resources**

### **Infrastructure**
- [**Central Actions Repository**](https://github.com/grinntec-terraform-modules-azure/.github) - Centralized CI/CD infrastructure
- [**Workflow Templates**](https://github.com/grinntec-terraform-modules-azure/.github/tree/main/workflow-templates) - Organization-wide templates

### **Tools & Standards**
- [**Terraform**](https://terraform.io) - Infrastructure as Code
- [**TFLint**](https://github.com/terraform-linters/tflint) - Terraform linter
- [**Checkov**](https://checkov.io) - Infrastructure security scanner
- [**terraform-docs**](https://terraform-docs.io) - Documentation generator

### **Azure Resources**
- [**Azure Provider**](https://registry.terraform.io/providers/hashicorp/azurerm/latest) - Official Terraform Azure provider
- [**Azure Documentation**](https://docs.microsoft.com/azure) - Microsoft Azure docs
- [**Azure Architecture Center**](https://docs.microsoft.com/azure/architecture/) - Best practices and patterns

## 🏆 **Benefits**

### **For Developers**
- ✅ **Consistent experience** across all modules
- ✅ **Automated quality assurance** - No manual checks needed
- ✅ **Pre-built workflows** - Copy-paste ready CI/CD
- ✅ **Security by default** - Automated vulnerability scanning
- ✅ **Documentation automation** - Always up-to-date docs

### **For Platform Teams**
- ✅ **Centralized maintenance** - Update once, apply everywhere
- ✅ **Consistent standards** - Organization-wide compliance
- ✅ **Security oversight** - Centralized security scanning
- ✅ **Quality metrics** - Organization-wide visibility
- ✅ **Reduced maintenance** - Single source of truth

### **For Organizations**
- ✅ **Enterprise-grade modules** - Production-ready infrastructure
- ✅ **Security compliance** - Automated security standards
- ✅ **Cost optimization** - Efficient resource management
- ✅ **Rapid deployment** - Pre-tested, documented modules
- ✅ **Governance at scale** - Consistent across all teams

## 📊 **Statistics**

- **🔧 Actions**: 6 centralized composite actions
- **📋 Templates**: Organization-wide workflow templates  
- **🛡️ Security**: 100% automated security scanning
- **📚 Documentation**: Auto-generated and always current
- **⚡ Efficiency**: 67KB saved per repository cleanup

## 📞 **Support**

### **Getting Help**
- **📖 Documentation** - Check module READMEs and examples
- **🐛 Issues** - Open issues in specific module repositories
- **💬 Discussions** - Use GitHub Discussions for questions
- **🔧 Central Actions** - Issues with CI/CD in `.github` repository

### **Contact**
- **Team**: Grinntec Infrastructure Team
- **Organization**: [grinntec-terraform-modules-azure](https://github.com/grinntec-terraform-modules-azure)

---

## 🎯 **Mission Statement**

> *To provide enterprise-grade, secure, and well-documented Terraform modules for Azure that enable teams to deploy infrastructure quickly, consistently, and safely at scale.*

**Built with ❤️ by the Grinntec Infrastructure Team**