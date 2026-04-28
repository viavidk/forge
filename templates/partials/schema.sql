-- ViaVi Forge base schema
-- Kør: sqlite3 database/app.sqlite < database/schema.sql

CREATE TABLE IF NOT EXISTS users (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  email       TEXT    NOT NULL UNIQUE,
  password    TEXT    NOT NULL,
  role        TEXT    NOT NULL DEFAULT 'user',
  created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Seed: standardadmin (password: Admin123! — SKIFT inden produktion)
INSERT OR IGNORE INTO users (email, password, role)
VALUES (
  'admin@example.com',
  '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'admin'
);

CREATE TABLE IF NOT EXISTS api_logs (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  service      TEXT NOT NULL,
  method       TEXT NOT NULL,
  endpoint     TEXT NOT NULL,
  request      TEXT,
  response     TEXT,
  status_code  INTEGER,
  duration_ms  INTEGER,
  created_at   TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_api_logs_service    ON api_logs(service);
CREATE INDEX IF NOT EXISTS idx_api_logs_created_at ON api_logs(created_at);

-- Tilføj dine egne tabeller herunder:
