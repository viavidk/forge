# /project:sanity-check

Run a full data integrity and presentation sanity check on the current
dashboard or report. Spawn data-integrity-auditor to execute.

## When to run
- Before sharing or deploying any dashboard or report
- After fetching fresh data from external APIs
- When a metric looks unexpected or inconsistent

## Steps

1. Identify all metrics currently displayed or prepared for display
2. For each metric, locate the raw source value in the database or API response
3. Verify mathematical consistency:
   - Rates: recalculate from raw numerator/denominator
   - Totals: sum segments and compare to reported total
   - Distributions: confirm percentages sum to ~100%
   - Currency: confirm all monetary values use the same currency
4. Verify business plausibility:
   - Flag conversion rates > 50%
   - Flag CTR > 30%
   - Flag spend = 0 on active campaigns
   - Flag any metric 10× above/below previous period without known cause
   - Flag any data for future dates
5. Return structured report with PASS / WARN / CRITICAL per metric
6. If any CRITICAL: block deployment and list what must be fixed
7. If only WARN: document assumptions and proceed with explicit sign-off

## Output

Return a report in this format:
```
SANITY CHECK — [dashboard/report name]
Date: [today]

CRITICAL  [metric]: [issue]
WARN      [metric]: [issue]
PASS      [metric]: verified

Status: PASS | BLOCKED
```
