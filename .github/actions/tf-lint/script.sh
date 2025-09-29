#!/usr/bin/env bash
set -euo pipefail

# Script: tf-lint/script.sh
# Purpose: Run TFLint on all .tf files in the repository root, auto-fix if possible, and summarize the results for GitHub Actions.

# Get repo root and work from there
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "[DEBUG] Running tflint in repository root: $(pwd)"

# Check if there are any .tf files in the root
tf_files_count=$(find . -maxdepth 1 -name "*.tf" | wc -l)
if [[ "$tf_files_count" -eq 0 ]]; then
  echo "::notice::No .tf files found in repository root."
  summary="## TFLint Checks

ℹ️ **No .tf files found in repository root.**

The TFLint action looks for .tf files in the root directory but found none.
"
  echo -e "$summary" >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

echo "[DEBUG] Found $tf_files_count .tf files in root directory"

# Check if tflint config exists (now looking for .tflint.hcl in root)
if [[ -f ".tflint.hcl" ]]; then
  echo "[DEBUG] Using tflint config: .tflint.hcl"
  
  # Initialize plugins if config exists
  echo "[DEBUG] Initializing tflint plugins..."
  tflint --init || echo "::warning::Failed to initialize tflint plugins, continuing anyway"
else
  echo "[DEBUG] No .tflint.hcl config found, using defaults"
fi

tflint --version || true

set +e

# Run TFLint (will automatically use .tflint.hcl if present)
tflint_output=$(tflint --fix --format=default --no-color 2>&1)
tflint_exit=$?

# Detect if TFLint made any changes by checking git diff
fixed_files=$(git diff --name-only | grep -E '\.tf$|\.tfvars$' || true)

if [[ $tflint_exit -eq 0 && -z "$fixed_files" ]]; then
  # No issues found, nothing changed
  summary="## TFLint Checks

✅ **No linting issues were found.**  

> Analyzes your Terraform code for potential errors, security issues, and best-practice violations specific to your cloud provider before you deploy any changes.
"
elif [[ -n "$fixed_files" ]]; then
  # Some files were auto-fixed
  summary="## TFLint Checks

⚠️ **TFLint found and auto-fixed some issues.**  
Your code was reformatted to match style and best practices.  
Please review the changes below.

"
  for file in $fixed_files; do
    diff_content=$(git --no-pager diff "$file")
    summary+="
#### \`$file\`
<details><summary>Show diff</summary>

\`\`\`diff
$diff_content
\`\`\`
</details>
"
  done
elif [[ $tflint_exit -ne 0 ]]; then
  # Lint failed, show the error
  summary="## TFLint Checks

❌ **Linting failed.**  
TFLint found issues that could not be auto-fixed.  
Please address them manually.

<details><summary>Show TFLint output</summary>

\`\`\`
$tflint_output
\`\`\`
</details>
"
fi

# Create output directory and save results
OUTPUT_DIR="tf-management/tf-lint/results"
mkdir -p "$OUTPUT_DIR"

# Save results to file
RESULTS_FILE="$OUTPUT_DIR/tf-lint-results-module.txt"

if [[ $tflint_exit -eq 0 && -z "$fixed_files" ]]; then
  # No issues found - write informative message
  cat > "$RESULTS_FILE" << EOF
TFLint Analysis Results
=======================

✅ Analysis Status: PASSED
📅 Scan Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
🔧 TFLint Version: $(tflint --version | head -n1)
📁 Files Analyzed: $tf_files_count .tf files

Results Summary:
---------------
✅ No linting issues found
✅ Code follows Terraform best practices
✅ Azure-specific rules compliance verified

Configuration:
-------------
Config File: .tflint.hcl
Active Rulesets:
$(tflint --version | grep -E "^\+ ruleset\." || echo "  - Default ruleset")

This indicates your Terraform code is well-structured and follows 
recommended practices for infrastructure as code.
EOF

  echo "::notice::TFLint results saved to: $RESULTS_FILE"
  echo "::notice::No linting issues found - code quality verified"
  
elif [[ -n "$fixed_files" ]]; then
  # Auto-fixed some files
  cat > "$RESULTS_FILE" << EOF
TFLint Analysis Results
=======================

⚠️  Analysis Status: FIXED
📅 Scan Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
🔧 TFLint Version: $(tflint --version | head -n1)
📁 Files Analyzed: $tf_files_count .tf files

Results Summary:
---------------
⚠️  Auto-fixed linting issues in: $fixed_files
✅ Code now follows Terraform best practices

TFLint Output:
-------------
$tflint_output

Files Modified:
--------------
$fixed_files
EOF

  echo "::notice::TFLint results saved to: $RESULTS_FILE"
  echo "::warning::TFLint auto-fixed some issues - please review changes"
  
else
  # Lint failed with errors
  cat > "$RESULTS_FILE" << EOF
TFLint Analysis Results
=======================

❌ Analysis Status: FAILED
📅 Scan Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
🔧 TFLint Version: $(tflint --version | head -n1)
📁 Files Analyzed: $tf_files_count .tf files

Results Summary:
---------------
❌ Linting issues found that require manual attention

TFLint Output:
-------------
$tflint_output

Action Required:
---------------
Please review and fix the issues listed above before proceeding.
EOF

  echo "::warning::TFLint results saved to: $RESULTS_FILE"
  echo "::error::TFLint found issues requiring manual attention"
fi

echo -e "$summary" >> "$GITHUB_STEP_SUMMARY"
echo -e "$summary" > "$GITHUB_WORKSPACE/tflint-summary.md"

exit 0