# /project:review

Run the BUILD → REVIEW → FIX loop until all dimensions score ≥ 8/10.
This command does not return control until the quality gate passes.

## Iteration limit

Maximum 5 iterations. If the gate is still not passed after 5 iterations,
STOP and output: "Quality gate not achievable automatically — manual
intervention needed on: [list the persistent findings]". Do not keep
looping indefinitely.

## Steps per iteration

1. Read all files in `/app`, `/public`, `/config`

2. **Spawn in parallel** (send all four as a single multi-agent call):
   - `code-reviewer`        — PHP quality, structure, PSR-12, MVC separation
   - `frontend-reviewer`    — Tailwind/DESIGN.md compliance, responsive design, accessibility, JS quality, REST API patterns
   - `db-reviewer`          — SQLite schema, prepared statements, N+1, WAL, indexes
   - `performance-reviewer` — PHP I/O, HTTP caching, output buffering, resources

   **Conditionally add:**
   - `data-integrity-auditor` — if `/app/services/` contains any file
     matching criteo|meta|ga4|google.ads|dv360|braze|talon (case-insensitive),
     spawn this agent too. It validates external API data handling.

3. Wait for all four to complete, then spawn:
   - `security-auditor` — uses code-reviewer output as input context

4. Merge all findings, deduplicate across agents

5. Output scored report:

   | Dimension       | Score | Issues                  |
   |-----------------|-------|-------------------------|
   | Code quality    | /10   | [Critical/Major/Minor]  |
   | Frontend        | /10   | [Critical/Major/Minor]  |
   | Database        | /10   | [Critical/Major/Minor]  |
   | Performance     | /10   | [Critical/Major/Minor]  |
   | Security        | /10   | [Critical/Major/Minor]  |

6. **Gate check — stop conditions:**
   - All 5 dimensions ≥ 8/10 AND zero CRITICAL findings → **STOP, loop complete**
   - Output: "Quality gate passed — all dimensions ≥ 8/10, no critical findings"

7. **Loop continuation — if gate not passed:**
   - Output: "Iteration [N] — gate not passed, running fix-issue..."
   - Run /project:fix-issue (without arguments = fix all findings by severity)
   - After fix-issue completes, return to step 1 for iteration [N+1]
   - Max 5 iterations total. After the 5th: STOP with manual intervention message.

## What "loop complete" means

Your work is not done when an iteration finishes. It is done when the gate
passes. Do not hand control back to the user until either:
(a) the gate passes, or
(b) 5 iterations have failed and you explain what is stuck.
