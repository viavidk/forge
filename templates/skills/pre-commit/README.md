# Skill: pre-commit

Triggered when the user signals readiness to commit with phrases like
"commit", "gem ændringer", "klar til commit", or "push".

Do NOT trigger on minor file saves or mid-feature work.

## Steps

1. **Run document skill first** — update PROJECT.md to reflect staged
   changes before review agents run. The commit will include current
   documentation.

2. **Announce** — output: "Kører pre-commit review inden commit..."

3. **Delegate quality loop to /project:review**
   - Let it run its full iteration loop (max 5 iterations)
   - If it reports "Quality gate not achievable automatically": STOP
     pre-commit. Do not commit. Report the persistent issues to the user.

4. **Commit-specific gates (on top of /project:review passing):**
   - .env is NOT in git staging area
     (run: `git diff --cached --name-only | grep -q '^\.env$' && echo FAIL`)
   - database/*.sqlite is NOT in git staging area
   - PROJECT.md HAS been updated since last module completed
     (check its mtime vs. the newest file in app/)

5. **If all gates pass:**
   - Output final score summary
   - Suggest a commit message based on staged changes:
     Format: `type(scope): beskrivelse`
     Types: feat, fix, refactor, style, docs, chore
   - Ask: "Skal jeg committe med denne besked, eller vil du ændre den?"
   - Wait for confirmation before running: git commit -m "..."

## What pre-commit does NOT do

- Does not orchestrate the review loop itself — that's /project:review
- Does not push to remote — that's an explicit user action after commit
