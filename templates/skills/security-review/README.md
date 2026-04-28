# Skill: security-review

Triggered automatically after changes to authentication, session handling,
external API services, or any code that touches user input (forms, query
parameters, file uploads).

## Steps

1. Spawn `security-auditor` agent on the changed files

2. **Block conditions:**
   - Any CRITICAL finding → block progress, fix immediately, re-run
   - Security score < 8 → add all findings to fix queue before next feature

3. Re-run the auditor after fixes. Maximum 3 iterations — if score is
   still <8 after 3 attempts, escalate: output the persistent finding
   and request manual review. Do not loop indefinitely.

4. Once score ≥ 8 and no CRITICAL: return control to the calling context.

## What this skill does NOT do

- Does not run the full /project:review loop (that's a separate command)
- Does not commit or push — that's pre-commit skill
- Does not handle performance or code quality — only security
