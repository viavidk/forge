# /project:new-module

Opret et nyt modul (partial/komponent) i Forge-projektet.

## Brug

/project:new-module <NAVN>

Eksempel: `/project:new-module user-card`

## Steps

1. Bestem modulnavn fra $ARGUMENTS — brug lowercase, erstat mellemrum med bindestreg
2. Opret `src/views/<NAVN>.php`:

```php
<?php
// <NAVN> module
// Inkluder med: require __DIR__ . '/<NAVN>.php';
?>

<div class="<NAVN>">
  <!-- TODO: <NAVN> module content -->
</div>
```

3. Print include-linjen brugeren kan bruge i andre views:

```php
require __DIR__ . '/<NAVN>.php';
```
