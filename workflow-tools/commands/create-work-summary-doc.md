# Summarize Work

You are tasked with creating comprehensive implementation summaries that document completed work. These summaries capture what was changed and why, serving as permanent documentation for future developers and AI coding agent instances.

## Process Steps

### Step 1: Check for Uncommitted Code

**Check for uncommitted code changes:**

- Run `git status` to check for uncommitted changes
- Filter out documentation files (files in `working-notes/`, `notes/`, or ending in `.md`)
- If there are uncommitted CODE changes:

  ```
  You have uncommitted code changes. Consider committing your work before generating implementation documentation.

  Uncommitted changes:
  [list the uncommitted code files]
  ```

- STOP and wait for the user to prompt you to proceed

### Step 2: Present Initial Prompt

Respond with:

```
I'll help you document the implementation work. This will create a comprehensive summary explaining what was changed and why.

Please provide any research or plan documents that were used and/or a brief description or the relevant Jira ticket.

With this context plus the git diff, I'll generate an implementation summary.
```

Then wait for the user's input.

### Step 3: Gather Jira Ticket and Git Diff Scope

1. **Determine the default branch:**
   - Run: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
   - This will return the default branch name (e.g., "main", "master", "carbon_ubuntu")
   - Use this as the base branch for all subsequent git commands
   - Store this in a variable: `DEFAULT_BRANCH`

2. **Gather Jira ticket and git diff scope using AskUserQuestion:**
   Use the AskUserQuestion tool with two questions:

   **Question 1 - Jira Ticket:**
   - question: "Is there a Jira ticket associated with this work?"
   - header: "Jira ticket"
   - multiSelect: false
   - options:
     - label: "No Jira ticket"
       description: "This work is not associated with a Jira ticket"
     - [Input field will be provided automatically for entering ticket number like PROJ-1234]

   **Question 2 - Git Diff Scope:**
   - question: "Which changes should be documented?"
   - header: "Changes"
   - multiSelect: false
   - options:
     - label: "Changes from [DEFAULT_BRANCH] branch"
       description: "All changes on this branch since it diverged from [DEFAULT_BRANCH]"
     - label: "Most recent commit"
       description: "Only the changes in the latest commit"
     - label: "Uncommitted changes"
       description: "Current uncommitted changes (not recommended)"
     - [Input field will be provided automatically for custom specification]

3. **Process the answers:**
   - Store the Jira ticket answer (either "No Jira ticket" or the ticket number provided)
   - Execute the appropriate git diff command based on the git diff scope answer:
     - Changes from default branch: `git diff [DEFAULT_BRANCH]...HEAD`
     - Most recent commit: `git diff HEAD~1 HEAD`
     - Uncommitted changes: `git diff HEAD`
     - Custom: Determine an appropriate git diff command based on the user's input

### Step 4: Gather Context

1. **Fetch Jira ticket details (if applicable):**
   - If a Jira ticket number was provided in Step 3:
     - Use the `workflow-tools:jira` agent to fetch ticket details: "Get details for Jira ticket [TICKET-NUMBER]"
     - Extract key information: summary, description, acceptance criteria, comments
     - Use this as additional context for understanding what was implemented and why

2. **Read provided documentation fully:**
   - If research documents provided: Read them FULLY (no limit/offset parameters)
   - If plan documents provided: Read them FULLY (no limit/offset parameters)
   - Extract key context about what was being implemented and why

### Step 5: Gather Git Metadata

1. **Collect frontmatter metadata using the agent:**
   - Use the `workflow-tools:frontmatter-generator` agent to collect metadata. Wait for the agent to return metadata before proceeding.
   - This provides: date/time, git commit hash, branch name, and repository info
   - Store this for use in frontmatter and throughout the document

2. **Collect comprehensive git metadata:**
   Run these commands to gather commit information:
   - Commit history for the range: `git log --oneline --no-decorate <range>`
   - Detailed commit info: `git log --format="%H%n%an%n%ae%n%aI%n%s%n%b" <range>`
   - Check if PR exists: `gh pr view --json number,url` (may not exist yet)
   - Get base commit: `git merge-base [DEFAULT_BRANCH] HEAD`
   - Jira ticket info (if provided earlier)

3. **Determine commit range context:**
   - Identify the base commit (where branch diverged)
   - Identify the head commit (current or latest, from frontmatter-generator)
   - Note the branch name (from frontmatter-generator)
   - Capture all commit hashes in the range (they may change on force-push, but provide context)

