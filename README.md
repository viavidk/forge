# ViaVi Forge v3.6.5

> **Et generator-værktøj der scaffolder produktionsklare PHP/SQLite-projekter med Claude Code AI-agents — præ-konfigureret og klar fra første prompt.**

```
                    ╔═════════════════════════╗
                    ║    ViaVi Forge v3.6.5   ║
                    ║   PHP · SQLite · Claude ║
                    ╚═════════════════════════╝

      Workflow-disciplin   Kvalitetssikring   Stack-validering
      ──────────────────   ────────────────   ────────────────
        brainstorming       security-audit    frontend-reviewer
        writing-plans       performance       db-reviewer
        executing-plans     accessibility     data-integrity
        debugging           code-review       browser-tester
        red-green-refac     php-pro / sql     mcp-health-check

              ↓                  ↓                  ↓
           Clarify→          Second              PHP/SQLite
           Plan→Code         opinion             conventions
```

Komplet AI-workflow installeret automatisk. Skriv hvad du vil bygge — Claude bruger de rigtige capabilities uden at du skal vælge eller koordinere.

---

## Hurtig start

```bash
# 1. Installér Forge (kun første gang)
curl -fsSL https://raw.githubusercontent.com/viavidk/forge/main/install.sh | bash

# 2. Gå til den mappe hvor projektet skal oprettes
cd ~/projects

# 3. Kør Forge
forge
```

Hvis `forge: command not found` — føj `~/.local/bin` til din PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

---

## Kommandoer

```bash
forge                            # Hurtigt mode — 2 spørgsmål, ~10 sek
forge --guided                   # Guided mode — 8 trin, ~1 min
forge --advanced                 # Avanceret mode — alle valg, ~3 min
forge update                     # Hent seneste version fra GitHub
forge --help                     # Vis hjælp

forge agents list                # List awesome-agents kategorier
forge agents search <ord>        # Find en specifik agent
forge agents update              # Opdatér agent-cache
forge agents cleanup             # (v3.6.3) Detektér v3.6.2-dubletter
forge agents cleanup --apply     # Slet Forge's gamle dublerede agents
```

---

## Hvad Forge genererer

Et nyt projekt får:

- **PHP 8.1+ MVC-struktur** uden framework — fuld kontrol, ingen afhængigheder
- **SQLite-database** med WAL-mode, prepared statements og admin-bruger pre-seeded
- **Login-system** med session-flags og brute-force-beskyttelse
- **Tailwind CSS** via Play CDN (eller med build, valgfrit)
- **Aceternity-mønstre + Motion JS** for premium-animations (kun website-typer)
- **DESIGN.md** — 31 templates fra `awesome-design-md` eller ViaVi design-system
- **Cloudflare Tunnel** — instant ekstern URL via QR-kode (valgfrit)
- **MCP-servere** — ViaVi Skills, Context7, Chrome DevTools (valgfrit)
- **Komplet AI-workflow** — workflow-disciplin, code-review, security-audit og stack-validering installeres automatisk

---

## AI-capabilities (v3.6.5)

Capabilities installeres automatisk — ingen konfiguration nødvendig.

### Workflow-disciplin

Clarify → Design → Plan → Code → Verify. Tvinger en struktureret tilgang før kode skrives. Auto-aktiveres via `.claude/settings.json` (Superpowers plugin fra `obra/superpowers-marketplace`).

Inkluderer: `brainstorming`, `writing-plans`, `executing-plans`, `systematic-debugging`, `red-green-refactor`, `code-reviewer` (auto-subagent).

### Kvalitetssikring

Generelle eksperter der kendes god kode på tværs af sprog og frameworks.

