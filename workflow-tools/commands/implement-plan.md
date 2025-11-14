# Implement Plan

You are tasked with implementing an approved technical plan from `working-notes/`. These plans contain phases with specific changes and success criteria.

## Getting Started

When given a plan path:

- Read the plan completely and check for any existing checkmarks (- [x])
- Read the original ticket and all files mentioned in the plan
- **Read files fully** - never use limit/offset parameters, you need complete context
- Think deeply about how the pieces fit together
- Create a todo list to track your progress
- Start implementing if you understand what needs to be done

If no plan path provided:

1. Find the 2 most recently edited plan documents:
   ```bash
   ls -t ~/.claude/working-notes/*.md 2>/dev/null | head -2
   ```

2. Extract just the filenames (without path) from the results

3. Use the AskUserQuestion tool to present them as options:
   - If 2+ plans found: Show the 2 most recent as options
   - If 1 plan found: Show that single plan as an option
   - If 0 plans found: Fall back to simple text prompt "What plan file do you want to implement?"

4. The question should be: "Which plan do you want to implement?"
   - Header: "Plan"
   - Options: The filenames only (e.g., "implement-auth.md")
   - Each option description should be the path from the current working directory (e.g., "working-notes/implement-auth.md")

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:

- Follow the plan's intent while adapting to what you find
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader codebase context
- Update checkboxes in the plan as you complete sections

When things don't match the plan exactly, think about why and communicate clearly. The plan is your guide, but your judgment matters too.

If you encounter a mismatch:

- STOP and think deeply about why the plan can't be followed
- Present the issue clearly:

  ```
  Issue in Phase [N]:
  Expected: [what the plan says]
  Found: [actual situation]
  Why this matters: [explanation]

  How should I proceed?
  ```

### Use Test-Driven Development

Write tests before doing implementation. Keep the tests focused on behavior not implementation. Describe the tests you intend to write to the user.

When writing tests follow this process:

1. Determine the scenarios you are going to test. These should roughly correspond to the individual tests you plan to write.
2. Get the user's approval for the scenarios you are testing so that we can course-correct early in the process.
3. Once you have obtained the user's approval, proceed to implement the tests.

## Verification Approach

After implementing a phase:

- Run the success criteria checks (often running all the tests will cover everything)
- Fix any issues before proceeding
- Update your progress in both the plan and your todos
- Check off completed items in the plan file itself using Edit

Don't let verification interrupt your flow - batch it at natural stopping points.

## If You Get Stuck

When something isn't working as expected:

- First, make sure you've read and understood all the relevant code
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance

Use sub-tasks sparingly - mainly for targeted debugging or exploring unfamiliar territory.

## Resuming Work

If the plan has existing checkmarks:

- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off

Remember: You're implementing a solution, not just checking boxes. Keep the end goal in mind and maintain forward momentum.

## Keep the Plan Documented Updated

As you make progress, update the plan document with what you have done. The plan document is a living document that should always be kept up-to-date.
