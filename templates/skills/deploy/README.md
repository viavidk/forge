# Skill: deploy

Triggered when the user requests production preparation with phrases like
"deploy", "klar til produktion", "push til server", "deployment checklist".

## Purpose

Make sure the codebase is genuinely production-ready — not just "it works
locally". Runs the full quality loop plus production-specific checks.

## Steps

1. **Quality gate** — run /project:review and wait for it to pass.
   - If the review loop exits with "manual intervention needed", STOP here
     and report. Do not proceed to deployment until the gate passes.

2. **Secrets audit** — verify:
   - `.env` is in `.gitignore` (run: `grep -q '^.env$' .gitignore`)
   - `.env` is NOT in git history (run: `git log --all --full-history -- .env`)
     If it has been committed at any point: CRITICAL — rotate all secrets
   - `database/*.sqlite` is in `.gitignore`
   - No hardcoded passwords/tokens in source (see security-auditor output)

3. **Production config check:**
   - APP_ENV=production in `.env.example` documentation
   - APP_DEBUG=false in production
   - session.cookie_secure=1 when APP_ENV=production (verify in config/app.php)
   - display_errors=0 in production

4. **Schema integrity:**
   - `database/schema.sql` loads cleanly in an empty database
   - All migrations applied locally are reflected in schema.sql
   - No ad-hoc schema changes that aren't in the file

5. **File permissions plan** — document in output:
   - `database/` must be writable by web server
   - `app/`, `config/`, `public/index.php` must NOT be writable by web server

6. **Output the deployment checklist** (as actual checkboxes the user can work through):
   - [ ] /project:review passed (all dimensions ≥ 8, no CRITICAL)
   - [ ] .env rotated if ever committed to git
   - [ ] APP_DEBUG=false in production .env
   - [ ] Admin password changed from default `Admin123!`
   - [ ] composer install run on server
   - [ ] vendor/ is gitignored and not deployed via git
   - [ ] Both .htaccess files in place (root + public/)
   - [ ] RewriteBase matches deployment subpath
   - [ ] SQLite file writable by web server user
   - [ ] HTTPS enforced on production domain
   - [ ] Backup strategy for database/app.sqlite documented

## When to block

If any step 1-4 fails: STOP deployment preparation. Do not output the
checklist until the failures are resolved. A broken build should never
reach production.
