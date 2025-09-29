# 🚀 New Terraform Module Repository Creation Guide

## Step-by-Step Process

### **Step 1: Create Repository on GitHub**

1. **Go to GitHub Organization**: https://github.com/grinntec-terraform-modules-azure
2. **Click "New"** to create a new repository
3. **Name**: `terraform-azurerm-{service}` (e.g., `terraform-azurerm-virtual_network`)
4. **Description**: "Terraform module for Azure {Service Name}"
5. **Settings**:
   - ✅ Public
   - ✅ Add a README file
   - ✅ Add .gitignore (choose "Terraform")
   - ✅ Choose a license (MIT recommended)

### **Step 2: Clone and Setup Local Environment**

```bash
# Clone the repository
git clone https://github.com/grinntec-terraform-modules-azure/terraform-azurerm-{service}.git
cd terraform-azurerm-{service}

# Create directory structure
mkdir -p .github/workflows
mkdir -p example
mkdir -p tf-management/tf-docs
mkdir -p tf-management/tf-lint/results
mkdir -p tf-management/checkov/module
```

### **Step 3: Copy Template Files**

Copy all the template files from `NEW_MODULE_TEMPLATE.md` into your new repository:

1. **`.github/workflows/governance.yml`** - Centralized workflow
2. **`.tflint.hcl`** - TFLint configuration
3. **`.gitignore`** - Enhanced with tool exclusions
4. **`tf-management/tf-docs/tf-docs.yaml`** - Documentation config
5. **`versions.tf`** - Terraform version constraints
6. **`variables.tf`** - Input variables template
7. **`outputs.tf`** - Output values template
8. **`example/main.tf`** - Example implementation
9. **`example/variables.tf`** - Example variables
10. **`example/terraform.tfvars`** - Example values

### **Step 4: Customize for Your Service**

1. **Update `main.tf`** with your Azure resource logic
2. **Customize `variables.tf`** for your service requirements
3. **Define `outputs.tf`** for your service outputs
4. **Update example files** with realistic usage
5. **Test the example** to ensure it works

### **Step 5: Initialize and Test**

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Test the example
cd example
terraform init
terraform plan
cd ..
```

### **Step 6: Commit and Push**

```bash
# Add all files
git add .

# Commit initial structure
git commit -m "feat: initial module structure

- Add centralized governance workflow
- Configure TFLint and terraform-docs
- Include working example implementation
- Set up proper .gitignore exclusions"

# Push to GitHub
git push origin main
```

### **Step 7: Verify Workflow**

1. **Check GitHub Actions**: Go to repository → Actions tab
2. **Verify workflow runs**: Should trigger automatically
3. **Review generated documentation**: README.md will be updated
4. **Check results files**: tf-management directories will be populated

## 🔧 **Automated Setup Script**

Here's a PowerShell script to automate the process:

```powershell
# new-terraform-module.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$ServiceName
)

$RepoName = "terraform-azurerm-$ServiceName"
$OrgPath = "c:\Users\neilg\Repos\grinntec-terraform-modules-azure"

# Create and navigate to new repository directory
$RepoPath = "$OrgPath\$RepoName"
New-Item -ItemType Directory -Path $RepoPath -Force
Set-Location $RepoPath

# Initialize git repository
git init
git remote add origin "https://github.com/grinntec-terraform-modules-azure/$RepoName.git"

# Create directory structure
$Directories = @(
    ".github\workflows",
    "example", 
    "tf-management\tf-docs",
    "tf-management\tf-lint\results",
    "tf-management\checkov\module"
)

foreach ($Dir in $Directories) {
    New-Item -ItemType Directory -Path $Dir -Force
}

# Copy template files from central repository
$TemplateSource = "$OrgPath\.github\NEW_MODULE_TEMPLATE.md"
Write-Host "Copy template files from $TemplateSource and customize for $ServiceName"
Write-Host "Then run: git add . && git commit -m 'feat: initial module structure' && git push -u origin main"
```

## 📋 **Checklist for New Modules**

### **Before First Commit**
- [ ] Repository created with correct naming convention
- [ ] All template files copied and customized
- [ ] `main.tf` implements the Azure resource
- [ ] Variables have proper descriptions and validation
- [ ] Outputs are documented and useful
- [ ] Example implementation works
- [ ] `.terraform.lock.hcl` generated (after `terraform init`)

### **After First Push**
- [ ] GitHub Actions workflow runs successfully
- [ ] README.md is auto-generated with documentation
- [ ] TF-Lint results show no critical issues
- [ ] Checkov security scan passes
- [ ] All files are properly formatted

### **Before Publishing**
- [ ] Example tested and working
- [ ] Documentation is comprehensive
- [ ] Security scan shows no critical findings
- [ ] Code review completed
- [ ] Version tagged (e.g., `v1.0.0`)

## 🎯 **Quality Gates**

Every new module must pass:

1. **✅ Terraform Validation** - Syntax and configuration correct
2. **✅ TFLint Analysis** - Best practices followed
3. **✅ Security Scan** - No critical security issues
4. **✅ Documentation** - Complete and auto-generated
5. **✅ Working Example** - Tested implementation
6. **✅ Code Review** - Peer reviewed and approved

## 🔄 **Continuous Improvement**

After initial creation:
- **Monitor workflow runs** for any failures
- **Update examples** based on real usage
- **Enhance documentation** based on feedback
- **Add more examples** for complex scenarios
- **Version releases** for breaking changes