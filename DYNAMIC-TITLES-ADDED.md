# 🚀 Enhanced Dynamic Terraform-Docs Configuration

## ✨ **New Dynamic Features Added:**

### 🏷️ **Dynamic Module Titles**
```yaml
# 🏗️ {{ if .Module.Resources }}{{ with index .Module.Resources 0 }}{{ .Type | title | replace "_" " " }}{{ end }} Module{{ else }}Terraform Azure Module{{ end }}
```

**How it works:**
- Examines the first resource in `{{ .Module.Resources }}`
- Extracts the resource type (e.g., `azurerm_resource_group`)
- Transforms it to a readable title: `"Azurerm Resource Group Module"`
- Falls back to `"Terraform Azure Module"` if no resources found

### 🎯 **Expected Results:**

| Repository | First Resource | Generated Title |
|-----------|---------------|-----------------|
| `terraform-azurerm-resource_group` | `azurerm_resource_group` | **🏗️ Azurerm Resource Group Module** |
| `terraform-azurerm-key_vault` | `azurerm_key_vault` | **🏗️ Azurerm Key Vault Module** |
| `terraform-azurerm-storage_account` | `azurerm_storage_account` | **🏗️ Azurerm Storage Account Module** |
| `terraform-azurerm-virtual_network` | `azurerm_virtual_network` | **🏗️ Azurerm Virtual Network Module** |

## 🔧 **Additional Dynamic Possibilities:**

### **Smart Resource Detection**
```yaml
# Extract multiple resource types
{{ range .Module.Resources }}
- Creates: {{ .Type | title | replace "_" " " }}
{{ end }}
```

### **Provider-Based Titles**  
```yaml
# Use provider information
{{ if .Module.Providers }}{{ with index .Module.Providers 0 }}{{ .Name | title }}{{ end }} Infrastructure Module{{ end }}
```

### **Resource Count Info**
```yaml
# Show resource statistics
> This module manages {{ len .Module.Resources }} Azure resources
```

## 🧪 **Testing the Dynamic Title:**

The current configuration should now generate titles like:
- **Resource Group repo** → "🏗️ Azurerm Resource Group Module"  
- **Key Vault repo** → "🏗️ Azurerm Key Vault Module"
- **Any repo** → Falls back to "🏗️ Terraform Azure Module"

## 📋 **Template Functions Available:**

- `{{ index .Module.Resources 0 }}` - Get first resource
- `{{ .Type }}` - Resource type (e.g., "azurerm_resource_group")
- `{{ .Type | title }}` - Title case ("Azurerm Resource Group")
- `{{ .Type | replace "_" " " }}` - Replace underscores with spaces
- `{{ len .Module.Resources }}` - Count of resources
- `{{ range .Module.Resources }}` - Loop through all resources

## 🎉 **Ready to Test!**

Run terraform-docs with this configuration to see:
1. **Dynamic titles** based on the actual resources in each module
2. **Consistent formatting** across all repositories  
3. **Fallback behavior** for edge cases

The title will automatically reflect what each module actually creates! 🚀