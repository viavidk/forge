# Skill: document

Triggered automatically after a module is completed, and as step 0
in the pre-commit skill before any review agents run.

Do NOT trigger on minor edits, bug fixes, or mid-feature work.

## Purpose

Keep PROJECT.md accurate and current so any AI system — Claude Code,
Copilot, Cursor, or any other — can read it and immediately understand
what has been built, what decisions were made, and what is known to
be incomplete.

## Steps

1. Read PROJECT.md in full.

2. Read the following to understand what has actually been built:
   - All files in /app/controllers/
   - All files in /app/models/
   - All files in /app/services/
   - All files in /app/views/ (excluding errors/)
   - /database/schema.sql
   - /public/index.php (router section)

3. Update each section of PROJECT.md:

   **Hvad systemet gør**
   - If still placeholder: write a precise 2-3 sentence description
     based on what the code actually does. No marketing language.

   **Sider og routes**
   - Add a row for every route registered in public/index.php
   - Controller column: exact class name
   - Beskrivelse: what the page does in one sentence
   - Auth krævet: Ja/Nej based on whether the controller checks session

   **Databaseskema**
   - Reflect the actual tables in database/schema.sql
   - Nøglekolonner: list the most important columns only (not all)
   - Relationer: FK relationships

   **Eksterne integrationer**
   - List every external API used in /app/services/
   - For each: name, purpose, which endpoints are called

   **Arkitekturbeslutninger**
   - NEVER delete existing entries
   - Add new entries for significant decisions made during this module
   - Format: "- [Decision]: [Why it was made]"

   **Teknisk gæld**
   - NEVER delete existing entries
   - Add any known shortcuts, missing features, or future concerns
     discovered during this module
   - Remove an entry only if the debt has been explicitly resolved

4. Update "Sidst opdateret":
   - Format: [dato] · efter [modulnavn]

5. Write the updated PROJECT.md back.

6. Output a brief summary of what changed in PROJECT.md.

## Rules

- Only write what is actually in the code — never invent features
- Keep descriptions short and factual — one sentence per item
- Preserve all existing content unless it is factually wrong
- If unsure about a decision or integration, leave it as-is
