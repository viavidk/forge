<?php

declare(strict_types=1);

// Indlæs .env hvis den findes
$envFile = ROOT . '/.env';
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#') || !str_contains($line, '=')) continue;
        [$key, $value] = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }
}

define('APP_ENV',   $_ENV['APP_ENV']   ?? 'production');
define('APP_DEBUG', ($_ENV['APP_DEBUG'] ?? 'false') === 'true');
$_dbPath = $_ENV['DB_PATH'] ?? 'database/app.sqlite';
define('DB_PATH', str_starts_with($_dbPath, '/') ? $_dbPath : ROOT . '/' . $_dbPath);
unset($_dbPath);

if (APP_DEBUG) {
    ini_set('display_errors', '1');
    error_reporting(E_ALL);
} else {
    ini_set('display_errors', '0');
    error_reporting(0);
}

// Session hardening
ini_set('session.cookie_httponly', '1');
ini_set('session.cookie_samesite', 'Lax');
ini_set('session.use_strict_mode', '1');
// Sæt session.cookie_secure=1 i produktion (HTTPS)
if (APP_ENV === 'production') {
    ini_set('session.cookie_secure', '1');
}