Inkluderer: `security-auditor`, `performance-engineer`, `accessibility-tester`, `php-pro`, `sql-pro` + type-specifikke. Fra [`VoltAgent/awesome-claude-code-subagents`](https://github.com/VoltAgent/awesome-claude-code-subagents).

### Stack-validering

PHP/SQLite-specifik validering med kendskab til Tailwind CDN-patterns, WAL-mode og Forge-konventioner.

Inkluderer: `frontend-reviewer`, `db-reviewer`, `data-integrity-auditor`, `browser-tester` (Chrome MCP), `mcp-health-check`.

---

## Smart defaults pr. projekttype

| Type | Profile | Tunnel | Tailwind | Animationer | Curated agents |
|---|---|---|---|---|---|
| 1 · Dashboard | intern | nej | ja | ingen | a11y, php, sql |
| 2 · Internt værktøj | intern | nej | ja | ingen | a11y, qa, php |
| 3 · Website | website | **ja** | ja | full | frontend, a11y, js, php |
| 4 · E-commerce | website | **ja** | ja | full | frontend, php, sql |
| 5 · API/Backend | backend | nej | nej | ingen | api-designer, php, sql |

Superpowers + Forge stack-agents installeres altid (alle typer). Smart defaults kan overstyres i Avanceret mode. Hurtigt mode bruger dem direkte.

---

## Modes

### Hurtigt (~10 sekunder)
2 spørgsmål: projektnavn + projekttype. Smart defaults sætter alt andet. Perfekt til prototyping.

### Guided (~1 minut, 8 trin)
1. Projektnavn
2. Projekttype (5 valg)
3. Lokal port
4. Apache routing + URL-sti
5. Cloudflare Tunnel (ja/nej)
6. DESIGN.md-kilde (4 valg) + Aceternity for websites
7. MCP-servere (ViaVi Skills, Context7, Chrome DevTools)
8. Konflikt-validering + scaffolding

### Avanceret (~3 minutter)
Alle valg manuelt — også ui-ux-pro-max design skill, Tailwind toggle, Aceternity for ikke-websites og pr.-kategori agent-browse.

---

## Krav

- **Forge selv:** `bash 4+`, `git`, `curl`
- **Genererede projekter:** `php 8.1+`, `composer`, `git`
- **Valgfrit:** `cloudflared` (tunnel), `npm` (uipro-cli, ui-ux-pro-max)

---

## ViaVi Skills (valgfrit)

Gratis bibliotek af Elkjøp Nordic-specifikke AI-skills til Claude Code. Hentes via MCP når token er sat.

Opret konto og hent token: [app.viavi.dk/skills](https://app.viavi.dk/skills)

Forge fungerer fuldt ud uden token — skip prompten i Trin 7.

---

## Migration fra v3.6.2 og tidligere

v3.6.3 sletter `code-reviewer.md`, `security-auditor.md` og `performance-reviewer.md` fra `templates/agents/` — de er nu erstattet af awesome-versionerne, som er mere generiske og uden PHP-stack-bias.

For eksisterende projekter kør:

```bash
cd din-app
forge agents cleanup           # Dry-run: detektér Forge's gamle agents
forge agents cleanup --apply   # Slet dem (med y/N-bekræftelse)
```

Cleanup detekterer kun Forge-versionerne (via PHP-stack-signatur i description) — bruger-custom agents og awesome-agents bevares.

---

## Changelog

### v3.6.6 — Automatiske hooks ✓

- `templates/hooks/post-write.sh` — PostToolUse(Write|Edit): PHP-lint + security/DB-tripwires → `additionalContext` til Claude
- `templates/hooks/pre-bash.sh` — PreToolUse(Bash): blokerer `git commit` ved PHP-syntaksfejl i staged files (`permissionDecision: deny`)
- `templates/hooks/stop.sh` — Stop: session-summary i terminalen med review-anbefalinger
- `lib/17-hooks.sh` — `install_hooks()` funktion + idempotent merge ind i `.claude/settings.json`
- `start-forge.sh` — `install_hooks` kaldt i build-sekvensen
- `welcome.php` — ny "Automatiske checks"-sektion med forklaring af de 3 hooks
- `markedsforing` — ny "Sker uden at du spørger"-sektion

### v3.6.5 — Usynlig orkestrering ✓

- `prompt_agentic_discipline` er nu altid stille — fuld pakke installeres uden at spørge
- Guided mode: 9 trin → 8 trin (Trin 8 "Agentic disciplin" fjernet)
- `welcome.php`: 3-kolonners Kilde-grid erstattet af capability-pills (hvad Claude kan, ikke hvorfra)
- Første-prompt tekst: fjernet mention af "agent-orkestrering" — simpel og handlingsorienteret
- `markedsforing`: "Tre kilder. Ingen dubletter." → "Claude kender din stack" med capability-fokuserede kort
- README: ASCII-diagram opdateret til capability-labels, ingen kilde-attributering

### v3.6.4 — Welcome-page polish + template-sweep ✓

- `welcome.php` "Første prompt" omskrevet til at afspejle agent-orkestrering (ikke "fulde review-loop")
- `pre-commit`-skill-beskrivelse: "Kører alle 5 agenter" → "alle relevante review-agenter (Forge stack + awesome curated)"
- `data-integrity-auditor` fjernet fra Skills-sektion (det er en agent, ikke en skill)
- `ui-ux-pro-max`-skill nu conditional: vises kun hvis faktisk installeret
- `mcp-health-check` agent-row nu conditional på MCP-konfiguration (matcher hvad der reelt installeres)
- `templates/partials/CLAUDE.md.base`: Agents-sektion delt i Forge stack + awesome curated, med klar source-attribution
- `templates/commands/review.md`: `/project:review` opdateret med (Forge) / (awesome) source-tags
- Self-improvement triggers omskrevet med kilde pr. agent + note om Superpowers-flow

### v3.6.3 — Agent-orkestrering ✓

- **Slettet** Forge's `code-reviewer.md`, `security-auditor.md`, `performance-reviewer.md` (overlap med awesome)
- **Beholdt** Forge's stack-specifikke 5: `frontend-reviewer`, `db-reviewer`, `data-integrity-auditor`, `browser-tester`, `mcp-health-check`
- **Ny baseline** — awesome's `code-reviewer/security-auditor/performance-engineer` installeres altid ved `INSTALL_AGENTS=recommended`
- **CLAUDE.md** får ny `## Agent-orkestrering`-sektion med decision-tabel
- **welcome.php** får 3-kolonners orchestration-grid (Workflow / Domain / Stack)
- **`forge agents cleanup`** + `--apply` migration-kommando
- **`warn_minimal_setup`** — advarsel ved Superpowers=N + agents=none

### v3.6.2 — welcome.php afspejler v3.6.x ✓
- Conditional Superpowers-sektion (5-trins kort) i welcome.php
- Conditional curated awesome-agents grid
- `forge agents` CLI-row i commands-sektionen

### v3.6.1 — Fix plugin-format ✓
- Korrekt `.claude/settings.json` med `enabledPlugins[]` + `extraKnownMarketplaces[]` (verificeret mod Claude Code's officielle spec via Context7)
- Hurtigt-mode regression: PROJECT_TYPE-fallback når `prompt_project_type` springes over
- Idempotent merge ind i eksisterende settings.json

### v3.6.0 — Superpowers + awesome-agents (broken) ⚠️
- Initial Superpowers integration (forkert plugin-format — brug v3.6.1+)
- `forge agents [list|search|update]` CLI
- 5 curated awesome-agents pr. projekttype
- Nyt Trin 8 i Guided mode

### v3.5.0 — Modulær PHP/SQLite-scaffold ✓
- 3 modes (Hurtigt/Guided/Avanceret)
- 5 projekttyper med smart defaults
- 31 design-templates fra awesome-design-md
- Aceternity + Motion JS for websites
- ViaVi Skills + Context7 + Chrome DevTools MCP
- Cloudflare Tunnel
- Modulær `lib/`-arkitektur (16 nummererede moduler)

---

## Test-coverage (v3.6.5)

```
Unit-tests (tests/scenarios/):    23/23 ✓
Original shadow (5×4 matrix):    101/101 ✓
Orchestration shadow:            180/180 ✓
End-to-end (start-forge.sh):      19/19 ✓
                                ─────────
                                323/323 ✓
```

Inklusiv: PHP-syntax-validering på genereret welcome.php, idempotens-test for settings.json-merge, migration-test for `forge agents cleanup`, dublet-detektion på tværs af alle 20 type/disciplin-kombinationer.

---

## Licens

MIT — se [LICENSE](LICENSE).

Forge er bygget af Jimmi Frederiksen ([viavi.dk](https://viavi.dk/)). Superpowers af Jesse Vincent ([obra/superpowers](https://github.com/obra/superpowers)). Awesome agents af [VoltAgent](https://github.com/VoltAgent/awesome-claude-code-subagents). Alle MIT.
