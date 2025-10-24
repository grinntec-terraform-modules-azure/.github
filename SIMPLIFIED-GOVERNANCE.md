# 🚀 Simplified Centralized Terraform Governance

This is the ultra-simplified approach where everything is centralized and standardized.

## 📁 File Structure

```
.github/
├── .terraform-docs.yml                                    # Single central config
├── .github/
│   ├── workflows/
│   │   ├── terraform-module-governance.yml                # Original (complex)
│   │   └── terraform-module-governance-simplified.yml     # New (simple)
│   └── actions/
│       ├── terraform-docs/                                # Original (complex)  
│       └── terraform-docs-simple/                         # New (simple)
└── terraform-configs/                                     # Legacy (can be removed)
```

## 🎯 How It Works

### 1. **Central Configuration**
- **One config file**: `.github/.terraform-docs.yml`
- **Used by all repos**: No local configs needed
- **Automatic download**: Actions fetch it directly

### 2. **Simplified Workflow**
- **No inputs needed**: Uses sensible defaults
- **Always runs**: Format, validate, lint, security, docs
- **Auto-commit**: Pushes changes back

### 3. **Ultra-Simple Repository Workflow**
```yaml
# In any Terraform module repository
name: 🚀 Terraform Governance
on:
  push:
    branches: [main]
    paths: ['**/*.tf']

jobs:
  governance:
    uses: grinntec-terraform-modules-azure/.github/.github/workflows/terraform-module-governance-simplified.yml@main
```

## ✅ Benefits

1. **🎯 Zero Configuration**: Repos need almost no setup
2. **📋 Consistency**: All repos behave identically  
3. **🔧 Easy Updates**: Change once, applies everywhere
4. **🚀 Simple**: 22-line workflow files in repos
5. **💾 Maintainable**: All logic centralized

## 🔄 Migration Path

### For New Repositories:
1. Copy `terraform-governance-ultra-simple.yml` to `.github/workflows/`
2. Done! 

### For Existing Repositories:
1. **Test**: Run ultra-simple workflow alongside existing
2. **Compare**: Verify output is identical  
3. **Switch**: Disable old workflows
4. **Clean**: Remove local configs and complex workflows

## 📚 Usage Examples

### Standard Module Repository:
```yaml
# .github/workflows/terraform-governance.yml
name: 🚀 Terraform Governance
on: [push, pull_request]
jobs:
  governance:
    uses: grinntec-terraform-modules-azure/.github/.github/workflows/terraform-module-governance-simplified.yml@main
```

### That's it! 🎉

No configuration files, no complex inputs, no maintenance needed.

## 🛠️ What Gets Automated

- ✅ **Format**: `terraform fmt`
- ✅ **Validate**: `terraform validate` 
- ✅ **Lint**: TFLint with rules
- ✅ **Security**: Checkov scanning
- ✅ **Documentation**: terraform-docs generation
- ✅ **Commit**: Auto-push changes

## 🎨 Emojis in Workflows

The simplified workflows use emojis to make GitHub Actions UI more friendly:
- 🚀 Launch/Deploy
- 📋 Governance/Process  
- 📚 Documentation
- 🔒 Security
- ✅ Validation
- 🎨 Formatting