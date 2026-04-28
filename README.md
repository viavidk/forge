# ViaVi Forge

Produktionsklar PHP/SQLite projektgenerator med Claude Code AI-agents — præ-konfigureret med reviewers, slash commands, rules og skills.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/viavi/forge/main/install.sh | bash
```

Kræver: `git`, `bash 4+`, `curl`

## Brug

```bash
forge                  # Hurtigt mode — 2 spørgsmål, ~10 sek
forge --guided         # Guided mode — 8 trin, ~1 min
forge --advanced       # Avanceret mode — alle valg, ~3 min
forge --help           # Vis hjælp
forge update           # Opdatér til seneste version
```

## Hvad Forge genererer

Et nyt projekt får:

- **PHP MVC-struktur** — controllers, services, models, views
- **SQLite** med WAL-mode og prepared statements
- **Claude Code AI-agents** — 8 parallelle reviewers (code, frontend, db, performance, security, data-integrity, browser-tester, mcp-health-check)
- **Slash commands** — `/project:review`, `/project:db-init`, `/project:deploy`, `/project:health` m.fl.
- **Rules** — code-style, database, API, javascript, testing, UX
- **MCP-servere** — ViaVi Skills, Context7, Chrome DevTools
- **DESIGN.md** — valgfrit fra [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (31 templates)
- **Tailwind CSS** — valgfrit
- **Aceternity UI + Motion** — valgfrit (website-profil)

## Projektkrav

Genererede projekter kræver:
- `php` 8.1+
- `composer`
- `git`

## ViaVi Skills (valgfrit)

ViaVi Skills er et gratis bibliotek af AI-skills til Claude Code.

Opret konto og hent token: [app.viavi.dk/skills](https://app.viavi.dk/skills)

Du kan altid springe dette over og bruge Forge fuldt ud uden en token.

## Opdatering

```bash
forge update
```

## Licens

MIT — se [LICENSE](LICENSE)
