#!/usr/bin/env bash

# --- Best practice for bash scripts, especially in CI/CD.
# -e: Exit immediately if any command fails.
# -u: Treat unset variables as errors.
# -o pipefail: If any command in a pipeline fails, the pipeline fails.
set -euo pipefail

# Script: terraform-docs/script.sh
# Purpose: Generate Terraform module documentation using terraform-docs

CONFIG_FILE="${1:-./tf-management/tf-docs/tf-docs.yaml}"
OUTPUT_FILE="${2:-README.md}"
WORKING_DIR="${3:-.}"
USE_CENTRAL_CONFIG="${4:-false}"

# Get repo root and work from there
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# If central config is requested, use the central configuration
if [[ "$USE_CENTRAL_CONFIG" == "true" ]]; then
    CENTRAL_CONFIG_URL="https://raw.githubusercontent.com/grinntec-terraform-modules-azure/.github/main/terraform-configs/tf-docs-standard.yaml"
    echo "[DEBUG] Using central configuration from: $CENTRAL_CONFIG_URL"
    
    # Download central config
    if curl -sL "$CENTRAL_CONFIG_URL" -o ".tf-docs-central.yaml" 2>/dev/null; then
        CONFIG_FILE=".tf-docs-central.yaml"
        echo "[DEBUG] Central configuration downloaded successfully"
    else
        echo "::warning::Failed to download central config, falling back to local config"
    fi
fi

# Handle remote config URLs
if [[ "$CONFIG_FILE" =~ ^https?:// ]]; then
    echo "[DEBUG] Downloading remote config file from: $CONFIG_FILE"
    if curl -sL "$CONFIG_FILE" -o ".tf-docs-remote.yaml" 2>/dev/null; then
        CONFIG_FILE=".tf-docs-remote.yaml"
        echo "[DEBUG] Remote configuration downloaded successfully"
    else
        echo "::error::Failed to download remote config file: $CONFIG_FILE"
        exit 1
    fi
fi

echo "[DEBUG] Running terraform-docs in directory: $(pwd)"
echo "[DEBUG] Config file: $CONFIG_FILE"
echo "[DEBUG] Output file: $OUTPUT_FILE"
echo "[DEBUG] Working directory: $WORKING_DIR"

# Check if there are any .tf files in the target directory
tf_files_count=$(find "$WORKING_DIR" -maxdepth 1 -name "*.tf" | wc -l)
if [[ "$tf_files_count" -eq 0 ]]; then
  echo "::notice::No .tf files found in directory: $WORKING_DIR"
  summary="## Terraform Documentation

ℹ️ **No .tf files found in directory: $WORKING_DIR**

The documentation generator looks for .tf files but found none in the specified directory.
"
  echo -e "$summary" >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

echo "[DEBUG] Found $tf_files_count .tf files in directory: $WORKING_DIR"

# Ensure terraform-docs is available
if ! command -v terraform-docs &> /dev/null; then
    echo "::error::terraform-docs command not found"
    exit 1
fi

echo "[DEBUG] terraform-docs location: $(which terraform-docs)"
echo "[DEBUG] terraform-docs version: $(terraform-docs version)"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "::warning::Config file not found: $CONFIG_FILE"
    echo "[DEBUG] Using default terraform-docs configuration"
    CONFIG_OPTION=""
else
    echo "[DEBUG] Using config file: $CONFIG_FILE"
    CONFIG_OPTION="--config $CONFIG_FILE"
fi

# Backup original README if it exists
if [[ -f "$OUTPUT_FILE" ]]; then
    cp "$OUTPUT_FILE" "${OUTPUT_FILE}.backup"
    echo "[DEBUG] Backed up existing $OUTPUT_FILE"
fi

# --- Generate documentation ---
set +e
echo "[DEBUG] Generating documentation..."
if [[ -n "$CONFIG_OPTION" ]]; then
    terraform_docs_output=$(terraform-docs $CONFIG_OPTION "$WORKING_DIR" 2>&1)
else
    terraform_docs_output=$(terraform-docs markdown table --output-file "$OUTPUT_FILE" "$WORKING_DIR" 2>&1)
fi
terraform_docs_exit=$?
set -e

echo "[DEBUG] terraform-docs exit code: $terraform_docs_exit"

# --- Check results ---
if [[ $terraform_docs_exit -eq 0 ]]; then
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo "::notice::Documentation generated successfully: $OUTPUT_FILE"
        
        # Show diff if backup exists
        if [[ -f "${OUTPUT_FILE}.backup" ]]; then
            if ! diff -q "$OUTPUT_FILE" "${OUTPUT_FILE}.backup" > /dev/null 2>&1; then
                echo "[DEBUG] Documentation was updated"
                # Count diff lines safely
                set +e
                diff_lines=$(diff -u "${OUTPUT_FILE}.backup" "$OUTPUT_FILE" | wc -l)
                set -e
                echo "::notice::Documentation updated with $diff_lines lines of changes"
            else
                echo "[DEBUG] No changes to documentation"
                echo "::notice::Documentation is up to date - no changes needed"
            fi
            rm -f "${OUTPUT_FILE}.backup"
        else
            echo "::notice::New documentation file created: $OUTPUT_FILE"
        fi
        
        doc_result="✅ Documentation generated successfully"
    else
        echo "::warning::terraform-docs completed but output file not found: $OUTPUT_FILE"
        doc_result="⚠️ Documentation generation completed but output file missing"
    fi
else
    echo "::error::terraform-docs failed with exit code $terraform_docs_exit"
    echo "[DEBUG] terraform-docs output:"
    echo "$terraform_docs_output"
    doc_result="❌ Documentation generation failed"
fi

# --- Build summary ---
summary=$(cat <<EOF
## Terraform Documentation Generation

$doc_result

**Configuration:**
- Config file: \`$CONFIG_FILE\`
- Output file: \`$OUTPUT_FILE\`
- Working directory: \`$WORKING_DIR\`
- Terraform files found: $tf_files_count

**Result:**
- Exit code: $terraform_docs_exit
- Generated documentation for Terraform module
EOF
)

# --- Write summary to GitHub Actions UI ---
echo "$summary" >> "$GITHUB_STEP_SUMMARY"

# --- Clean up temporary config files ---
rm -f ".tf-docs-central.yaml" ".tf-docs-remote.yaml"

# --- Exit with terraform-docs exit code ---
if [[ $terraform_docs_exit -ne 0 ]]; then
    exit $terraform_docs_exit
fi

echo "Documentation generation completed successfully."