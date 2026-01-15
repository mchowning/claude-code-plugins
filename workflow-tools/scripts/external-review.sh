#!/usr/bin/env bash
set -euo pipefail

# external-review.sh - Run external AI reviews in parallel
#
# Usage: external-review.sh <document_path> "<review_prompt>"
#
# Requires CLAUDE_EXTERNAL_REVIEW_COMMAND environment variable:
#   Single reviewer:   "opencode --model github-copilot/gpt-5 run"
#   Multiple (JSON):   '["cmd1 run", "cmd2 run"]'

show_setup_instructions() {
  cat <<'EOF'
ERROR: CLAUDE_EXTERNAL_REVIEW_COMMAND environment variable is not set.

To use external review, set this variable to your review command(s):

Single reviewer:
  export CLAUDE_EXTERNAL_REVIEW_COMMAND="opencode --model github-copilot/gpt-5 run"

Multiple reviewers (JSON array):
  export CLAUDE_EXTERNAL_REVIEW_COMMAND='["opencode --model github-copilot/gpt-5 run", "opencode --model deepseek/deepseek-v3 run"]'

With Nix (in your home.nix):
  sessionVariables = {
    CLAUDE_EXTERNAL_REVIEW_COMMAND = "opencode --model github-copilot/gpt-5 run";
    # Or for multiple:
    CLAUDE_EXTERNAL_REVIEW_COMMAND = builtins.toJSON [
      "opencode --model github-copilot/gpt-5 run"
      "opencode --model github-copilot/gemini-3-pro-preview run"
    ];
  };
EOF
  exit 1
}

if [[ $# -lt 2 ]]; then
  echo "Usage: external-review.sh <document_path> \"<review_prompt>\""
  exit 1
fi

DOCUMENT_PATH="$1"
REVIEW_PROMPT="$2"

if [[ -z "${CLAUDE_EXTERNAL_REVIEW_COMMAND:-}" ]]; then
  show_setup_instructions
fi

# Parse review commands - supports single string or JSON array
REVIEW_CMDS=()

if [[ "${CLAUDE_EXTERNAL_REVIEW_COMMAND}" == "["* ]]; then
  # JSON array format - parse with jq if available, otherwise basic parsing
  if command -v jq &>/dev/null; then
    while IFS= read -r cmd; do
      REVIEW_CMDS+=("$cmd")
    done < <(echo "${CLAUDE_EXTERNAL_REVIEW_COMMAND}" | jq -r '.[]')
  else
    # Fallback: basic JSON array parsing (handles simple cases)
    cleaned="${CLAUDE_EXTERNAL_REVIEW_COMMAND#[}"
    cleaned="${cleaned%]}"
    IFS=',' read -ra parts <<< "$cleaned"
    for part in "${parts[@]}"; do
      # Remove surrounding quotes and whitespace
      cmd="${part#\"}"
      cmd="${cmd%\"}"
      cmd="${cmd# }"
      cmd="${cmd% }"
      cmd="${cmd#\"}"
      cmd="${cmd%\"}"
      [[ -n "$cmd" ]] && REVIEW_CMDS+=("$cmd")
    done
  fi
else
  # Single command format
  REVIEW_CMDS+=("${CLAUDE_EXTERNAL_REVIEW_COMMAND}")
fi

if [[ ${#REVIEW_CMDS[@]} -eq 0 ]]; then
  echo "ERROR: No review commands found in CLAUDE_EXTERNAL_REVIEW_COMMAND"
  exit 1
fi

# Create temp directory for review outputs
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Run all review commands in parallel
PIDS=()
for i in "${!REVIEW_CMDS[@]}"; do
  (
    ${REVIEW_CMDS[$i]} "${REVIEW_PROMPT}" > "${TEMP_DIR}/review_${i}.txt" 2>&1
  ) &
  PIDS+=($!)
done

# Wait for all background jobs
for pid in "${PIDS[@]}"; do
  wait "$pid" || true
done

# Output combined results
for i in "${!REVIEW_CMDS[@]}"; do
  if [[ -f "${TEMP_DIR}/review_${i}.txt" ]]; then
    echo "=== Review from Reviewer $((i+1)) (${REVIEW_CMDS[$i]%% *}) ==="
    cat "${TEMP_DIR}/review_${i}.txt"
    echo ""
    echo "---"
    echo ""
  fi
done
