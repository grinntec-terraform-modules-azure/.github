#!/usr/bin/env bash
set -euo pipefail

# Script: terraform-validate/script.sh
# Purpose: Run terraform validate on the module without creating any resources or state files

# Get repo root and work from there
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "[DEBUG] Running terraform validate in repository root: $(pwd)"

# Check if there are any .tf files in the root
tf_files_count=$(find . -maxdepth 1 -name "*.tf" | wc -l)
if [[ "$tf_files_count" -eq 0 ]]; then
  echo "::notice::No .tf files found in repository root."
  summary="## Terraform Validate

ℹ️ **No .tf files found in repository root.**

The terraform validate action looks for .tf files in the root directory but found none.
"
  echo -e "$summary" >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

echo "[DEBUG] Found $tf_files_count .tf files in root directory"

# Initialize Terraform (downloads providers based on .terraform.lock.hcl)
echo "[DEBUG] Initializing Terraform (downloading providers only)..."
terraform init -backend=false

# Validate the configuration
echo "[DEBUG] Running terraform validate..."
set +e
validate_output=$(terraform validate -json 2>&1)
validate_exit=$?
set -e

echo "[DEBUG] Terraform validate exit code: $validate_exit"
echo "[DEBUG] Terraform validate output:"
echo "$validate_output"

# Parse the JSON output if validation succeeded
if [[ $validate_exit -eq 0 ]]; then
  # Check if the output is valid JSON
  if echo "$validate_output" | jq . > /dev/null 2>&1; then
    valid=$(echo "$validate_output" | jq -r '.valid')
    error_count=$(echo "$validate_output" | jq -r '.error_count')
    warning_count=$(echo "$validate_output" | jq -r '.warning_count')
    
    if [[ "$valid" == "true" && "$error_count" == "0" ]]; then
      echo "::notice::Terraform configuration is valid!"
      
      summary="## Terraform Validate ✅

✅ **Configuration is valid**

- **Syntax**: All .tf files have valid HCL syntax
- **References**: All variable and resource references are correct
- **Providers**: All required providers are properly configured
- **Files validated**: $tf_files_count .tf files
- **Errors**: 0
- **Warnings**: $warning_count

The Terraform configuration can be safely deployed.
"
    else
      echo "::error::Terraform configuration has validation errors"
      summary="## Terraform Validate ❌

❌ **Configuration has errors**

- **Valid**: $valid
- **Errors**: $error_count  
- **Warnings**: $warning_count
- **Files checked**: $tf_files_count .tf files

\`\`\`
$validate_output
\`\`\`
"
    fi
  else
    # If output is not JSON, treat as error
    echo "::error::Terraform validate failed with non-JSON output"
    summary="## Terraform Validate ❌

❌ **Validation failed**

\`\`\`
$validate_output
\`\`\`
"
  fi
else
  echo "::error::Terraform validate failed with exit code: $validate_exit"
  summary="## Terraform Validate ❌

❌ **Validation failed with exit code: $validate_exit**

\`\`\`
$validate_output
\`\`\`
"
fi

# Add summary to GitHub Actions
echo -e "$summary" >> "$GITHUB_STEP_SUMMARY"

# Exit with the same code as terraform validate
exit $validate_exit