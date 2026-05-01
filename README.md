# ViaVi Forge v3.6.4

> **Et generator-værktøj der scaffolder produktionsklare PHP/SQLite-projekter med Claude Code AI-agents — orkestreret, præ-konfigureret og klar fra første prompt.**

```
                    ╔═════════════════════════╗
                    ║    ViaVi Forge v3.6.3   ║
                    ║   PHP · SQLite · Claude ║
                    ╚═════════════════════════╝

         Workflow            Domain             Stack
        Superpowers          Awesome             Forge
        ───────────         ─────────          ─────────
         brainstorm        code-reviewer    frontend-reviewer
         writing-plans     security-auditor    db-reviewer
         executing-plans   performance-eng     data-integrity
         debugging         a11y-tester         browser-tester
         red-green-refac   php-pro             mcp-health-check
         (subagents)       sql-pro / m.fl.

              ↓                  ↓                  ↓
            Disciplin       Bredde-viden      Stack-validering
```

Tre komplementære agent-systemer. Ingen dubletter. Ingen modarbejdelse. Hver kilde ejer sit domæne — det er Forge v3.6.3's orkestrerings-filosofi.

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
forge --guided                   # Guided mode — 9 trin, ~1 min
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
- **Agent-orkestrering** — Superpowers + curated awesome + Forge stack

---

## Agent-orkestrering (v3.6.3)

I tidligere versioner var der overlap mellem Forge's egne agents, awesome-agents og Superpowers — fx 3 forskellige `code-reviewer`. v3.6.3 retter dette ved at gøre **hver kilde ansvarlig for sit eget domæne**.

### Workflow-disciplin · Superpowers

> *Tvinger Claude igennem Clarify → Design → Plan → Code → Verify før kode skrives.*

| Skill / agent | Hvornår |
|---|---|
| `brainstorming` | Før et nyt modul, design, feature |
| `writing-plans` | Når implementering kræver flere skridt |
| `executing-plans` | Mens planen følges, med checkpoints |
| `systematic-debugging` | Bug-jagt med 4-fase root-cause-analysis |
| `red-green-refactor` | TDD-disciplin |
| `code-reviewer` (subagent) | Auto efter implementation, validerer mod planen |

Auto-aktiveres ved `claude`-start. Plugin'et installeres fra `obra/superpowers-marketplace` via `.claude/settings.json`.

### Domain-ekspertise · Curated awesome-agents

> *Generelle, sprog-/stack-uafhængige domain-eksperter. Kaldes via `Task` tool.*

| Agent | Brug når |
|---|---|
| `code-reviewer` | Generel code review (uden Superpowers-flow) |
| `security-auditor` | OWASP-audit, auth, secrets, CSRF/XSS |
| `performance-engineer` | Web Vitals, bundle size, caching |
| `accessibility-tester` | WCAG 2.1, keyboard-nav, screen reader |
| `php-pro` / `sql-pro` | Sprog-idiomatik på tværs af projekter |
| `frontend-developer` / `api-designer` / `qa-expert` | Andre domæner |

Hentet fra [`VoltAgent/awesome-claude-code-subagents`](https://github.com/VoltAgent/awesome-claude-code-subagents) (100+ agents). Curated liste pr. projekttype. Cache i `~/.local/share/forge/awesome-claude-code-subagents`.

### Stack-specifik validering · Forge agents

> *PHP/SQLite/Tailwind-CDN/MCP-konventioner — Forge-domænet.*

| Agent | Hvad den ved | Generel awesome ville mangle |
|---|---|---|
| `frontend-reviewer` | Tailwind via CDN + PHP-partials, DESIGN.md-compliance | Ja |
| `db-reviewer` | SQLite WAL-mode, FK-constraints, prepared statements | Ja (sql-pro er generisk) |
| `data-integrity-auditor` | Forge's schema, valuta/tidszoner ved API-data | Ja (Forge-specifikt) |
| `browser-tester` | Chrome DevTools MCP integration | Ja (Forge MCP-config) |
| `mcp-health-check` | Verifier Forge's MCP-config | Ja (Forge-specifikt) |

### Beslutningstabel — hvilken agent når?

| Situation | Brug |
|---|---|
| "Review denne PR" / "tjek koden" | Superpowers `code-reviewer` (auto efter plan) |
| Ad-hoc code review uden Superpowers | awesome `code-reviewer` |
| "Audit for sikkerhed" | awesome `security-auditor` |
| "Optimér performance" / Web Vitals | awesome `performance-engineer` |
| "Lav accessibility-audit" | awesome `accessibility-tester` |
| "Tjek SQLite-skemaet" / WAL-mode | Forge `db-reviewer` |
| "Verificer Tailwind + PHP partials" | Forge `frontend-reviewer` |
| "Test i browseren" / E2E | Forge `browser-tester` |
| "Tjek MCP-helbred" | Forge `mcp-health-check` |
| "Er PHP-koden idiomatic?" | awesome `php-pro` |
| "Optimér denne SQL-query" | awesome `sql-pro` |
| Brainstorming før nyt modul | Superpowers `brainstorming` |
| Plan-skabelse | Superpowers `writing-plans` |
| Debugging | Superpowers `systematic-debugging` |

---

## Smart defaults pr. projekttype

| Type | Profile | Tunnel | Tailwind | Animationer | Superpowers | Curated agents |
|---|---|---|---|---|---|---|
| 1 · Dashboard | intern | nej | ja | ingen | **ja** | ja (a11y, php, sql) |
| 2 · Internt værktøj | intern | nej | ja | ingen | **ja** | ja (a11y, qa, php) |
| 3 · Website | website | **ja** | ja | full | **ja** | ja (frontend, a11y, js, php) |
| 4 · E-commerce | website | **ja** | ja | full | **ja** | ja (frontend, php, sql) |
| 5 · API/Backend | backend | nej | nej | ingen | nej | ja (api-designer, php, sql) |

Smart defaults kan altid overstyres i Guided/Avanceret mode. Hurtigt mode bruger dem direkte.

---

## Modes

### Hurtigt (~10 sekunder)
2 spørgsmål: projektnavn + projekttype. Smart defaults sætter alt andet. Perfekt til prototyping.

### Guided (~1 minut, 9 trin)
1. Projektnavn
2. Projekttype (5 valg)
3. Lokal port
4. Apache routing + URL-sti
5. Cloudflare Tunnel (ja/nej)
6. DESIGN.md-kilde (4 valg) + Aceternity for websites
7. MCP-servere (ViaVi Skills, Context7, Chrome DevTools)
8. **Agentic disciplin** — Fuld pakke / Kun Superpowers / Kun curated agents / Ingen ekstras
9. Konflikt-validering + scaffolding

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

## Test-coverage (v3.6.3)

```
Unit-tests (tests/scenarios/):    23/23 ✓
Original shadow (5×4 matrix):    101/101 ✓
Orchestration shadow (v3.6.3):   180/180 ✓
End-to-end (start-forge.sh):      19/19 ✓
                                ─────────
                                323/323 ✓
```

Inklusiv: PHP-syntax-validering på genereret welcome.php, idempotens-test for settings.json-merge, migration-test for `forge agents cleanup`, dublet-detektion på tværs af alle 20 type/disciplin-kombinationer.

---

## Licens

MIT — se [LICENSE](LICENSE).

Forge er bygget af Jimmi Frederiksen ([viavi.dk](https://viavi.dk/)). Superpowers af Jesse Vincent ([obra/superpowers](https://github.com/obra/superpowers)). Awesome agents af [VoltAgent](https://github.com/VoltAgent/awesome-claude-code-subagents). Alle MIT.
