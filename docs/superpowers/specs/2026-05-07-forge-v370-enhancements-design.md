# Forge v3.7.0 — Enhancement Spec

**Date:** 2026-05-07
**Status:** Draft — awaiting user review
**Scope:** Part A — Forge engine features (8 enhancements)
**Parts B + C** (markedsforing/ site + welcome.php) follow after Part A is implemented.

---

## Overview

Eight targeted improvements to the Forge engine addressing gaps in session continuity, project health visibility, developer productivity, and release management. All changes land in `~/.local/share/forge/` — nothing changes in the installer (`forge_3.5.0/`).

---

## Feature 1: Session Audit

### Goal
Claude remembers what happened in previous sessions without the user repeating context.

### Components

**`templates/hooks/stop.sh` (extended)**
After every Claude response, the Stop hook writes/overwrites `sessions/DRAFT.md` in the project root. Content:
- Timestamp of last Stop trigger
- Git diff summary: which files changed, categorised (auth/schema/feature/other)
- Count of changes since session start

The file is overwritten on each Stop trigger — always the current session's latest data snapshot. Note: stop.sh is a shell script and cannot access Claude's reasoning. The narrative is written by Claude at `/project:session-end`, using this file as a data scaffold.

**New SessionStart hook**
A new `templates/hooks/session-start.sh` reads the newest non-DRAFT file in `sessions/` (sorted by filename, descending) and injects a brief summary into Claude's context:
> "Last session (2026-05-06): Built login validation, fixed SQL race condition. Open: auth middleware."

Injected as `additionalContext` via the SessionStart hook mechanism.

**New slash command: `/project:session-end`**
When the user runs this, Claude:
1. Writes a narrative summary in natural Danish/English language
2. Saves it as `sessions/YYYY-MM-DD-HHMMSS.md`
3. Asks if the user wants to add a personal note (appended to the file)
4. Deletes `sessions/DRAFT.md`

**`.gitignore` entry**
`sessions/` is added to `.gitignore` during scaffold — personal dev log, not committed.

### Files changed
- `templates/hooks/stop.sh` — extended with session draft logic
- `templates/hooks/session-start.sh` — new
- `templates/commands/session-end.md` — new slash command
- `lib/17-hooks.sh` — registers SessionStart hook in settings.json
- `lib/99-finalize.sh` — adds `sessions/` to `.gitignore`, creates `sessions/` directory

---

## Feature 2: forge doctor

### Goal
One command that tells you whether the project environment is healthy.

### Behaviour
`forge doctor` runs from the project root. Prints a checklist with ✓ / ⚠ / ✗ per check:

| Check | Pass | Warning | Fail |
|-------|------|---------|------|
| PHP 8.1+ | version printed | — | not found |
| composer | version printed | — | not found |
| git | version printed | — | not found |
| sqlite3 | available | — | not found |
| Hooks | all 3 present + executable | missing one | all missing |
| settings.json | record format | — | array format (breaks Claude Code) |
| CLAUDE.md | present | — | missing |
| .env | present | missing (copy from .env.example) | — |
| database/app.sqlite | present | missing (run /project:db-init) | — |

Returns exit code 0 (all ok/warnings), 1 (any failures).

### Files changed
- `start-forge.sh` — new `doctor` subcommand branch

---

## Feature 3: Auto-update Check

### Goal
Users are informed when a newer Forge version is available without having to remember to check.

### Behaviour
- Runs silently at `forge` startup (scaffold, doctor, agents, design — all entry points)
- Compares local `VERSION` file against `raw.githubusercontent.com/viavidk/forge/main/VERSION`
- Rate-limited: only checks once per calendar day via `~/.local/share/forge/.update-checked` timestamp file
- Non-blocking: check runs, scaffold proceeds. If update available, one line prints after scaffold completes:
  ```
  ℹ  Forge v3.7.1 tilgængelig — kør 'forge update'
  ```
- Fails silently if offline or GitHub unreachable

### VERSION file
New file `~/.local/share/forge/VERSION` containing the current version string (e.g. `3.7.0`). Updated on every release. README and CHANGELOG are also updated as part of each release.

### Files changed
- `VERSION` — new file
- `start-forge.sh` — `check_for_update()` function called at entry
- `lib/_common.sh` — shared `get_local_version()` helper
- `README.md` — updated to document `VERSION` file and auto-update behaviour
- `CHANGELOG.md` — v3.7.0 entry added

