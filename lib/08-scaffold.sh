#!/bin/bash
# lib/08-scaffold.sh — projektstruktur, git, .gitignore, startfiler

scaffold_project_structure() {
  if [ "$UPGRADE" = "false" ]; then
    start_spinner "Opretter projektstruktur..."
    mkdir -p "$PROJECT"/{app/{controllers,services,models,views/errors,views/partials},public/assets/{css,js},config,database}
  fi
  mkdir -p "$PROJECT/.claude"/{commands,rules,agents,skills/{security-review,deploy,pre-commit,document}}

  if [ "$UPGRADE" = "false" ]; then
    touch "$PROJECT/app/controllers/.gitkeep"
    touch "$PROJECT/app/services/.gitkeep"
    touch "$PROJECT/app/views/.gitkeep"
    touch "$PROJECT/app/models/.gitkeep"

    if [ ! -d "$PROJECT/.git" ]; then
      git -C "$PROJECT" init -q
    fi
    if [ ! -f "$PROJECT/.gitignore" ]; then
      cat > "$PROJECT/.gitignore" << 'EOF'
CLAUDE.local.md
.claude/settings.local.json
database/*.sqlite
.env
vendor/
node_modules/
.venv/
public/.tunnel-url
EOF
    fi
    stop_spinner "Projektstruktur oprettet"
  fi
}

scaffold_project_files() {
  PORT="${PORT:-8080}"
  USE_TUNNEL="${USE_TUNNEL:-N}"
  USE_ROUTER="${USE_ROUTER:-Y}"

  if [ "$UPGRADE" = "false" ]; then
    start_spinner "Genererer projektfiler..."
  fi

  # start.sh
  if [ ! -f "$PROJECT/start.sh" ]; then
    if [ "$USE_TUNNEL" = "Y" ]; then
      cat > "$PROJECT/start.sh" << STARTSH
#!/bin/bash
# Start $PROJECT lokalt med Cloudflare Tunnel
APP_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
PORT=$PORT

if ! command -v php &>/dev/null; then echo "Fejl: php ikke fundet i PATH"; exit 1; fi

if ! command -v cloudflared &>/dev/null; then
  echo "Fejl: cloudflared ikke fundet. Starter lokalt på http://localhost:\$PORT"
  cd "\$APP_DIR"
  $([ "$USE_ROUTER" = "Y" ] && echo 'php -S "127.0.0.1:$PORT" -t public/ public/router.php' || echo 'php -S "127.0.0.1:$PORT" -t public/')
  exit 0
fi

if command -v lsof &>/dev/null; then
  EXISTING=\$(lsof -ti :\$PORT 2>/dev/null)
elif command -v fuser &>/dev/null; then
  EXISTING=\$(fuser \$PORT/tcp 2>/dev/null)
fi
[ -n "\$EXISTING" ] && kill \$EXISTING 2>/dev/null && sleep 0.5

TUNNEL_LOG="\$(mktemp /tmp/$PROJECT-tunnel-XXXX.log)"
PHP_PID=""; TUNNEL_PID=""
cleanup() {
  [ -n "\$PHP_PID" ]    && kill "\$PHP_PID"    2>/dev/null
  [ -n "\$TUNNEL_PID" ] && kill "\$TUNNEL_PID" 2>/dev/null
  rm -f "\$TUNNEL_LOG" "\$APP_DIR/public/.tunnel-url"
  printf "\nServer og tunnel stoppet.\n"
}
trap cleanup EXIT INT TERM

cloudflared tunnel --config /dev/null --url "http://127.0.0.1:\$PORT" --no-autoupdate > "\$TUNNEL_LOG" 2>&1 &
TUNNEL_PID=\$!

printf "Starter Cloudflare Tunnel"; TUNNEL_URL=""
for i in \$(seq 1 30); do
  TUNNEL_URL=\$(grep -o 'https://[a-zA-Z0-9._-]*\.trycloudflare\.com' "\$TUNNEL_LOG" 2>/dev/null | head -1)
  [ -n "\$TUNNEL_URL" ] && break; printf "."; sleep 1
done
printf "\n"
[ -n "\$TUNNEL_URL" ] && echo "\$TUNNEL_URL" > "\$APP_DIR/public/.tunnel-url"

echo "Starter $PROJECT på http://localhost:\$PORT"
[ -n "\$TUNNEL_URL" ] && echo "   Ekstern URL: \$TUNNEL_URL"
echo "   Tryk Ctrl+C for at stoppe"; echo ""

cd "\$APP_DIR"
$([ "$USE_ROUTER" = "Y" ] && echo 'php -S "127.0.0.1:$PORT" -t public/ public/router.php &' || echo 'php -S "127.0.0.1:$PORT" -t public/ &')
PHP_PID=\$!; wait \$PHP_PID
STARTSH
    else
      cat > "$PROJECT/start.sh" << STARTSH
#!/bin/bash
# Start $PROJECT lokalt
APP_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
PORT=$PORT

if ! command -v php &>/dev/null; then echo "Fejl: php ikke fundet i PATH"; exit 1; fi

if command -v lsof &>/dev/null; then
  EXISTING=\$(lsof -ti :\$PORT 2>/dev/null)
elif command -v fuser &>/dev/null; then
  EXISTING=\$(fuser \$PORT/tcp 2>/dev/null)
fi
[ -n "\$EXISTING" ] && echo "Stopper eksisterende server på port \$PORT" && kill \$EXISTING 2>/dev/null && sleep 0.5

echo "Starter $PROJECT på http://localhost:\$PORT"
echo "   Tryk Ctrl+C for at stoppe"; echo ""
cd "\$APP_DIR"
$([ "$USE_ROUTER" = "Y" ] && echo 'php -S "127.0.0.1:$PORT" -t public/ public/router.php' || echo 'php -S "127.0.0.1:$PORT" -t public/')
STARTSH
    fi
    chmod +x "$PROJECT/start.sh"
  fi

  # .env.example
  cat > "$PROJECT/.env.example" << 'EOF'
# Kopiér til .env og udfyld
APP_ENV=production
APP_DEBUG=false
DB_PATH=database/app.sqlite
EOF

  # .htaccess + router.php
  if [ "$USE_ROUTER" = "Y" ]; then
    cat > "$PROJECT/.htaccess" << HTEOF
RewriteEngine On
RewriteBase ${SUBPATH}/

RewriteRule ^(app|config|database|\.claude)/ - [F,L]
RewriteRule ^$ public/ [L]
RewriteRule ^((?!public/).*)$ public/\$1 [L]
HTEOF

    cat > "$PROJECT/public/.htaccess" << HTEOF
Options -Indexes
RewriteEngine On
RewriteBase ${REWRITEBASE}

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php?route=\$1 [QSA,L]

RewriteRule ^(app|config|database|\.claude)/ - [F,L]
HTEOF

    cat > "$PROJECT/public/router.php" << 'REOF'
<?php
$uri  = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$file = __DIR__ . $uri;
if ($uri !== '/' && file_exists($file) && !is_dir($file)) { return false; }
$_GET['route'] = ltrim($uri, '/');
require __DIR__ . '/index.php';
REOF
  fi

  # public/index.php
  cat > "$PROJECT/public/index.php" << 'INDEXEOF'
<?php
declare(strict_types=1);
define('ROOT', dirname(__DIR__));
require ROOT . '/config/app.php';
$autoload = ROOT . '/vendor/autoload.php';
if (file_exists($autoload)) { require $autoload; }
$route = trim($_GET['route'] ?? '', '/');
if (array_key_exists('__forge', $_GET)) {
    $project = basename(ROOT); include ROOT . '/app/views/welcome.php'; exit;
}
if ($route === '') {
    $index = ROOT . '/app/views/index.php';
    if (file_exists($index)) { include $index; } else { $project = basename(ROOT); include ROOT . '/app/views/welcome.php'; }
    exit;
}
http_response_code(404);
include ROOT . '/app/views/errors/404.php';
INDEXEOF

  # config/app.php
  cp "$FORGE_ROOT/templates/partials/config-app.php" "$PROJECT/config/app.php"

  # Database.php
  cp "$FORGE_ROOT/templates/partials/Database.php" "$PROJECT/app/models/Database.php"

  # schema.sql
  cp "$FORGE_ROOT/templates/partials/schema.sql" "$PROJECT/database/schema.sql"

  # api.js
  cp "$FORGE_ROOT/templates/partials/api.js" "$PROJECT/public/assets/js/api.js"

  # .editorconfig
  cp "$FORGE_ROOT/templates/partials/editorconfig" "$PROJECT/.editorconfig"

  # requirements.txt
  cp "$FORGE_ROOT/templates/partials/requirements.txt" "$PROJECT/requirements.txt"

  # composer.json (med variabel-substitution)
  local proj_name
  proj_name="$(basename "$PROJECT")"
  sed "s|PROJECT_NAME_PLACEHOLDER|${proj_name}|g" "$FORGE_ROOT/templates/partials/composer.json.tpl" > "$PROJECT/composer.json"

  # Fejlsider
  scaffold_error_pages

  if [ "$UPGRADE" = "false" ]; then
    stop_spinner "Projektfiler genereret"
  fi
}

install_motion_js() {
  [ "$USE_ACETERNITY" = "none" ] && return
  [ "$USE_ACETERNITY" = "" ]    && return

  start_spinner "Tilføjer Motion JS via CDN..."
  mkdir -p "$PROJECT/public/assets/partials"
  cp "$FORGE_ROOT/templates/partials/motion.html" "$PROJECT/public/assets/partials/motion.html"
  stop_spinner "motion.html partial inkluderet i layout"
}

scaffold_error_pages() {
  mkdir -p "$PROJECT/app/views/errors"

  cat > "$PROJECT/app/views/errors/404.php" << 'EOF'
<?php declare(strict_types=1); ?>
<!DOCTYPE html><html lang="da"><head><meta charset="UTF-8"><title>404 — Ikke fundet</title>
<style>body{font-family:system-ui,sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f5f5f5}
.box{text-align:center;padding:2rem}h1{font-size:4rem;margin:0;color:#1d1d1f}p{color:#666}</style>
</head><body><div class="box"><h1>404</h1><p>Siden blev ikke fundet.</p><p><a href="/">Gå til forsiden</a></p></div></body></html>
EOF

  cat > "$PROJECT/app/views/errors/500.php" << 'EOF'
<?php declare(strict_types=1); ?>
<!DOCTYPE html><html lang="da"><head><meta charset="UTF-8"><title>500 — Serverfejl</title>
<style>body{font-family:system-ui,sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f5f5f5}
.box{text-align:center;padding:2rem}h1{font-size:4rem;margin:0;color:#d70015}p{color:#666}</style>
</head><body><div class="box"><h1>500</h1><p>Der opstod en serverfejl.</p></div></body></html>
EOF
}
