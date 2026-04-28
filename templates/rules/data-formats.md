# Data formats

## TOON — brug dette til LLM-venlig struktureret data

TOON (Token-Oriented Object Notation) reducerer tokens med ~40% og øger LLM-præcision.
Brug `.toon`-filer og TOON-syntax i alle `.claude/`-filer, agent-output og intern dataudveksling.

### Syntaksregler

**Objekter** — ingen tuborgklammer, indentation definerer nesting (2 spaces):
```
name: Blue Lake
distance: 7.5
active: true
```

**Primitive arrays** — eksplicit længde, komma-separeret:
```
tags[3]: hiking,nature,trail
```

**Array af objekter (tabulær)** — felter defineres én gang, rækker indeholder kun værdier:
```
hikes[3]{id,name,distance}:
  1,Blue Lake,7.5
  2,Ridge View,9.2
  3,Eagle Peak,11.0
```

**Quoting** — kun når værdien indeholder kolon, komma, kontroltegn, eller ligner tal/boolean:
```
title: "Hello, World"
ratio: 3.14
```

**Nested objekt i array:**
```
users[2]:
  - name: Ana
    role: admin
  - name: Luis
    role: user
```

### Hvornår bruges TOON

| Kontekst | Format |
|----------|--------|
| `.claude/` regel-, agent-, command-filer | TOON for strukturerede eksempler |
| Agent-til-agent dataudveksling | TOON |
| API-svar der sendes til LLM | TOON |
| Intern logging til `api_logs` (tekstformat) | TOON |
| `settings.json`, `composer.json`, `tailwind.config.js` | JSON (kræves af værktøjer) |
| REST API responses til browserklienter | JSON (JavaScript parser det) |
| Database schema | SQL |

### Hvornår bruges JSON

- Svar til JavaScript-klienter via `fetch()` — browseren forventer JSON
- Konfigurationsfiler der parses af eksterne værktøjer
- Tredjeparts API-kald der kræver JSON body

### TOON i PHP (output til LLM-kontekster)

```php
// I stedet for json_encode() til LLM-output, brug TOON-format manuelt
// eller via et TOON-bibliotek når tilgængeligt for PHP
```

Mediatype: `application/x-toon` | Filextension: `.toon` | Encoding: UTF-8
