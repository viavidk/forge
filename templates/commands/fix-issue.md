# /project:fix-issue

Fix issues from the most recent review. Called by /project:review when
any score is below 8 or any CRITICAL finding exists.

Target: $ARGUMENTS

## Steps

1. Load latest review findings from the merged report

2. **Select what to fix:**
   - If $ARGUMENTS is set: fix that specific issue
   - If not: fix in strict priority order
     - ALL Critical first (blocking)
     - Then Major
     - Then Minor (only if time permits within current iteration)

3. **Fix principles:**
   - Do not patch — improve the underlying design if needed
   - If the same issue recurs across iterations: refactor the entire module
   - If a fix would require changes >30 lines, prefer small incremental fixes
     over one big rewrite

4. **Validate each fix:**
   - Run `php -l` on changed PHP files — syntax must be valid
   - For DB changes: verify schema.sql still loads cleanly
   - For JS changes: verify no obvious syntax errors

5. **Return control to /project:review.**
   Do NOT re-run review on just "affected files" — the orchestrator
   (/project:review) is responsible for the next full iteration. Your
   job as fix-issue is done when all selected issues are fixed and
   validated.

## When to give up

If a single issue has resisted two consecutive fix attempts, stop and
output: "[issue] has failed 2 fix attempts — flagging for manual
review. Root cause appears to be: [your best analysis]"
