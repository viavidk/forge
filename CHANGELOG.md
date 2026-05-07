# Changelog — ViaVi Forge

All notable changes to Forge are documented here. Newest entries first.

---

## v3.7.0 — 2026-05-07

### Added

- **Session audit** — Stop hook skriver `sessions/DRAFT.md` med git-data efter hvert svar. SessionStart-hook injicerer forrige sessions kontekst ved opstart. `/project:session-end` slash-kommando: Claude skriver narrativ opsummering, gemmer som `sessions/YYYY-MM-DD-HHMMSS.md`. `sessions/` er .gitignored.
- **`forge doctor`** — checker PHP 8.1+, composer, git, sqlite3, hooks, settings.json-format, CLAUDE.md, .env og database. Printer ✓/⚠/✗ pr. check. Exit code 1 ved fejl (CI-kompatibel).
- **Auto-update check** — stille check ved opstart maks én gang per dag. Printer en linje hvis ny version er tilgængelig. Fejler silently hvis offline.
- **Post-write test runner** — `post-write.sh` kører `composer test` (hvis scripts.test eksisterer) efter PHP lint. Fejl sendes som `additionalContext` til Claude.
- **`/project:new-page`** og **`/project:new-module`** — scaffold view-skeleton + routing-linje / include-linje.
- **`forge design refresh`** — genafvikler DESIGN.md-valg i eksisterende projekt. Overskriver DESIGN.md efter bekræftelse.
- **`.env.example`** — genereres ved scaffold med alle standard Forge-variabler. `.env` tilføjes til `.gitignore`.
- **Agents version info** — `forge agents list` viser dato og antal. `forge agents update` printer diff (tilføjede/fjernede agents).
- **`VERSION`-fil** — `~/.local/share/forge/VERSION` indeholder semver-streng. `check_for_update()` bruger denne til sammenligning.

---

## v3.6.6 — 2025-xx-xx

### Added

- `templates/hooks/post-write.sh` — PostToolUse(Write|Edit): PHP-lint + security/DB-tripwires → `additionalContext` til Claude
- `templates/hooks/pre-bash.sh` — PreToolUse(Bash): blokerer `git commit` ved PHP-syntaksfejl i staged files (`permissionDecision: deny`)
- `templates/hooks/stop.sh` — Stop: session-summary i terminalen med review-anbefalinger
- `lib/17-hooks.sh` — `install_hooks()` funktion + idempotent merge ind i `.claude/settings.json`
- `start-forge.sh` — `install_hooks` kaldt i build-sekvensen
- `welcome.php` — ny "Automatiske checks"-sektion med forklaring af de 3 hooks
- `markedsforing` — ny "Sker uden at du spørger"-sektion

---

## v3.6.5 — 2025-xx-xx

### Changed

- `prompt_agentic_discipline` er nu altid stille — fuld pakke installeres uden at spørge
- Guided mode: 9 trin → 8 trin (Trin 8 "Agentic disciplin" fjernet)
- `welcome.php`: 3-kolonners Kilde-grid erstattet af capability-pills (hvad Claude kan, ikke hvorfra)
- Første-prompt tekst: fjernet mention af "agent-orkestrering" — simpel og handlingsorienteret
- `markedsforing`: capability-fokuserede kort
- README: ASCII-diagram opdateret til capability-labels, ingen kilde-attributering

---

## v3.6.4 — 2025-xx-xx

### Changed

- `welcome.php` "Første prompt" omskrevet til at afspejle agent-orkestrering
- `pre-commit`-skill-beskrivelse: "Kører alle 5 agenter" → "alle relevante review-agenter"
- `data-integrity-auditor` fjernet fra Skills-sektion (det er en agent, ikke en skill)
- `ui-ux-pro-max`-skill nu conditional: vises kun hvis faktisk installeret
- `mcp-health-check` agent-row nu conditional på MCP-konfiguration
- `templates/partials/CLAUDE.md.base`: Agents-sektion delt i Forge stack + awesome curated med klar source-attribution
- `templates/commands/review.md`: `/project:review` opdateret med (Forge)/(awesome) source-tags
- Self-improvement triggers omskrevet med kilde pr. agent

---

## v3.6.3 — 2025-xx-xx

### Added

- **`forge agents cleanup`** + `--apply` migration-kommando
- **`warn_minimal_setup`** — advarsel ved Superpowers=N + agents=none
- **CLAUDE.md** ny `## Agent-orkestrering`-sektion med decision-tabel
- **welcome.php** 3-kolonners orchestration-grid (Workflow / Domain / Stack)

### Removed

- Forge's egne `code-reviewer.md`, `security-auditor.md`, `performance-reviewer.md` (overlap med awesome)

### Changed

- Ny baseline: awesome's `code-reviewer/security-auditor/performance-engineer` installeres altid ved `INSTALL_AGENTS=recommended`
- Forge's stack-specifikke 5 agents beholdt: `frontend-reviewer`, `db-reviewer`, `data-integrity-auditor`, `browser-tester`, `mcp-health-check`

---

## v3.6.2 — 2025-xx-xx

### Added

- Conditional Superpowers-sektion (5-trins kort) i welcome.php
- Conditional curated awesome-agents grid
- `forge agents` CLI-row i commands-sektionen

---

## v3.6.1 — 2025-xx-xx

### Fixed

- Korrekt `.claude/settings.json` med `enabledPlugins[]` + `extraKnownMarketplaces[]` (verificeret mod Claude Code's officielle spec via Context7)
- Hurtigt-mode regression: PROJECT_TYPE-fallback når `prompt_project_type` springes over
- Idempotent merge ind i eksisterende settings.json

---

## v3.6.0 — 2025-xx-xx

### Added (broken — brug v3.6.1+)

- Initial Superpowers integration (forkert plugin-format)
- `forge agents [list|search|update]` CLI
- 5 curated awesome-agents pr. projekttype
- Nyt Trin 8 i Guided mode

---

## v3.5.0 — 2025-xx-xx

### Added

- 3 modes: Hurtigt (~10 sek), Guided (8 trin), Avanceret (alle valg)
- 5 projekttyper med smart defaults
- 31 design-templates fra awesome-design-md
- Aceternity + Motion JS for websites
- ViaVi Skills + Context7 + Chrome DevTools MCP
- Cloudflare Tunnel via QR-kode
- Modulær `lib/`-arkitektur (16 nummererede moduler)
- PHP 8.1+ MVC-struktur, SQLite WAL-mode, login-system med brute-force-beskyttelse
