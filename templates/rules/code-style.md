# Code style

- PHP 8.1+, declare(strict_types=1) in every file
- PSR-12: 4-space indent, no tabs
- Classes: PascalCase. Methods/variables: camelCase. Constants: UPPER_SNAKE_CASE
- One class per file, namespace matches directory structure
- No inline SQL — always use model layer
- No `die()`, `exit()`, or `var_dump()` in committed code
- Catch specific exceptions, never bare `catch (\Exception $e)` unless re-thrown
