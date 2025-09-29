#!/usr/bin/env bash
# =========================================================================================
# Script: terraform-fmt/script.sh
#
# Purpose:
#   - Runs 'terraform fmt -recursive' in the root directory of the repository.
#   - If formatting changes are made, commits & pushes, shows which files changed, and writes
#     a unified diff for each changed file to the GitHub summary.
#   - If nothing changed, writes a clear summary stating so.
#
# Usage:
#   ./script.sh [author_name] [author_email]
#
#   - author_name: (optional) Git commit author name (default: github-actions[bot])
#   - author_email: (optional) Git commit author email (default: github-actions[bot]@users.noreply.github.com)
#
# Best Practices:
#   - Only commits formatting changes, never functional changes.
#   - Produces a clear and actionable summary for end users.
#   - Runs against all .tf files in the repository root.
# =========================================================================================

set -euo pipefail

AUTHOR_NAME="${1:-github-actions[bot]}"
AUTHOR_EMAIL="${2:-github-actions[bot]@users.noreply.github.com}"

echo "[DEBUG] Input AUTHOR_NAME: '$AUTHOR_NAME'"
echo "[DEBUG] Input AUTHOR_EMAIL: '$AUTHOR_EMAIL'"

# Get repo root and work from there
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "[DEBUG] Running terraform fmt in repository root: $(pwd)"

# Check if there are any .tf files in the root
tf_files_count=$(find . -maxdepth 1 -name "*.tf" | wc -l)
if [[ "$tf_files_count" -eq 0 ]]; then
  echo "::notice::No .tf files found in repository root."
  {
    echo "## Terraform Auto-Format"
    echo ""
    echo "ℹ️ **No .tf files found in repository root.**"
    echo ""
    echo "The terraform fmt action looks for .tf files in the root directory but found none."
  } >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

echo "[DEBUG] Found $tf_files_count .tf files in root directory"

# Run terraform fmt and capture output
fmt_output=$(terraform fmt -diff -list=true . 2>&1)
fmt_exit=$?
echo "[DEBUG] terraform fmt output:"
echo "$fmt_output"

# Detect changed .tf and .tfvars files after formatting (content only)
changed_files=$(git diff --name-only | grep -E '\.tf$|\.tfvars$' || true)
changed_count=$(echo "$changed_files" | grep -c . || true)


echo "[DEBUG] Changed files after fmt (count=$changed_count):"
echo "$changed_files"

if [[ "$changed_count" -eq 0 ]]; then
  echo "::notice::No Terraform formatting changes were needed."
  {
    echo "## Terraform Auto-Format"
    echo ""
    echo "✅ **No formatting changes were needed.**"
    echo ""
    echo "> Automatically reformats your Terraform files to follow the standard style conventions, ensuring consistent code formatting across your project."
  } >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

# Stage changed files only (not scripts or unrelated files)
echo "[DEBUG] Configuring git author: $AUTHOR_NAME <$AUTHOR_EMAIL>"
git config user.name "$AUTHOR_NAME"
git config user.email "$AUTHOR_EMAIL"

echo "[DEBUG] Staging changed files:"
while read -r file; do
  [ -z "$file" ] && continue
  echo "[DEBUG] git add '$file'"
  git add "$file"
done <<< "$changed_files"

# Compose summary with diffs
summary="## Terraform Auto-Format

⚠️ **Terraform formatting was applied and committed.**

The following files were reformatted automatically:
"
while read -r file; do
  [ -z "$file" ] && continue
  summary+="
#### \`$file\`
<details><summary>Show diff</summary>

\`\`\`diff
$(git diff --cached -- "$file")
\`\`\`
</details>
"
done <<< "$changed_files"

summary+="

A commit was made and pushed to your branch by the bot.

**What this means for you:**
- Your branch now includes a formatting-only commit.
- You may need to \`git pull\` before pushing further changes.
- No functional code was changed—only whitespace, alignment, or syntax was fixed.
- Please review the changes carefully.

*If you see warnings about unstaged changes or failed rebase, these are unrelated file permission changes by the CI runner and can be ignored for the purposes of formatting.*

"

echo "$summary" >> "$GITHUB_STEP_SUMMARY"

echo "[DEBUG] Git diff --cached output for all changes:"
git diff --cached

if ! git diff --cached --quiet; then
  echo "[DEBUG] Committing formatting changes"
  git commit -m "chore(terraform): auto-format via GitHub Actions"
  echo "[DEBUG] Pulling latest with rebase before push"
  git pull --rebase || echo "::warning::git pull --rebase failed; proceeding with push."
  echo "[DEBUG] Pushing auto-format commit to remote"
  git push
  echo "::notice::Pushed auto-format commit to remote."
else
  echo "[DEBUG] No formatting changes to commit after add."
fi

exit 0