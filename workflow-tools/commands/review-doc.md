You are tasked with obtaining external review of a document.

Follow these specific steps:

1. **Check if arguments were provided**:
   - If the user provided a reference to a specific document to be removed, skip the default message below.

2. **If no arguments were provided**, respond with:

Use the AskUserQuestion tool to present these options:

```
What document would you like me to review?
```

For Options, present at most 2 documents: prioritize documents you created in the current session (most recent first), then fall back to the most recent documents in the `working-notes/` directory.

3. **Check for the external review command environment variable**

Look for the environment variable `CLAUDE_EXTERNAL_REVIEW_COMMAND`. If that variable exists, move to the next step. If it does not exist, give the user the following prompt:

```
To use this slash command you must set up the terminal command to use for external review and store it as the environment variable `CLAUDE_EXTERNAL_REVIEW_COMMAND`. This command should include everything other than the prompt that is needed to access another model.

For example, if you want to use opencode to obtain the external review, you could use something like:

"opencode --model github-copilot/gpt-5 run"
```

4. **Obtain external review of the document**

Invoke the provided external review command by appending the following prompt to the command in the following form:

```
${CLAUDE_EXTERNAL_REVIEW_COMMAND} "Review the document at
  RELEVANT_DOC_PATH and
  provide detailed feedback. Evaluate:

  1. Technical accuracy and completeness of the implementation approach
  2. Alignment with project standards (check project documentation like CLAUDE.md,
  package.json, configuration files, and existing patterns)
  3. Missing technical considerations (error handling, rollback procedures, monitoring,
  security)
  4. Missing behavioral considerations (user experience, edge cases, backward
  compatibility)
  5. Missing strategic considerations (deployment strategy, maintenance burden,
  alternative timing)
  6. Conflicts with established patterns in the codebase
  7. Risk analysis completeness
  8. Testing strategy thoroughness

  Be specific about what's missing or incorrect. Cite file paths and line numbers where
  relevant. Focus on actionable improvements that would reduce implementation risk."
```

Feel free to tweak the prompt to be more applicable to this document and codebase.

5. **Critically analyze the external review feedback**

Apply a skeptical lens to the feedback received from the external review. Your job is to identify which feedback items are truly critical and actionable. Consider:

- Is this feedback technically sound?
- Does this feedback identify real risks or just theoretical concerns?
- Would implementing this feedback provide meaningful value, or is it unnecessary complexity?
- Does this feedback align with the project's constraints and priorities?
- Is the feedback making assumptions?

Dismiss feedback that doesn't meet a high bar for quality and relevance. It's possible that none of the feedback is valuable - if that's the case, clearly state that and explain why.

6. **Present summary to the user**

Provide a concise summary of the external review feedback with your recommendations. For each significant piece of feedback, include:

- **Summary**: Brief description of the feedback point
- **Recommended action**: One of:
  - **Implement**: Critical feedback that should be addressed
  - **Consider**: Potentially valuable feedback worth discussing with the user
  - **Discard**: Feedback that is not valuable or applicable
- **Reasoning**: Clear explanation for your recommendation

Format your response to be scannable and actionable. Group similar feedback items together where appropriate.
