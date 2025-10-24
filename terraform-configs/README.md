# Centralized Terraform-Docs Configurations

This directory contains standardized terraform-docs configuration files used across all Terraform modules in the `grinntec-terraform-modules-azure` organization.

## 📁 Available Configurations

| File | Purpose | Use Case |
|------|---------|----------|
| `tf-docs-standard.yaml` | Full-featured configuration | Production modules with examples, linting, and security scan results |
| `tf-docs-minimal.yaml` | Basic configuration | Simple modules that only need core documentation |

## 🚀 Usage Options

### Option 1: Central Configuration via GitHub Actions

**Modify your workflow** to use central configuration:

```yaml
- name: Terraform Documentation
  uses: grinntec-terraform-modules-azure/.github/.github/actions/terraform-docs@main
  with:
    central_config: 'true'  # Uses tf-docs-standard.yaml
    output_file: README.md
```

### Option 2: Specific Central Configuration

**Reference a specific config file**:

```yaml
- name: Terraform Documentation
  uses: grinntec-terraform-modules-azure/.github/.github/actions/terraform-docs@main
  with:
    config_file: https://raw.githubusercontent.com/grinntec-terraform-modules-azure/.github/main/terraform-configs/tf-docs-minimal.yaml
    output_file: README.md
```

### Option 3: Remove Local Configuration

1. **Delete local tf-docs config** from individual repositories:
   ```bash
   rm -rf ./tf-management/tf-docs/tf-docs.yaml
   ```

2. **Update workflow** to use central config:
   ```yaml
   tf_docs_config: 'https://raw.githubusercontent.com/grinntec-terraform-modules-azure/.github/main/terraform-configs/tf-docs-standard.yaml'
   ```

## 🔄 Migration Strategy

For existing repositories:

1. **Test with one repository first**
2. **Compare output** with current local configuration 
3. **Update workflows** once satisfied
4. **Remove local configurations**
5. **Apply to all repositories**

## 🛠️ Maintenance

- **Centralized updates**: Changes to these files automatically apply to all repositories
- **Version control**: All changes are tracked in the `.github` repository
- **Consistency**: Ensures all modules have identical documentation formatting

## ⚙️ Configuration Details

Both configurations support:
- ✅ Markdown table format
- ✅ Inject mode (preserves custom content)
- ✅ Sorted output by name
- ✅ All standard terraform-docs sections
- ✅ HTML and anchor support

**Standard configuration additionally includes:**
- 📋 TFLint results integration
- 🔒 Checkov security scan results
- 💡 Production deployment examples
- 📄 Header and footer from main.tf