# Grinntec Terraform Modules for Azure

This repository contains centralized GitHub Actions workflows and composite actions for Terraform modules in the `grinntec-terraform-modules-azure` organization.

## 🚀 **Features**

### **Centralized Actions**
- **🔧 terraform-fmt**: Automatic Terraform formatting with auto-commit
- **✅ terraform-validate**: Terraform configuration validation
- **🔍 tf-lint**: TFLint with Azure-specific rules and auto-fix
- **🛡️ terraform-security-scan**: Checkov security scanning with comprehensive caching
- **📚 terraform-docs**: Automatic README generation with terraform-docs
- **💾 cache-terraform-providers**: Optimized Terraform provider caching

### **Reusable Workflows**
- **📋 terraform-module-governance**: Complete CI/CD pipeline for Terraform modules

## 📁 **Structure**

```
.github/
├── actions/                                    # Centralized composite actions
│   ├── cache-terraform-providers/
│   ├── terraform-fmt/
│   ├── terraform-validate/
│   ├── tf-lint/
│   ├── terraform-security-scan/
│   └── terraform-docs/
├── workflows/                                  # Reusable workflows
│   └── terraform-module-governance.yml
└── workflow-templates/                         # Organization workflow templates
    ├── terraform-module.yml
    └── terraform-module.properties.json
```

## 🎯 **Usage**

### **For New Repositories**

1. Create a new Terraform module repository
2. Add this workflow file: `.github/workflows/governance.yml`

```yaml
name: Terraform Module Governance

on:
  workflow_dispatch:
  push:
    paths:
      - '**/*.tf'
      - '**/*.tfvars'
  pull_request:
    paths:
      - '**/*.tf'
      - '**/*.tfvars'

jobs:
  terraform-governance:
    uses: grinntec-terraform-modules-azure/.github/.github/workflows/terraform-module-governance.yml@main
    with:
      terraform_version: 'latest'
      enable_security_scan: true
      enable_documentation: true
      auto_commit: true
```

### **For Existing Repositories**

Replace local action references with centralized ones:

```yaml
# Before
- uses: ./.github/actions/terraform-fmt

# After  
- uses: grinntec-terraform-modules-azure/.github/.github/actions/terraform-fmt@main
```

## ⚙️ **Configuration**

### **Required Files in Each Module Repository**

1. **`.tflint.hcl`** - TFLint configuration
2. **`tf-management/tf-docs/tf-docs.yaml`** - terraform-docs configuration
3. **`.terraform.lock.hcl`** - Terraform provider lock file

### **Optional Configuration**

The reusable workflow supports these inputs:

| Input | Description | Default |
|-------|-------------|---------|
| `terraform_version` | Terraform version to use | `latest` |
| `enable_security_scan` | Enable Checkov security scanning | `true` |
| `enable_documentation` | Enable terraform-docs generation | `true` |
| `auto_commit` | Auto-commit documentation changes | `true` |
| `tf_docs_config` | Path to terraform-docs config | `./tf-management/tf-docs/tf-docs.yaml` |

## 🏆 **Benefits**

✅ **Single Source of Truth**: All actions centralized in one repository  
✅ **Easy Updates**: Change once, applies to all repositories  
✅ **Consistent Standards**: All modules follow identical governance  
✅ **Version Control**: Tag releases for stable action versions  
✅ **Reduced Maintenance**: No duplicate code across repositories  
✅ **Organization Templates**: New repos get workflows automatically  

## 🔧 **Maintenance**

### **Updating Actions**

1. Update actions in this repository
2. Tag a new release for stability
3. Update references in module repositories

### **Versioning Strategy**

- `@main` - Latest development version
- `@v1` - Stable major version
- `@v1.2.3` - Specific release version

## 📊 **Pipeline Overview**

The complete governance pipeline includes:

1. **Format** → Auto-format Terraform files
2. **Validate** → Verify Terraform syntax and configuration  
3. **Lint** → TFLint with Azure-specific rules
4. **Security** → Checkov security scanning
5. **Documentation** → Generate README with terraform-docs
6. **Commit** → Auto-commit changes back to repository

## 🤝 **Contributing**

1. Make changes to actions in this repository
2. Test with a sample Terraform module
3. Create a pull request with changes
4. Tag releases for stable versions

---

**Maintained by**: Grinntec Infrastructure Team  
**Organization**: [grinntec-terraform-modules-azure](https://github.com/grinntec-terraform-modules-azure)
