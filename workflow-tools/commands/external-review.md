---
name: external-review
description: Obtain external AI review of a document using configured review commands.
disable-model-invocation: true
---

# External Review

Obtain external AI review of a document for a fresh perspective on research or plan documents.

**Arguments:** $ARGUMENTS

## Step 1: Determine Target Document

If `$ARGUMENTS` contains a document reference, use that document.

Otherwise, use AskUserQuestion to ask:
> What document would you like reviewed?

Present at most 2 options: prioritize documents created in the current session (most recent first), then fall back to the most recent documents in `working-notes/`.

## Step 2: Run External Reviews

Craft a review prompt appropriate for the document type and codebase context. Include:
- The document path
- What aspects to evaluate (technical accuracy, completeness, alignment with project patterns, missing considerations, risk analysis)
- Request for specific, actionable feedback

Run the external review script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/external-review.sh "<document_path>" "<review_prompt>"
```

If the script reports that `CLAUDE_EXTERNAL_REVIEW_COMMAND` is not set, show the user the setup instructions from the script output.

## Step 3: Synthesize Feedback

Analyze the combined feedback from all reviewers:

- Identify **common themes** where multiple reviewers agreed
- Highlight **conflicting recommendations** where reviewers disagreed
- Note which points were mentioned by multiple reviewers (higher confidence)

For each piece of feedback, critically evaluate:
- Is this technically sound?
- Does it identify real risks or theoretical concerns?
- Would implementing it provide meaningful value?
- Does it align with project constraints and priorities?
- Is the feedback making assumptions?

Dismiss feedback that doesn't meet a high bar for quality and relevance.

## Step 4: Present Summary

Provide a concise summary structured as:

**Common Themes** (mentioned by multiple reviewers):
- Point with agreement
  - **Recommended action**: Implement/Consider/Discard
  - **Reasoning**: Clear explanation

**Unique Insights**:
- Reviewer-specific point
  - **Recommended action**: Implement/Consider/Discard
  - **Reasoning**: Clear explanation

**Conflicting Views** (if any):
- Reviewer 1 says X, Reviewer 2 says Y
  - **Recommended action**: Consider/Discard
  - **Reasoning**: Explanation of conflict and resolution

Format the response to be scannable and actionable.
