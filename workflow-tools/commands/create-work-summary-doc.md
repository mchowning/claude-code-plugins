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

### Step 3: Check for Jira Ticket Number

1. **Check if Jira ticket is mentioned:**
   - Review the user's response and any referenced documents
   - Look for Jira ticket numbers (e.g., ABC-1234, PROJ-567)
   - If a Jira ticket number is found, note it and move to the next step
   - If NO Jira reference is found, ask: "Is there a Jira ticket associated with this work? If so, please provide the ticket number."
   - Wait for the user's response
   - Note: Do not fetch the actual Jira ticket details now. We'll do that later in Step 5

### Step 4: Determine Default Branch and Select Git Diff

1. **Determine the default branch:**
   - Run: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
   - This will return the default branch name (e.g., "main", "master", "carbon_ubuntu")
   - Use this as the base branch for all subsequent git commands
   - Store this in a variable: `DEFAULT_BRANCH`

2. **Prompt user to select the git diff scope:**
   Use the AskUserQuestion tool to present these options:

   ```
   Which changes should be documented?
   ```

   Options:
   - **Changes from `[DEFAULT_BRANCH]` branch** - All changes on this branch since it diverged from `[DEFAULT_BRANCH]`
   - **Most recent commit** - Only the changes in the latest commit
   - **Uncommitted changes** - Current uncommitted changes (not recommended)
   - **[OTHER]** - User provides custom changes that should be considered

3. **Execute the appropriate git diff command:**
   - Diff from default branch: `git diff [DEFAULT_BRANCH]...HEAD`
   - Most recent commit: `git diff HEAD~1 HEAD`
   - Uncommitted: `git diff HEAD`
   - Custom: Determine an appropriate git diff command based on the user's request

### Step 5: Gather Context

1. **Fetch Jira ticket details (if applicable):**
   - If a Jira ticket number was identified in Step 3:
     - Use the `workflow-tools:jira-searcher` agent to fetch ticket details: "Get details for Jira ticket [TICKET-NUMBER]"
     - Extract key information: summary, description, acceptance criteria, comments
     - Use this as additional context for understanding what was implemented and why

2. **Read provided documentation fully:**
   - If research documents provided: Read them FULLY (no limit/offset parameters)
   - If plan documents provided: Read them FULLY (no limit/offset parameters)
   - Extract key context about what was being implemented and why

### Step 6: Gather Git Metadata

1. **Collect comprehensive git metadata:**
   Run these commands to gather commit information:
   - Current branch: `git branch --show-current`
   - Commit history for the range: `git log --oneline --no-decorate <range>`
   - Detailed commit info: `git log --format="%H%n%an%n%ae%n%aI%n%s%n%b" <range>`
   - Check if PR exists: `gh pr view --json number,url` (may not exist yet)
   - Get base commit: `git merge-base [DEFAULT_BRANCH] HEAD`
   - Repository info: `gh repo view --json owner,name`
   - Jira ticket info (if provided earlier)

2. **Determine commit range context:**
   - Identify the base commit (where branch diverged)
   - Identify the head commit (current or latest)
   - Note the branch name
   - Capture all commit hashes in the range (they may change on force-push, but provide context)

### Step 7: Analyze Changes

1. **Analyze the git diff:**
   - Understand what files changed
   - Identify the key changes and their purposes
   - Connect changes to the context from research/plan docs (if provided)
   - Focus on understanding WHY these changes accomplish the goals

### Step 8: Find GitHub Permalinks (if applicable)

1. **Obtain GitHub permalinks:**
   - Check if commits are pushed: `git branch -r --contains HEAD`
   - If pushed, or if on main branch:
     - Get repo info: `gh repo view --json owner,name`
     - Get GitHub permalinks for all commits (i.e., `https://github.com/{owner}/{repo}/blob/{commit}`)

### Step 9: Generate Implementation Summary

1. **Gather metadata for the document:**
   - Use the `workflow-tools:frontmatter-generator` agent to collect metadata. Wait for the agent to return metadata before proceeding.
   - Use `date '+%Y-%m-%d'` for the filename timestamp
   - Create descriptive filename: `notes/YYYY-MM-DD_descriptive-name.md`.

2. **Write the implementation summary using this strict template:**

````markdown
---
date: [Current date and time with timezone in ISO format]
git_commit: [Current commit hash]
branch: [Current branch name]
repository: [Repository name]
jira_ticket: "[TICKET-NUMBER]" # Optional - include if applicable
topic: "[Feature/Task Name]"
tags: [implementation, relevant-component-names]
last_updated: [Current date in YYYY-MM-DD format]
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
- Use the `workflow-tools:jira-searcher` agent to fetch ticket details when available
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
- [ ] All relevant research/plan documents have been read fully
- [ ] Git diff has been analyzed thoroughly
- [ ] All git metadata collected (commits, messages, branch, range, PR if available, Jira ticket)
- [ ] Document follows strict three-level template
- [ ] Summary section is 1-3 sentences
- [ ] Overview section is high-level and readable
- [ ] Technical Details explain WHY, not just WHAT
- [ ] Git References section includes all commits with full messages
- [ ] GitHub permalinks included (if applicable)
- [ ] Frontmatter generated via frontmatter-generator agent
- [ ] File saved to `notes/YYYY-MM-DD_descriptive-name.md`
- [ ] Document is standalone (no references to research/plan docs)
