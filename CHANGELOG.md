# Changelog

## v3.7.0 — 2026-05-07

### Added

- **Session audit** — Stop hook skriver `sessions/DRAFT.md` med git-data efter hvert svar. SessionStart-hook injicerer forrige sessions kontekst ved opstart. `/project:session-end` slash-kommando: Claude skriver narrativ opsummering, gemmer som `sessions/YYYY-MM-DD-HHMMSS.md`. `sessions/` er .gitignored.
- **`forge doctor`** — checker PHP 8.1+, composer, git, sqlite3, hooks, settings.json-format, CLAUDE.md, .env og database. Printer ✓/⚠/✗ pr. check. Exit code 1 ved fejl (CI-kompatibel).
- **Auto-update check** — stille check ved opstart maks én gang per dag. Printer en linje hvis ny version er tilgængelig. Fejler silently hvis offline.
- **Post-write test runner** — `post-write.sh` kører `composer test` (hvis scripts.test eksisterer) efter PHP lint på filer i `app/`. Fejl sendes som `additionalContext` til Claude.
- **`/project:new-page`** og **`/project:new-module`** — scaffold view-skeleton i `app/views/` + routing-linje / include-linje.
- **`forge design refresh`** — genafvikler DESIGN.md-valg i eksisterende projekt. Overskriver DESIGN.md efter bekræftelse.
- **`.env.example`** — genereres ved scaffold med alle standard Forge-variabler. `.env` tilføjes til `.gitignore`.
- **Agents version info** — `forge agents list` viser dato og antal. `forge agents update` printer diff (tilføjede/fjernede agents).
- **`VERSION`-fil** — `~/.local/share/forge/VERSION` indeholder semver-streng. `check_for_update()` bruger denne til sammenligning.
