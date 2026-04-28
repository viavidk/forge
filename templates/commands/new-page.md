# /project:new-page

Create a new page following the project's MVC structure.

Page name: $ARGUMENTS

## Steps

1. Create app/controllers/{Name}Controller.php
   - Single public method: handle(array $params): void
   - Validate input, call service if needed, pass data to view
   - Always check authentication if page is protected

2. Create app/views/{name}.php
   - Follow DESIGN.md — correct section backgrounds, typography, components
   - Include CSRF meta tag if page has any forms:
     <meta name="csrf-token" content="<?= $_SESSION['csrf_token'] ?>">
   - Mobile-first layout

3. Registrér route i app/routes.php (ALDRIG i public/index.php)

**Special case — forside/startside (route `/`):**
- View skal hedde `app/views/index.php` — routeren loader den automatisk uden at du registrerer en route
- Opret IKKE en ekstra case '' i switch — det håndteres allerede af bootstrap
- Controller placeres som normalt: app/controllers/HomeController.php (eller tilsvarende)

4. Spawn frontend-reviewer on the new view file only
5. Fix any findings before marking done
6. **Update PROJECT.md** — add row to "Sider og routes" table with:
   - Route, view path, controller class, auth requirement, 1-sentence description
   - Update "Sidst opdateret" date at bottom
