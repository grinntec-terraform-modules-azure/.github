#!/usr/bin/env bash

# --- Best practice for bash scripts, especially in CI/CD.
# -e: Exit immediately if any command fails.
# -u: Treat unset variables as errors.
# -o pipefail: If any command in a pipeline fails, the pipeline fails.
set -euo pipefail

# Script: terraform-security-scan/script.sh
# Purpose: Run Checkov security scan on Terraform files in the repository root

# Get repo root and work from there
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "[DEBUG] Running Checkov security scan in repository root: $(pwd)"

# Check if there are any .tf files in the root
tf_files_count=$(find . -maxdepth 1 -name "*.tf" | wc -l)
if [[ "$tf_files_count" -eq 0 ]]; then
  echo "::notice::No .tf files found in repository root."
  summary="## Terraform Security Scan

ℹ️ **No .tf files found in repository root.**

The security scan looks for .tf files in the root directory but found none.
"
  echo -e "$summary" >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

echo "[DEBUG] Found $tf_files_count .tf files in root directory"

# Ensure PATH includes Python user bin directory
export PATH="$HOME/.local/bin:$PATH"
echo "[DEBUG] PATH: $PATH"

# Verify Checkov is available
if ! command -v checkov &> /dev/null; then
    echo "::error::Checkov command not found. Attempting to locate..."
    find "$HOME" -name "checkov" -type f 2>/dev/null | head -5
    exit 1
fi

echo "[DEBUG] Checkov location: $(which checkov)"
echo "[DEBUG] Checkov version: $(checkov --version 2>&1 | head -1)"

# Ensure Checkov cache directory exists and is writable
mkdir -p ~/.checkov ~/.cache/checkov
echo "[DEBUG] Checkov cache directories prepared"

# Create output directory for results
OUTPUT_DIR="tf-management/checkov/module"
mkdir -p "$OUTPUT_DIR"
echo "[DEBUG] Created output directory: $OUTPUT_DIR"

# Set up environment variables for optimal caching
export CHECKOV_RUNNER_FILTER=""
export CHECKOV_LOG_LEVEL="WARNING"  # Reduce logging verbosity

# --- Run Checkov against the Terraform files with optimized settings ---
set +e
checkov_output=$(checkov -d . \
  --framework terraform \
  2>&1)
checkov_exit=$?

# Save CLI output to a specific file for later use
checkov -d . \
  --framework terraform \
  --download-external-modules false \
  > "./$OUTPUT_DIR/results_cli.txt" 2>&1

echo "[DEBUG] Checkov exit code: $checkov_exit"
echo "[DEBUG] Results file created with $(wc -l < "./$OUTPUT_DIR/results_cli.txt") lines"
set -e

echo "[DEBUG] Checkov exit code: $checkov_exit"
echo "[DEBUG] Checkov output (first 500 chars):"
echo "${checkov_output:0:500}..."

# --- Set result and help text ---
if [ $checkov_exit -eq 0 ]; then
  checkov_result="✅ No security issues found"
  echo "::notice::Checkov security scan passed!"
else
  checkov_result="⚠️ Security issues detected"
  echo "::warning::Checkov found security issues (exit code $checkov_exit)"
fi

help=$(cat <<EOF
> - Checkov scanned your Terraform files for security misconfigurations and compliance issues.
> - If issues are found, review the findings below and fix critical security concerns.
> - This scan helps ensure your infrastructure follows security best practices.
EOF
)

checkov_details=$(cat <<EOF
<details><summary>Show Checkov Security Scan Results</summary>

\`\`\`
$checkov_output
\`\`\`
</details>
EOF
)

# --- Build Markdown summary ---
summary=$(cat <<EOF
## Terraform Security Scan

$checkov_result

$help

$checkov_details
EOF
)

# --- Write summary to GitHub Actions UI ---
echo "$summary" >> "$GITHUB_STEP_SUMMARY"

# --- Show file locations ---
echo "::notice::Checkov results saved to: $OUTPUT_DIR/results_cli.txt"
if [[ -f "./$OUTPUT_DIR/results_cli.txt" ]]; then
  file_size=$(wc -l < "./$OUTPUT_DIR/results_cli.txt")
  echo "[DEBUG] Results file created with $file_size lines"
  echo "::notice::View results: cat $OUTPUT_DIR/results_cli.txt"
else
  echo "::warning::Results file not created"
fi

# --- For security scans, we'll warn but not fail the build for now ---
# This allows developers to see issues without blocking the pipeline
if [[ $checkov_exit -ne 0 ]]; then
  echo "::warning::Security scan found issues. Please review and address them."
  # Uncomment the line below if you want to fail the build on security issues:
  # exit $checkov_exit
fi

echo "Security scan completed."