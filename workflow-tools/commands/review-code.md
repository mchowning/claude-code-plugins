---
name: workflow-tools:review-code
description: Get external AI review of code changes or implementation plans. Runs GPT and Gemini in parallel for diverse perspectives.
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/review.sh:*)
  - Bash(git diff*)
  - Bash(git show*)
  - Bash(git log*)
  - Bash(git status*)
  - Bash(git branch*)
  - Bash(ls *)
  - Bash(date *)
  - Read
  - Glob
  - Grep
  - Task
  - AskUserQuestion
---

# Code Review

Get external AI review of code changes or implementation plans from multiple models (GPT 5.2 and Gemini 3 Pro) for diverse perspectives.

**Arguments:** $ARGUMENTS

## Step 1: Determine What to Review

**If `$ARGUMENTS` specifies a document or "plan":**

- Use the specified document as the review target
- This is likely a plan document describing intended code changes

**If `$ARGUMENTS` specifies "diff", "changes", or "code":**

- Review uncommitted changes (`git diff`) or the current PR

**If `$ARGUMENTS` is empty, auto-detect:**

1. Check for uncommitted changes: `git status --porcelain`
2. If uncommitted changes exist:
   - Use AskUserQuestion: "What would you like reviewed?"
   - Options:
     - "Current uncommitted changes" (description: "git diff of staged and unstaged changes")
     - Show 1-2 recent plan docs from `working-notes/` if they exist
3. If no uncommitted changes:
   - Look for recent plan documents in `working-notes/`
   - Present options via AskUserQuestion

## Step 2: Find the Intent/Plan Document

**Critical for detecting unintended behavioral changes.**

Before reviewing code changes, search for a related plan document that describes the intent:

1. **Check branch name for clues:**
   - Run `git branch --show-current`
   - Look for ticket numbers (e.g., `ABC-1234/feature-name`)
   - Search `working-notes/` for files mentioning that ticket

2. **Check recent plan documents:**
   - `ls -t working-notes/*plan*.md 2>/dev/null | head -3`
   - Read their overviews to see if they relate to current changes

3. **Check git log for plan references:**
   - Recent commits may reference plan documents

**If a plan document is found:**

- Read it to understand the intended changes
- Include reference to it in the review instructions

**If no plan document is found:**

- Ask the user: "I couldn't find a plan document for these changes. Can you provide:"
  - Options:
    - "Path to a plan document"
    - "Brief description of the intent" (use "Other" for free text)
    - "Skip intent context" (description: "Review without intent context - may miss unintended changes")

## Step 3: Craft Review Instructions

Build clear, specific instructions for the external reviewers using the templates below.

### Core Evaluation Criteria

All reviews should evaluate:

1. **Assumptions**: What assumptions does this make? Are they safe? Could they silently break if conditions change?

2. **Fragility**: Does this make the code fragile or easy to break when changes are made—either to this code or elsewhere in the codebase?

3. **Hidden coupling**: Are there implicit dependencies (execution order, global state, timing, external systems) that aren't obvious?

4. **Test coverage**: Are tests verifying the important behaviors? Would a regression be caught?

5. **Security**: Any vulnerabilities introduced (injection, auth bypass, data exposure)?

6. **Error handling**: If something fails, will the error surface clearly?

7. **Unintended behavioral changes**: Are there changes to existing behaviors or user flows that weren't intended?

8. **What's missing**: Is there anything that should be included but isn't?

---

### Template: Plan Documents

Use when reviewing an implementation plan:

```
Review the implementation plan at: [exact file path]

Evaluate using the core criteria:
- Assumptions
- Fragility
- Hidden coupling
- Test coverage
- Security
- Error handling
- Unintended behavioral changes
- What's missing

Plus:
- **Plan-specific**: Does this approach make sense? Are there better alternatives?

Be specific. Cite sections of the plan. Focus on actionable issues, not style preferences.
```

### Template: Code with Plan Context

Use when reviewing code changes AND a plan document was found:

```
Review the code changes in this repository.

To see the changes, run: git diff
(Or if reviewing a specific commit: git show [commit])

## Intent
The intended changes are described in: [plan document path]
Read that document to understand what these changes are supposed to accomplish.

Evaluate using the core criteria:
- Assumptions
- Fragility
- Hidden coupling
- Test coverage
- Security
- Error handling
- Unintended behavioral changes
- What's missing

Plus:
- **Alignment with intent**: Do these changes achieve what the plan describes? Are there deviations?
- **What's missing from plan**: Based on the plan, is anything missing from these changes?

Be specific. Cite file names and line numbers. Focus on actionable issues.
```

### Template: Code without Plan Context

Use when reviewing code changes without a plan document:

```
Review the code changes in this repository.

To see the changes, run: git diff

Evaluate using the core criteria:
- Assumptions
- Fragility
- Hidden coupling
- Test coverage
- Security
- Error handling
- Unintended behavioral changes
- What's missing

Be specific. Cite file names and line numbers. Focus on actionable issues.
```

## Step 4: Run External Reviews

Run the review script with your crafted instructions:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh "<review_instructions>"
```

The external agents will read the files and run git commands themselves based on your instructions.

## Step 5: Synthesize Feedback

Analyze the combined feedback from all reviewers:

**Identify patterns:**

- **Common themes**: Issues both reviewers flagged (higher confidence)
- **Unique insights**: Valid points only one reviewer caught
- **Conflicting views**: Where reviewers disagree

**Critically evaluate each piece of feedback:**

- Is this technically sound and applicable to THIS codebase?
- Does it identify a real risk or just a theoretical concern?
- Is the reviewer making incorrect assumptions about the code?
- Would addressing this provide meaningful value?

**Be skeptical.** External models don't know your codebase as well as Claude does. Dismiss feedback that:

- Is based on incorrect assumptions
- Doesn't apply to your specific context
- Adds unnecessary complexity
- Is a style preference rather than a real issue

## Step 6: Present Summary

Provide a concise, actionable summary:

```
## Code Review Summary

### High-Confidence Issues (flagged by multiple reviewers)

1. **[Issue title]**
   - GPT 5.2: [their point]
   - Gemini: [their point]
   - **Recommendation**: [Implement / Consider / Discuss]
   - **Reasoning**: [Why this matters or doesn't]

### Notable Insights

1. **[Issue title]** (from [reviewer])
   - **Recommendation**: [Implement / Consider / Dismiss]
   - **Reasoning**: [Explanation]

### Dismissed Feedback

- [Brief note on feedback that was dismissed and why]

### Summary

[Brief overall assessment and recommended next steps]
```

Format the response to be scannable and actionable.
