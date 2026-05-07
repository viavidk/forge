# /project:session-end

Afslut dagens arbejdssession og gem en narrativ opsummering.

## Steps

1. Læs `sessions/DRAFT.md` for git-data (hvilke filer, kategorier)
2. Gennemgå hvad der faktisk skete i denne session baseret på samtalen
3. Skriv en narrativ opsummering (3–8 sætninger) i naturligt sprog:
   - Hvad blev bygget, fikset eller refaktoreret
   - Vigtige tekniske beslutninger eller fund
   - Hvad der er åbent og mangler at gøre næste gang
4. Gem opsummeringen som `sessions/YYYY-MM-DD-HHMMSS.md`
   (brug faktisk tidsstempel, fx `sessions/2026-05-07-143022.md`)
5. Spørg: "Vil du tilføje en personlig note? (Enter for at springe over)"
6. Hvis brugeren skriver noget: append det til filen under overskriften `## Din note`
7. Slet `sessions/DRAFT.md` hvis den eksisterer
8. Print: "✓ Session gemt — sessions/YYYY-MM-DD-HHMMSS.md"
