<?php

declare(strict_types=1);

namespace App\Models;

use PDO;
use PDOException;

class Database
{
    private static ?PDO $instance = null;

    public static function connect(): PDO
    {
        if (self::$instance !== null) {
            return self::$instance;
        }

        $path = DB_PATH;

        try {
            $pdo = new PDO('sqlite:' . $path);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

            // SQLite performance og integritet
            $pdo->exec('PRAGMA journal_mode=WAL');
            $pdo->exec('PRAGMA foreign_keys=ON');
            $pdo->exec('PRAGMA synchronous=NORMAL');

            self::$instance = $pdo;
            return $pdo;
        } catch (PDOException $e) {
            // Log fejl men eksponer aldrig detaljer til brugeren
            error_log('Database connection failed: ' . $e->getMessage());
            throw new \RuntimeException('Database unavailable');
        }
    }

    // Forhindre kloning og direkte instantiering
    private function __construct() {}
    private function __clone() {}
}
