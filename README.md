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

Et nyt projekt får PHP MVC-struktur, SQLite-database, login-system og 8 Claude Code AI-agents der reviewer kode, frontend, database, performance og sikkerhed automatisk.

## Krav

- `bash` 4+, `git`, `curl`
- Genererede projekter kræver: `php` 8.1+, `composer`, `git`

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
