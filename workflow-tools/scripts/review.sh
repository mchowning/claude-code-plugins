#!/usr/bin/env bash
set -euo pipefail

# review.sh - Run external AI reviews in parallel
#
# Usage: review.sh "<review_instructions>"
#
# The instructions should tell the external agents what to review and how.
# External agents can read files, run git commands, etc. on their own.

# External review commands - edit these to change which models are used
REVIEW_CMDS=(
  "opencode --model github-copilot/gpt-5.2 run"
  "opencode --model github-copilot/gemini-3-pro-preview run"
)

# Friendly names for output
REVIEWER_NAMES=(
  "GPT 5.2"
  "Gemini 3 Pro"
)

if [[ $# -lt 1 ]]; then
  echo "Usage: review.sh \"<review_instructions>\""
  exit 1
fi

REVIEW_INSTRUCTIONS="$1"

if [[ ${#REVIEW_CMDS[@]} -eq 0 ]]; then
  echo "ERROR: No review commands configured in script"
  exit 1
fi

# Use /tmp for review output files (internal to script)
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Run all review commands in parallel
PIDS=()
for i in "${!REVIEW_CMDS[@]}"; do
  (
    ${REVIEW_CMDS[$i]} "${REVIEW_INSTRUCTIONS}" > "${TEMP_DIR}/review_${i}.txt" 2>&1
  ) &
  PIDS+=($!)
done

# Wait for all background jobs
for pid in "${PIDS[@]}"; do
  wait "$pid" || true
done

# Output combined results
for i in "${!REVIEW_CMDS[@]}"; do
  REVIEWER_NAME="${REVIEWER_NAMES[$i]:-Reviewer $((i+1))}"
  if [[ -f "${TEMP_DIR}/review_${i}.txt" ]]; then
    echo "=== Review from ${REVIEWER_NAME} ==="
    echo ""
    cat "${TEMP_DIR}/review_${i}.txt"
    echo ""
    echo "---"
    echo ""
  fi
done