### Step 6: Analyze Changes

1. **Analyze the git diff:**
   - Understand what files changed
   - Identify the key changes and their purposes
   - Connect changes to the context from research/plan docs (if provided)
   - Focus on understanding WHY these changes accomplish the goals

### Step 7: Find GitHub Permalinks (if applicable)

1. **Obtain GitHub permalinks:**
   - Check if commits are pushed: `git branch -r --contains HEAD`
   - If pushed, or if on main branch:
     - Use repository info from frontmatter-generator (Step 5.1)
     - Get GitHub permalinks for all commits (i.e., `https://github.com/{owner}/{repo}/blob/{commit}`)

### Step 8: Generate Implementation Summary

1. **Prepare the document filename:**
   - Use the date from frontmatter-generator (Step 5.1) to extract YYYY-MM-DD for the filename
   - Create descriptive filename: `notes/YYYY-MM-DD_descriptive-name.md`

2. **Write the implementation summary using this strict template:**

````markdown
---
date: [Use date from frontmatter-generator (Step 5.1)]
git_commit: [Use git_commit from frontmatter-generator (Step 5.1)]
branch: [Use branch from frontmatter-generator (Step 5.1)]
repository: [Use repository from frontmatter-generator (Step 5.1)]
jira_ticket: "[TICKET-NUMBER]" # Optional - include if Jira ticket provided in Step 3
topic: "[Feature/Task Name]"
tags: [implementation, relevant-component-names]
last_updated: [Extract YYYY-MM-DD from frontmatter date field]
---

# [Feature/Task Name]

## Summary

[1-3 sentence high-level summary of what was accomplished]

## Overview

[High-level description of the changes, written for developers to quickly understand what was done and why. This should be readable in a few minutes. Minimal code citations and quotations - only include them if central to understanding the change. Focus on the business/technical goals and how they were achieved.]

## Technical Details

