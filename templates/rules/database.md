# Database conventions (SQLite)

- Enable WAL mode on every connection for better concurrent read performance:
  ```php
  $pdo->exec('PRAGMA journal_mode=WAL');
  $pdo->exec('PRAGMA foreign_keys=ON');
  ```
- All queries use PDO prepared statements — string interpolation in SQL is never acceptable
- Add indexes on every foreign key and every column used in WHERE or ORDER BY
- No N+1 queries — if you loop and query inside, refactor to a JOIN or IN() clause
- Schema changes go in `database/schema.sql` — never alter the DB ad hoc
- SQLite file must not be inside `public/` — keep in `database/` which is blocked by .htaccess
- SQLite file needs write permission for the web server user — document in deploy checklist
- Use transactions for multi-step writes:
  ```php
  $pdo->beginTransaction();
  // ... queries ...
  $pdo->commit();
  ```
