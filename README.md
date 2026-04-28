# ViaVi Forge

Produktionsklar PHP/SQLite projektgenerator med Claude Code AI-agents — præ-konfigureret med reviewers, slash commands, rules og skills.

## Hurtig start

```bash
# 1. Installér Forge (kun første gang)
curl -fsSL https://raw.githubusercontent.com/viavidk/forge/main/install.sh | bash

# 2. Gå til den mappe hvor projektet skal oprettes
cd ~/projects   # eller fx /var/www/html

# 3. Kør Forge
forge
```

> **Tip:** Hvis terminalen siger `forge: command not found` skal `~/.local/bin` i din PATH.  
> Kør: `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc`

## Brug

```bash
forge                  # Hurtigt mode — 2 spørgsmål, ~30 sek
forge --guided         # Guided mode — 8 trin
forge --advanced       # Avanceret mode — alle valg
forge --help           # Vis hjælp
forge update           # Opdatér til seneste version
```

## Hvad Forge genererer

Et nyt projekt får:

- **PHP MVC-struktur** — controllers, services, models, views
- **SQLite** med WAL-mode og prepared statements
- **Login-system** — bcrypt, CSRF-tokens, session hardening
- **Claude Code AI-agents** — 8 parallelle reviewers (code, frontend, db, performance, security, data-integrity, browser-tester, mcp-health-check)
- **Slash commands** — `/project:review`, `/project:db-init`, `/project:deploy`, `/project:health` m.fl.
- **Rules** — code-style, database, API, javascript, testing, UX
- **MCP-servere** — ViaVi Skills, Context7, Chrome DevTools (valgfrit)
- **DESIGN.md** — valgfrit fra [awesome-design-md](https://github.com/VoltAgent/awesome-design-md)
- **Tailwind CSS** — valgfrit
- **Aceternity UI + Motion JS** — valgfrit (website/ecommerce-profil)

## Projektkrav

Kræver på udviklingsmaskinen:
- `bash` 4+, `git`, `curl` (til Forge selv)

Genererede projekter kræver:
- `php` 8.1+, `composer`, `git`

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