---

## Feature 4: Post-write Test Runner

### Goal
Claude is immediately informed when a file change breaks tests, not just when it breaks PHP syntax.

### Behaviour
Extension to `templates/hooks/post-write.sh`:
1. PHP lint runs first (unchanged)
2. If lint passes AND `composer.json` has a `scripts.test` entry: run `composer test --no-interaction 2>&1`
3. If tests fail: output failure summary as `additionalContext` to Claude — same pattern as current lint errors
4. Only triggers on PHP files in `src/` (not assets, config, or views-only changes)

No change to projects without a `test` script in `composer.json`.

### Files changed
- `templates/hooks/post-write.sh` — extended with composer test check

---

## Feature 5: Slash Commands — new-page, new-module

### Goal
Reduce friction when adding a new page or module to an existing Forge project.

### `/project:new-page NAME`
1. Creates `src/views/NAME.php` with a minimal skeleton:
   - Extends layout template
   - Empty content block with a `<!-- TODO: NAME page content -->` marker
2. Prints the routing entry to add to the router (does not auto-edit the router — routing structures vary)

### `/project:new-module NAME`
Same as new-page — creates `src/views/NAME.php` skeleton. Claude scaffolds further content based on context.

Rationale for minimal approach: routing structures differ across Forge projects (URL rewriting on/off, subpath deployments). Printing the entry is safer than auto-editing.

### Files changed
- `templates/commands/new-page.md` — new
- `templates/commands/new-module.md` — new
- `lib/11-commands.sh` — copies new commands during scaffold

---

## Feature 6: DESIGN.md Refresh

### Goal
Allow changing design direction mid-project without re-scaffolding.

### Behaviour
`forge design refresh` re-runs module `06-design-md.sh` in the current directory. Same prompt flow as scaffold (choose source: awesome-design-md / ViaVi design system / skip). Overwrites existing `DESIGN.md`. Confirms before overwriting.

### Files changed
- `start-forge.sh` — new `design refresh` subcommand branch
- `lib/06-design-md.sh` — extract `run_design_md()` function callable standalone

---

## Feature 7: .env.example

### Goal
Every scaffolded project ships with a documented list of required environment variables.

### Content
```env
# ViaVi Forge — environment variables
# Copy to .env and fill in values. Never commit .env.

APP_NAME=my-app
APP_ENV=development        # development | production
APP_DEBUG=true             # false in production
DB_PATH=database/app.sqlite
SESSION_SECRET=change-me-to-a-random-string
```

Type-specific additions:
- `web-app` / `e-commerce`: `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`
- `api`: `API_KEY_SALT`

`CLAUDE.md` gets a one-line note: "Copy `.env.example` → `.env` and fill in values before running."

### Files changed
- `templates/partials/.env.example` — new (base variables)
- `lib/99-finalize.sh` — copies `.env.example`, adds `.env` to `.gitignore`
- `templates/partials/CLAUDE.md.base` — adds `.env` setup note

---

## Feature 8: Agents Version Info

### Goal
Transparency about when the agent cache was last updated and what changed.

### Behaviour

**`forge agents list`**
Header line added:
```
  Agent-cache: opdateret 2026-05-07  (kør 'forge agents update' for at hente seneste)
```

**`forge agents update`**
Before updating: reads current agent names. After updating: diffs against new names.
```
  Agents opdateret.
  + react-specialist (ny)
  - vue-developer (fjernet)
  = 47 uændrede
```

### Files changed
- `lib/16-awesome-agents.sh` — cache metadata stored alongside cache (`agents-cache-meta.json` with date + agent list)
- `start-forge.sh` — `agents list` reads metadata, `agents update` diffs before/after

---

## Release checklist

- [ ] `VERSION` file created with `3.7.0`
- [ ] `README.md` updated: new CLI commands, new features documented
- [ ] `CHANGELOG.md`: v3.7.0 entry with all 8 features
- [ ] All 8 features implemented and passing existing test suite
- [ ] New tests written for session audit, doctor, auto-update, agents diff
- [ ] `forge` run end-to-end in a clean directory — all modes
- [ ] `welcome.php` updates (Part B) planned separately after Part A is approved

---

## Out of scope (Part B + C)

- `markedsforing/` PHP marketing site updates
- `lib/99-finalize.sh` welcome.php updates

These are planned as a follow-on spec once Part A is implemented and tested.
