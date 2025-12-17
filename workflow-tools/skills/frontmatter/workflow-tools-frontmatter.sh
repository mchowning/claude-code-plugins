#!/usr/bin/env bash
set -euo pipefail

# Get current date/time with timezone
DATETIME_TZ=$(date '+%Y-%m-%d %H:%M:%S %Z')

echo "Current Date/Time (TZ): $DATETIME_TZ"

# Check if in git repository
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
  REPO_NAME=$(basename "$REPO_ROOT")
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD)
  GIT_COMMIT=$(git rev-parse HEAD)

  echo "Current Git Commit Hash: $GIT_COMMIT"
  echo "Current Branch Name: $GIT_BRANCH"
  echo "Repository Name: $REPO_NAME"
fi
