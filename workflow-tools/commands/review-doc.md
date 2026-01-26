---
description: Get external AI review of research documents or general documents. Runs GPT and Gemini in parallel for diverse perspectives.
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/review.sh *)
  - Bash(ls *)
  - Bash(date *)
  - Read
  - Glob
  - AskUserQuestion
---

# Document Review

Get external AI review of research documents or general documents from multiple models (GPT 5.2 and Gemini 3 Pro) for diverse perspectives.

**Arguments:** $ARGUMENTS

## Step 1: Determine What to Review

**If `$ARGUMENTS` specifies a document:**
- Use the specified document as the review target

**If `$ARGUMENTS` is empty:**

1. Find recent documents in `working-notes/`:
   ```bash
   ls -t working-notes/*.md 2>/dev/null | head -3
   ```

2. Use AskUserQuestion:
   - Question: "What document would you like reviewed?"
   - Options: Show up to 2-3 recent documents from `working-notes/`
     - Prioritize research docs (`*research*`) over plan docs
     - Label: Filename
     - Description: Relative path

## Step 2: Craft Review Instructions

Build clear, specific instructions for the external reviewers:

```
Review the document at: [exact file path]

Evaluate:

1. **Clarity and structure**: Is the document well-organized? Are the main points clear?

2. **Completeness**: Are there gaps in the analysis or missing considerations?

3. **Technical accuracy**: Are the technical claims and assumptions correct?

4. **Logical consistency**: Does the reasoning flow logically? Are there contradictions?

5. **Actionability**: If this is meant to inform decisions, does it provide enough information to act on?

6. **Missing perspectives**: What viewpoints or considerations are not represented?

7. **Assumptions**: What assumptions does this document make? Are they stated explicitly?

8. **Risk analysis**: If applicable, are risks adequately identified and assessed?

Be specific. Cite sections of the document. Focus on substantive improvements, not style preferences.
```

## Step 3: Run External Reviews

Run the review script with your crafted instructions:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/review.sh "<review_instructions>"
```

The external agents will read the document themselves based on your instructions.

## Step 4: Synthesize Feedback

Analyze the combined feedback from all reviewers:

**Identify patterns:**
- **Common themes**: Issues both reviewers flagged (higher confidence)
- **Unique insights**: Valid points only one reviewer caught
- **Conflicting views**: Where reviewers disagree

**Critically evaluate each piece of feedback:**
- Is this feedback applicable to the document's purpose?
- Does it identify a real gap or just a theoretical concern?
- Is the reviewer making incorrect assumptions?
- Would addressing this meaningfully improve the document?

**Be skeptical.** Dismiss feedback that:
- Is based on incorrect assumptions about context
- Doesn't serve the document's purpose
- Is a style preference rather than a substantive issue
- Would add noise without adding value

## Step 5: Present Summary

Provide a concise, actionable summary:

```
## Document Review Summary

### High-Confidence Issues (flagged by multiple reviewers)

1. **[Issue title]**
   - GPT 5.2: [their point]
   - Gemini: [their point]
   - **Recommendation**: [Address / Consider / Dismiss]
   - **Reasoning**: [Why this matters or doesn't]

### Notable Insights

1. **[Issue title]** (from [reviewer])
   - **Recommendation**: [Address / Consider / Dismiss]
   - **Reasoning**: [Explanation]

### Dismissed Feedback

- [Brief note on feedback that was dismissed and why]

### Summary

[1-2 sentences on overall assessment and recommended next steps]
```

Format the response to be scannable and actionable.
