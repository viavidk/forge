# /project:new-page

Opret en ny side i Forge-projektet.

## Brug

/project:new-page <NAVN>

Eksempel: `/project:new-page about`

## Steps

1. Bestem sidenavn fra $ARGUMENTS — brug lowercase, erstat mellemrum med bindestreg
2. Opret `app/views/<NAVN>.php`:

```php
<?php
// <NAVN> view
$title = '<NAVN>';
?>
<?php require __DIR__ . '/partials/header.php'; ?>

<main class="container">
  <h1><?= htmlspecialchars($title) ?></h1>

  <!-- TODO: <NAVN> page content -->

</main>

<?php require __DIR__ . '/partials/footer.php'; ?>
```

3. Print routing-linjen brugeren skal tilføje i sin router:

```php
'<NAVN>' => 'app/views/<NAVN>.php',
```

4. Informer brugeren om at tilføje routing-linjen til router-filen (typisk `app/routes.php` eller `index.php`).
