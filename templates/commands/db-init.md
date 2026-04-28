# /project:db-init

Initialize or reset the SQLite database from schema.sql.

## Steps

1. Check that `database/schema.sql` exists
2. Run: `sqlite3 database/app.sqlite < database/schema.sql`
3. Verify tables were created: `sqlite3 database/app.sqlite ".tables"`
4. Confirm admin user exists in `users` table
5. Set file permissions if needed: `chmod 664 database/app.sqlite`