[Comprehensive explanation of the changes with focus on WHY. This is NOT just a recitation of what changed (that's available in the git commits). Instead, explain:

- What the purpose was behind the different changeds
- Why these specific changes were chosen to accomplish those goals
- Key design decisions and their rationale
- How different pieces fit together

For the most important changes, include code quotations to illustrate the implementation. For moderately important changes, include code references (file:line). Small changes like name changes should not be referenced at all.]

### [Component/Area 1]

[Explain what was changed in this component and why these changes accomplish the goals. Include code quotations for the most important changes. There should almost always be at least one code change quotation for each component/area:]

```[language]
// Most important code change
function criticalFunction() {
  // ...
}
```

[For moderately important changes, use code references like `path/to/file.ext:123`]

### [Component/Area 2]

[Similar structure...]

[Add additional sections as necessary for additional Components/Areas]

## Git References

**Branch**: `[branch-name]`

**Commit Range**: `[base-commit-hash]...[head-commit-hash]`

**Commits Documented**:

**[commit-hash]** ([date])
[Full commit message including body]
[If on main branch or commits are pushed, include GitHub permalink to files]

**[commit-hash]** ([date])
[Full commit message including body]

[Continue for all commits in the range...]

**Pull Request**: [#123](https://github.com/owner/repo/pull/123) _(if available)_
````

### Step 9: Finalize Document Quality

This step must be completed before presenting the document to the user.

#### 9.1: Check for External Review Configuration

Check if external review is configured:

```bash
echo "${CLAUDE_EXTERNAL_REVIEW_COMMAND:-NOT_SET}"
```

#### 9.2: Run External Review (if configured)

**If the variable shows `NOT_SET` or is empty:**
- Continue to Step 9.3
- No further action needed

**If external review IS configured:**

The environment variable contains one or more review commands separated by `: ` (colon-space).
Examples:
- Single: `opencode --model github-copilot/gpt-5 run`
- Multiple: `opencode --model github-copilot/gpt-5 run: opencode --model deepseek/deepseek-v3 run`

For each review command (process them sequentially):

1. **Extract the command** (split on `: ` delimiter if multiple)

2. **Run the external review:**
   Execute the command with this review prompt:
   ```bash
   ${COMMAND} "Review the implementation summary at [DOCUMENT_PATH] and provide detailed feedback on:

   1. Accuracy of the technical explanation - does it correctly explain what was implemented and why?
   2. Completeness - are there important changes that were omitted from the summary?
   3. Clarity - will another developer understand what was done and why from reading this?
   4. Missing context - are there important decisions, constraints, or rationale that should be documented?
   5. Factual errors - are there any incorrect statements about what the code does?
   6. Missing git references - are all relevant commits properly documented?

   Be specific about what's missing or incorrect. Focus on ensuring the summary accurately and completely documents the implementation work."
   ```

3. **Analyze feedback with extreme skepticism:**
   - Dismiss theoretical concerns or style suggestions
   - Ignore feedback that adds unnecessary complexity
   - Ignore feedback based on false assumptions
   - **Only identify feedback that reveals GENUINE gaps, errors, or missing CRITICAL information**
   - Most feedback should probably be dismissed

4. **Silently address ONLY critical issues:**
   - Fix any factual errors about what was implemented
   - Add only truly important missing information
   - Make minimal, focused updates
   - **Do NOT implement every suggestion**
   - Update the document file directly

5. **If multiple reviewers:** Each subsequent reviewer sees the updated document from the previous review

**Do NOT present reviews to the user** - this is an internal quality check.

#### 9.3: Document Ready for Presentation

The implementation summary has been written and quality-checked. Ready to present to user.

### Step 10: Present Summary to User

1. **Present the implementation summary:**

```
I've created the implementation summary at: `notes/YYYY-MM-DD_descriptive-name.md`
```

## Important Guidelines

1. **Document Standalone Nature**:

- The implementation summary is a standalone document
- Do NOT reference research or plan documents in the summary itself
- All necessary context should be incorporated into the summary
- Research/plan docs are only used as input to understand what to write

2. **Focus on WHY, Not WHAT**:

- The git diff shows WHAT changed
- The summary explains WHY those changes accomplish the goals
- Focus on intent, design decisions, and rationale
- Explain how the changes achieve the desired outcome

3. **Three-Level Structure is Mandatory**:

- **Summary**: Always exactly 1-3 sentences
- **Overview**: Always high-level, readable by any developer quickly
- **Technical Details**: Always comprehensive with WHY focus

4. **Git Metadata Must Be Complete**:

- Include all commit hashes in the range
- Include full commit messages (subject and body)
- Include dates and times
- Include branch name and commit range
- This metadata helps locate commits even after force-pushes

5. **Uncommitted Code Warning**:

- Always check for uncommitted code FIRST
- Only check for uncommitted CODE files, not documentation files
- Stop immediately if uncommitted code exists
- Advise committing before proceeding

6. **Read Documentation Fully**:

- Never use limit/offset when reading research or plan docs
- Read the entire document to understand full context
- Extract relevant information to inform the summary

7. **Jira Context**:

- Always check if a Jira ticket is mentioned or exists
- Use the `workflow-tools:jira` agent to fetch ticket details when available
- Include Jira ticket reference in the document header
- Use Jira information as context for understanding requirements and goals

8. **Dynamic Default Branch**:

- Always determine the default branch dynamically
- Never assume it's "main" - could be "master", "carbon_ubuntu", etc.
- Use the determined default branch for all git diff and merge-base commands

9. **Use Objective Language**

- Use objective technical language only.
- Avoid subjective quality judgments like 'clever', 'elegant', 'nice', 'beautiful', 'clean', 'simple', 'pragmatic', or similar terms that evaluate.
- Focus on facts and mechanisms, not value judgments.

## Success Criteria

The implementation summary is complete when:

- [ ] Jira ticket checked for and fetched (if applicable)
- [ ] Default branch determined dynamically
- [ ] Frontmatter metadata collected via frontmatter-generator agent (date, commit, branch, repository)
- [ ] All relevant research/plan documents have been read fully
- [ ] Git diff has been analyzed thoroughly
- [ ] All git metadata collected (commit history, messages, commit range, PR if available, Jira ticket)
- [ ] Document follows strict three-level template
- [ ] Summary section is 1-3 sentences
- [ ] Overview section is high-level and readable
- [ ] Technical Details explain WHY, not just WHAT
- [ ] Git References section includes all commits with full messages
- [ ] GitHub permalinks included (if applicable) using repository info from frontmatter-generator
- [ ] File saved to `notes/YYYY-MM-DD_descriptive-name.md`
- [ ] Document is standalone (no references to research/plan docs)
