# /project:new-module

Scaffold a complete feature module from scratch.

Module name: $ARGUMENTS

## Steps

1. Plan: list all pages, routes, DB tables, and service methods needed.
   Output the plan and wait — do not proceed until confirmed.

2. Schema: add new tables to database/schema.sql with indexes and FK constraints.
   Run /project:db-init after.

3. Model: create app/models/{Name}.php
   - Static methods only: find(), findAll(), create(), update(), delete()
   - PDO prepared statements exclusively
   - WAL + FK already enabled by Database::connect()

4. Service: create app/services/{Name}Service.php
   - Business logic only — no SQL, no HTTP output
   - Stateless: no session or global state
   - External API calls: retry 3x, log to api_logs, throw typed exceptions

5. Controllers + Views: run /project:new-page for each page in the module

6. Run full /project:review across all new files
7. Fix all findings before marking module complete
8. **Update PROJECT.md comprehensively:**
   - Add module summary to "Hvad systemet gør" section
   - Add every new route to "Sider og routes"
   - Add every new table to "Databaseskema" with columns
   - Add every external API to "Eksterne integrationer"
   - Note key architecture decisions in "Arkitekturbeslutninger"
   - Update "Sidst opdateret" date
