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

### **Step 2: Use Template Repository (Recommended)**

**Option A: GitHub Template (Easiest)**
1. **Go to Template Repository**: https://github.com/grinntec-terraform-modules-azure/NEW_MODULE_REPO
2. **Click "Use this template"** → "Create a new repository"
3. **Name**: `terraform-azurerm-{service}`
4. **Clone your new repository**:
   ```bash
   git clone https://github.com/grinntec-terraform-modules-azure/terraform-azurerm-{service}.git
   cd terraform-azurerm-{service}
   ```

**Option B: Manual Clone and Setup**
```bash
# Clone the template repository
git clone https://github.com/grinntec-terraform-modules-azure/NEW_MODULE_REPO.git terraform-azurerm-{service}
cd terraform-azurerm-{service}

# Update remote origin
git remote set-url origin https://github.com/grinntec-terraform-modules-azure/terraform-azurerm-{service}.git

# Create initial commit
git add .
git commit -m "feat: initial module from template"
git push -u origin main
```

### **Step 3: Customize for Your Service (Template Already Applied)**

Since you used the template repository, all essential files are already in place! Now just customize:

1. **Update `main.tf`** with your Azure resource logic
2. **Customize `variables.tf`** for your service requirements  
3. **Define `outputs.tf`** for your service outputs
4. **Update example files** with realistic usage
5. **Test the example** to ensure it works

**Files already provided by template:**
- ✅ **`.github/workflows/governance.yml`** - Centralized workflow
- ✅ **`.tflint.hcl`** - TFLint configuration  
- ✅ **`.gitignore`** - Enhanced with tool exclusions
- ✅ **`tf-management/tf-docs/tf-docs.yaml`** - Documentation config
- ✅ **`versions.tf`** - Comprehensive provider documentation
- ✅ **`variables.tf`** - Input variables template
- ✅ **`outputs.tf`** - Output values template
- ✅ **`example/`** - Complete example implementation

### **Step 4: Initialize and Test**

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

### **Step 5: Commit and Push**

```bash
# Add all files
git add .

# Commit initial structure
git commit -m "feat: customize module for {service}

- Implement main.tf for {service} resource
- Configure variables and outputs for service
- Update example with realistic usage
- Ready for testing and deployment"

# Push to GitHub
git push origin main
```

### **Step 6: Verify Workflow**

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