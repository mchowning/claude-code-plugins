You are tasked with obtaining external review of a document.

**Arguments:** $ARGUMENTS

Follow these specific steps:

1. **Check if arguments were provided** (see `$ARGUMENTS` above):
   - If `$ARGUMENTS` contains a reference to a specific document, skip the default message below.

2. **If `$ARGUMENTS` is empty**, respond with:

Use the AskUserQuestion tool to present these options:

```
What document would you like me to review?
```

For Options, present at most 2 documents: prioritize documents you created in the current session (most recent first), then fall back to the most recent documents in the `working-notes/` directory.

3. **Check for the external review command environment variable**

**Environment Variable Format**: The `CLAUDE_EXTERNAL_REVIEW_COMMAND` environment variable should contain one or more review commands separated by the delimiter `: ` (colon followed by space). Each command should include everything needed to invoke the model except the actual prompt.

First, define a helper function to extract review commands:

```bash
get_review_commands() {
  if [ -z "${CLAUDE_EXTERNAL_REVIEW_COMMAND:-}" ]; then
    return 1
  fi

  # Split on ": " delimiter to get individual commands
  # The format is: "cmd1 run: cmd2 run: cmd3 run"
  echo "${CLAUDE_EXTERNAL_REVIEW_COMMAND}"
  return 0
}
```

Then check if any review commands are configured:

```bash
mapfile -t REVIEW_CMDS < <(get_review_commands)

if [ ${#REVIEW_CMDS[@]} -eq 0 ]; then
  # No commands configured - show error message
fi
```

If no commands are configured, give the user the following prompt:

```
To use this slash command you must set up the terminal command to use for external review and store it as the environment variable `CLAUDE_EXTERNAL_REVIEW_COMMAND`. This command should include everything other than the prompt that is needed to access another model.

The variable format uses `: ` (colon followed by space) as a delimiter to separate multiple review commands:

For single reviewer:
  CLAUDE_EXTERNAL_REVIEW_COMMAND="opencode --model github-copilot/gpt-5 run"

For multiple reviewers (colon-separated):
  CLAUDE_EXTERNAL_REVIEW_COMMAND="opencode --model github-copilot/gpt-5 run: opencode --model deepseek/deepseek-v3 run"
```

4. **Obtain external reviews in parallel**

Run all review commands simultaneously using bash background jobs:

```bash
# Generate unique temp file for each reviewer
for i in "${!REVIEW_CMDS[@]}"; do
  (
    ${REVIEW_CMDS[$i]} "Review the document at RELEVANT_DOC_PATH and provide detailed feedback. Evaluate:

    1. Technical accuracy and completeness of the implementation approach
    2. Alignment with project standards (check project documentation like CLAUDE.md, package.json, configuration files, and existing patterns)
    3. Missing technical considerations (error handling, rollback procedures, monitoring, security)
    4. Missing behavioral considerations (user experience, edge cases, backward compatibility)
    5. Missing strategic considerations (deployment strategy, maintenance burden, alternative timing)
    6. Conflicts with established patterns in the codebase
    7. Risk analysis completeness
    8. Testing strategy thoroughness

    Be specific about what's missing or incorrect. Cite file paths and line numbers where relevant. Focus on actionable improvements that would reduce implementation risk." > "/tmp/review_${i}.txt" 2>&1
  ) &
done

# Wait for all background jobs to complete
wait
```

Feel free to tweak the prompt to be more applicable to this document and codebase.

5. **Collect and combine all reviews**

Read all review outputs and synthesize them:

```bash
# Read all review files
for i in "${!REVIEW_CMDS[@]}"; do
  if [ -f "/tmp/review_${i}.txt" ]; then
    echo "=== Review from Reviewer $((i+1)) ==="
    cat "/tmp/review_${i}.txt"
    echo ""
  fi
done
```

Analyze the combined feedback:
- Identify **common themes** where multiple reviewers agreed
- Highlight **conflicting recommendations** where reviewers disagreed
- Note which points were mentioned by multiple reviewers (higher confidence)
- Apply a skeptical lens to identify which feedback items are truly critical and actionable

Consider for each piece of feedback:
- Is this feedback technically sound?
- Does this feedback identify real risks or just theoretical concerns?
- Would implementing this feedback provide meaningful value, or is it unnecessary complexity?
- Does this feedback align with the project's constraints and priorities?
- Is the feedback making assumptions?

Dismiss feedback that doesn't meet a high bar for quality and relevance. It's possible that none of the feedback is valuable - if that's the case, clearly state that and explain why.

6. **Present unified summary to the user**

Provide a concise summary of the combined external review feedback with your recommendations. Structure it as:

**Common Themes** (mentioned by multiple reviewers):
- Point with agreement from reviewers 1 and 2
  - **Recommended action**: Implement/Consider/Discard
  - **Reasoning**: Clear explanation

**Unique Insights**:
- Reviewer 1 specific point
  - **Recommended action**: Implement/Consider/Discard
  - **Reasoning**: Clear explanation

**Conflicting Views**:
- Reviewer 1 says X, Reviewer 2 says Y
  - **Recommended action**: Consider/Discard
  - **Reasoning**: Explanation of why conflict exists and how to resolve

Format your response to be scannable and actionable. Group similar feedback items together where appropriate.
