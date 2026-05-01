#!/bin/bash
# lib/99-finalize.sh — welcome.php, initial git commit, summary

_whp_browser_tester_row() {
  [ "${USE_CHROME_DEVTOOLS:-N}" = "Y" ] || return 0
  cat <<'EH'
    <div class="agent-row" style="border-color:rgba(56,189,248,.3)">
      <div class="agent-left" style="background:rgba(56,189,248,.06)">
        <div class="agent-name" style="color:var(--accent2)">browser-tester</div>
        <div class="agent-scope">Chrome DevTools &middot; E2E &middot; UX</div>
      </div>
      <div class="agent-right">Kører visuelle og funktionelle tests i Chrome via MCP. Validerer user-flows, responsive layouts og JavaScript-interaktioner i en rigtig browser.</div>
    </div>
EH
}

_whp_mcp_health_check_row() {
  if [ "${USE_VIAVI_SKILLS:-N}" != "Y" ] && [ "${USE_CONTEXT7:-N}" != "Y" ] && [ "${USE_CHROME_DEVTOOLS:-N}" != "Y" ]; then
    return 0
  fi
  cat <<'EH'
    <div class="agent-row" style="border-color:rgba(56,189,248,.3)">
      <div class="agent-left" style="background:rgba(56,189,248,.06)">
        <div class="agent-name" style="color:var(--accent2)">mcp-health-check</div>
        <div class="agent-scope">MCP &middot; tools &middot; connectivity</div>
      </div>
      <div class="agent-right">Verificerer at alle aktive MCP-servere svarer korrekt. Tjekker tool-tilg&aelig;ngelighed, autentifikation og svar-format. Blokerer ved dead tools eller auth-fejl.</div>
    </div>
EH
}

_whp_mcp_section() {
  [ "${USE_VIAVI_SKILLS:-N}" = "Y" ] || [ "${USE_CONTEXT7:-N}" = "Y" ] || [ "${USE_CHROME_DEVTOOLS:-N}" = "Y" ] || return 0
  echo '<div class="div"></div>'
  echo ''
  echo '<!-- MCP-SERVERE -->'
  echo '<section class="sec fu2" id="mcp">'
  echo '  <span class="sec-tag">MCP-servere</span>'
  echo '  <h2 class="sec-h2">Ekstern viden direkte i Claude.</h2>'
  echo '  <p class="sec-lead">MCP-servere giver Claude adgang til live dokumentation, browser-tests og team-skills &mdash; uden at forlade terminalen.</p>'
  echo '  <div style="display:flex;flex-direction:column;gap:8px;margin-top:36px">'
  if [ "${USE_VIAVI_SKILLS:-N}" = "Y" ]; then
    cat <<'EH'
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:12px;padding:18px 22px;display:grid;grid-template-columns:160px 1fr;gap:16px;align-items:start">
      <div>
        <div style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--brand);font-weight:500;margin-bottom:4px">viavi-skills</div>
        <div style="font-size:11px;color:var(--tm)">ViaVi &middot; skills &middot; patterns</div>
      </div>
      <div style="font-size:13px;color:var(--ts);line-height:1.65">Team-specifik viden fra ViaVi's centrale bibliotek. Trigger-baserede skills, design-patterns og projekt-regler &mdash; leveret som MCP-tools.</div>
    </div>
EH
  fi
  if [ "${USE_CONTEXT7:-N}" = "Y" ]; then
    cat <<'EH'
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:12px;padding:18px 22px;display:grid;grid-template-columns:160px 1fr;gap:16px;align-items:start">
      <div>
        <div style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--brand);font-weight:500;margin-bottom:4px">context7</div>
        <div style="font-size:11px;color:var(--tm)">Docs &middot; live &middot; versioned</div>
      </div>
      <div style="font-size:13px;color:var(--ts);line-height:1.65">Live, versions-nøjagtig dokumentation for PHP, Tailwind, SQLite og øvrige afhængigheder. Eliminerer hallucination om outdated API'er og funktioner.</div>
    </div>
EH
  fi
  if [ "${USE_CHROME_DEVTOOLS:-N}" = "Y" ]; then
    cat <<'EH'
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:12px;padding:18px 22px;display:grid;grid-template-columns:160px 1fr;gap:16px;align-items:start">
      <div>
        <div style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--brand);font-weight:500;margin-bottom:4px">chrome-devtools</div>
        <div style="font-size:11px;color:var(--tm)">Browser &middot; CDP &middot; tests</div>
      </div>
      <div style="font-size:13px;color:var(--ts);line-height:1.65">Giver Claude direkte adgang til Chrome via Chrome DevTools Protocol. Kører browser-tester-agenten, inspicerer DOM og fanger konsolejl i realtid.</div>
    </div>
EH
  fi
  echo '  </div>'
  echo '</section>'
}

_whp_superpowers_section() {
  [ "${INSTALL_SUPERPOWERS:-N}" = "Y" ] || return 0
  cat <<'EH'
<div class="div"></div>

<!-- SUPERPOWERS -->
<section class="sec fu2" id="superpowers">
  <span class="sec-tag" style="color:#a78bfa">Superpowers plugin</span>
  <h2 class="sec-h2">Disciplineret workflow før kode.</h2>
  <p class="sec-lead">Superpowers tvinger Claude Code igennem Clarify &rarr; Design &rarr; Plan &rarr; Code &rarr; Verify &mdash; så komplekse features ikke bliver til debugging. Plugin'et auto-installeres ved første <span class="mono">claude</span>-start.</p>

  <div style="margin-top:36px;display:grid;grid-template-columns:repeat(5,1fr);gap:8px">
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:10px;padding:14px 16px;text-align:center">
      <div style="font-family:'Geist Mono',monospace;font-size:10px;color:#a78bfa;text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px">1. Clarify</div>
      <div style="font-size:11px;color:var(--ts);line-height:1.6">Socratic spørgsmål før noget kode skrives</div>
    </div>
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:10px;padding:14px 16px;text-align:center">
      <div style="font-family:'Geist Mono',monospace;font-size:10px;color:#a78bfa;text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px">2. Design</div>
      <div style="font-size:11px;color:var(--ts);line-height:1.6">Foresl&aring;r arkitektur f&oslash;r implementation</div>
    </div>
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:10px;padding:14px 16px;text-align:center">
      <div style="font-family:'Geist Mono',monospace;font-size:10px;color:#a78bfa;text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px">3. Plan</div>
      <div style="font-size:11px;color:var(--ts);line-height:1.6">Bryder arbejdet op i bid-st&oslash;rrelser med TDD</div>
    </div>
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:10px;padding:14px 16px;text-align:center">
      <div style="font-family:'Geist Mono',monospace;font-size:10px;color:#a78bfa;text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px">4. Code</div>
      <div style="font-size:11px;color:var(--ts);line-height:1.6">Skriver test f&oslash;rst, derefter implementation</div>
    </div>
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:10px;padding:14px 16px;text-align:center">
      <div style="font-family:'Geist Mono',monospace;font-size:10px;color:#a78bfa;text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px">5. Verify</div>
      <div style="font-size:11px;color:var(--ts);line-height:1.6">Code-reviewer agent validerer mod planen</div>
    </div>
  </div>

  <div style="margin-top:18px;background:rgba(167,139,250,.05);border:1px solid rgba(167,139,250,.18);border-radius:10px;padding:14px 18px;font-size:12px;color:var(--ts);line-height:1.7">
    <strong style="color:#a78bfa">Skip f&oslash;les langsommere de f&oslash;rste 30 sekunder &mdash; sparer ofte 30 minutters debugging.</strong> For trivielle ting kan du sige <span class="mono">"skip clarify"</span> eller <span class="mono">"just fix this"</span>. Forfatter: Jesse Vincent (MIT). Se <span class="mono">obra/superpowers</span>.
  </div>
</section>
EH
}

_whp_awesome_agents_section() {
  # v3.6.5: Capability-pills — hvad Claude kan, ikke hvorfra det kommer.
  local has_sp="${INSTALL_SUPERPOWERS:-N}"
  local has_ag="${INSTALL_AGENTS:-none}"
  if [ "$has_sp" != "Y" ] && [ "$has_ag" = "none" ]; then
    return 0
  fi

  # Find faktisk installerede awesome (curated) agents
  local forge_owned=("frontend-reviewer" "db-reviewer" "data-integrity-auditor" "browser-tester" "mcp-health-check")
  local awesome_installed=()
  if [ -d "$PROJECT/.claude/agents" ]; then
    for f in "$PROJECT"/.claude/agents/*.md; do
      [ -f "$f" ] || continue
      local name; name=$(basename "$f" .md)
      local is_forge=0
      for fo in "${forge_owned[@]}"; do
        [ "$name" = "$fo" ] && is_forge=1 && break
      done
      [ "$is_forge" = 0 ] && awesome_installed+=("$name")
    done
  fi

  # Tæl alle installerede capabilities
  local total=0
  [ "$has_sp" = "Y" ] && total=$((total + 6))
  total=$((total + ${#awesome_installed[@]}))
  total=$((total + 3))
  [ "${USE_CHROME_DEVTOOLS:-N}" = "Y" ] && total=$((total + 1))
  if [ "${USE_VIAVI_SKILLS:-N}" = "Y" ] || [ "${USE_CONTEXT7:-N}" = "Y" ] || [ "${USE_CHROME_DEVTOOLS:-N}" = "Y" ]; then
    total=$((total + 1))
  fi

  cat <<EH
<div class="div"></div>

<!-- AI-CAPABILITIES (v3.6.5) -->
<section class="sec fu2" id="capabilities">
  <span class="sec-tag" style="color:#a78bfa">AI-capabilities</span>
  <h2 class="sec-h2">Klar til første prompt.</h2>
  <p class="sec-lead">${total} capabilities installeret og konfigureret. Skriv hvad du vil bygge &mdash; Claude bruger dem automatisk.</p>

  <div style="margin-top:28px;display:flex;flex-wrap:wrap;gap:8px">
EH

  # Workflow-pills (Superpowers)
  if [ "$has_sp" = "Y" ]; then
    for cap in "brainstorming" "writing-plans" "executing-plans" "systematic-debugging" "red-green-refactor" "code-review (auto)"; do
      echo "    <span style=\"background:rgba(167,139,250,.1);border:1px solid rgba(167,139,250,.25);border-radius:20px;padding:5px 13px;font-family:'Geist Mono',monospace;font-size:11px;color:#a78bfa\">${cap}</span>"
    done
  fi

  # Awesome-pills
  for name in "${awesome_installed[@]}"; do
    echo "    <span style=\"background:rgba(56,189,248,.08);border:1px solid rgba(56,189,248,.22);border-radius:20px;padding:5px 13px;font-family:'Geist Mono',monospace;font-size:11px;color:#38BDF8\">${name}</span>"
  done

  # Stack-pills (Forge, altid)
  for cap in "frontend-reviewer" "db-reviewer" "data-integrity-auditor"; do
    echo "    <span style=\"background:rgba(124,106,240,.1);border:1px solid rgba(124,106,240,.25);border-radius:20px;padding:5px 13px;font-family:'Geist Mono',monospace;font-size:11px;color:var(--brand)\">${cap}</span>"
  done
  if [ "${USE_CHROME_DEVTOOLS:-N}" = "Y" ]; then
    echo "    <span style=\"background:rgba(124,106,240,.1);border:1px solid rgba(124,106,240,.25);border-radius:20px;padding:5px 13px;font-family:'Geist Mono',monospace;font-size:11px;color:var(--brand)\">browser-tester</span>"
  fi
  if [ "${USE_VIAVI_SKILLS:-N}" = "Y" ] || [ "${USE_CONTEXT7:-N}" = "Y" ] || [ "${USE_CHROME_DEVTOOLS:-N}" = "Y" ]; then
    echo "    <span style=\"background:rgba(124,106,240,.1);border:1px solid rgba(124,106,240,.25);border-radius:20px;padding:5px 13px;font-family:'Geist Mono',monospace;font-size:11px;color:var(--brand)\">mcp-health-check</span>"
  fi

  cat <<'EH'
  </div>
</section>
EH
}

_whp_aceternity_section() {
  [ "${USE_ACETERNITY:-none}" != "none" ] || return 0
  echo '<div class="div"></div>'
  echo ''
  echo '<!-- ANIMATIONER -->'
  echo '<section class="sec fu2" id="animationer">'
  echo '  <span class="sec-tag">Animationer</span>'
  if [ "${USE_ACETERNITY:-none}" = "full" ]; then
    echo '  <h2 class="sec-h2">Motion JS + Aceternity patterns.</h2>'
    echo '  <p class="sec-lead">Motion JS er indlæst via CDN i alle sider. Aceternity-patterns er dokumenteret i DESIGN.md &mdash; Claude bruger dem automatisk ved UI-arbejde.</p>'
  else
    echo '  <h2 class="sec-h2">Motion JS klar.</h2>'
    echo '  <p class="sec-lead">Motion JS er indlæst via CDN i alle sider. Brug <code style="font-family:'\''Geist Mono'\'',monospace;font-size:12px;color:var(--accent2)">window.motion</code> direkte i JavaScript.</p>'
  fi
  cat <<'EH'
  <div style="margin-top:32px;display:flex;flex-direction:column;gap:12px">
    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:12px;padding:18px 22px">
      <div style="font-family:'Geist Mono',monospace;font-size:11px;color:var(--tm);text-transform:uppercase;letter-spacing:.08em;margin-bottom:10px">Motion JS CDN</div>
      <div style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--ts);line-height:1.7">Indlæst via <span style="color:var(--brand)">public/assets/partials/motion.html</span><br>Eksponeret som <span style="color:var(--accent2)">window.motion.animate</span>, <span style="color:var(--accent2)">window.motion.scroll</span>, <span style="color:var(--accent2)">window.motion.inView</span></div>
    </div>
EH
  if [ "${USE_ACETERNITY:-none}" = "full" ]; then
    cat <<'EH'
    <div style="background:linear-gradient(135deg,rgba(232,121,160,.06),rgba(124,106,240,.03));border:1px solid rgba(232,121,160,.2);border-radius:12px;padding:18px 22px">
      <div style="font-family:'Geist Mono',monospace;font-size:11px;color:var(--accent);text-transform:uppercase;letter-spacing:.08em;margin-bottom:10px">Aceternity Patterns</div>
      <div style="font-size:13px;color:var(--ts);line-height:1.65">Tilføjet til DESIGN.md &mdash; Claude kender patterns og bruger dem automatisk ved UI/UX-arbejde. Se <span style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--accent2)">DESIGN.md</span> for den fulde liste.</div>
    </div>
EH
  fi
  echo '  </div>'
  echo '</section>'
}

generate_welcome_php() {
  cat > "$PROJECT/app/views/welcome.php" << WELCOMEOF
<?php
/** Velkomstside — vises ved tom route. Erstat med din app når du er klar. */
\$tunnelUrlFile = ROOT . '/public/.tunnel-url';
\$tunnelUrl = (is_readable(\$tunnelUrlFile)) ? trim(file_get_contents(\$tunnelUrlFile)) : '';
?>
<!DOCTYPE html>
<html lang="da" data-theme="dark" data-font="geist">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= htmlspecialchars(\$project) ?> · klar</title>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
[data-theme="dark"]{
  --base:#080810;--surface:#0F0F1A;--elevated:#171726;
  --bs:#1A1A2E;--bd:#24243C;--bst:#32325A;
  --brand:#7C6AF0;--brandh:#6B59E0;--accent:#E879A0;--accent2:#38BDF8;
  --tp:#F0F0FF;--ts:#9090B8;--tm:#505078;
  --ok:#34D399;
  --nav-bg:rgba(8,8,16,.9);--glow1:rgba(124,106,240,.18);--glow2:rgba(232,121,160,.1)
}
[data-font="geist"]{--ff:'Geist',system-ui,sans-serif;--fh:700;--ftk:-.03em}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html,body{min-height:100vh;background:var(--base);color:var(--tp);font-family:var(--ff);-webkit-font-smoothing:antialiased;overflow-x:hidden}

#sp{position:fixed;top:0;left:0;height:2px;background:linear-gradient(90deg,var(--brand),var(--accent),var(--accent2));z-index:300;width:0%;transition:width .1s linear}
.mesh{position:fixed;inset:0;pointer-events:none;z-index:0;overflow:hidden}
.orb{position:absolute;border-radius:50%;filter:blur(100px);animation:orbf 14s ease-in-out infinite}
.o1{width:700px;height:700px;background:var(--glow1);top:-200px;left:-150px}
.o2{width:500px;height:500px;background:var(--glow2);bottom:-100px;right:-100px;animation-delay:-6s}
@keyframes orbf{0%,100%{transform:translate(0,0) scale(1)}40%{transform:translate(40px,-30px) scale(1.08)}70%{transform:translate(-20px,40px) scale(.94)}}
.noise{position:fixed;inset:0;pointer-events:none;z-index:1;opacity:.025;
  background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}

.nav{position:fixed;top:0;left:0;right:0;height:56px;background:var(--nav-bg);backdrop-filter:blur(16px);border-bottom:1px solid var(--bs);display:flex;align-items:center;padding:0 32px;z-index:200;justify-content:space-between}
.ldot{width:8px;height:8px;background:var(--brand);border-radius:50%;box-shadow:0 0 12px var(--brand);animation:pdot 2.5s ease-in-out infinite;flex-shrink:0}
@keyframes pdot{0%,100%{box-shadow:0 0 6px var(--brand)}50%{box-shadow:0 0 22px var(--brand),0 0 40px var(--brand)}}
.nav-left{display:flex;align-items:center;gap:10px}
.nav-name{font-size:15px;font-weight:600;letter-spacing:-.02em;color:var(--tp)}
.nav-ver{font-family:'Geist Mono',monospace;font-size:11px;color:var(--tm);background:var(--surface);border:1px solid var(--bd);padding:3px 8px;border-radius:6px}
.nav-link{font-size:13px;color:var(--ts);text-decoration:none;transition:color .15s}
.nav-link:hover{color:var(--tp)}

.page{position:relative;z-index:2}
.sec{padding:88px 32px;max-width:900px;margin:0 auto}
.div{height:1px;background:var(--bs);margin:0 32px;position:relative;z-index:2}

.gb{background:linear-gradient(90deg,var(--brand),var(--accent),var(--accent2),var(--brand));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;background-size:300% auto;animation:gsa 5s ease infinite}
@keyframes gsa{0%{background-position:0%}50%{background-position:100%}100%{background-position:0%}}
.gsu{background:linear-gradient(90deg,var(--tp),var(--ts));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}

.hero{min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:56px 32px 80px}
.hero-tag{font-family:'Geist Mono',monospace;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.12em;color:var(--brand);margin-bottom:24px;opacity:0;animation:fu .8s .1s cubic-bezier(.16,1,.3,1) forwards}
.hero h1{font-size:clamp(36px,6vw,80px);font-weight:var(--fh);letter-spacing:var(--ftk);line-height:1.05;margin-bottom:16px;opacity:0;animation:fu .9s .2s cubic-bezier(.16,1,.3,1) forwards}
.hero-sub{font-size:clamp(15px,2vw,18px);color:var(--ts);font-weight:300;line-height:1.7;max-width:500px;margin-bottom:48px;opacity:0;animation:fu .9s .3s cubic-bezier(.16,1,.3,1) forwards}
.prompt-wrap{width:100%;max-width:680px;opacity:0;animation:fu .9s .4s cubic-bezier(.16,1,.3,1) forwards}
@keyframes fu{to{opacity:1;transform:none}}

.prompt-box{background:var(--elevated);border:1px solid var(--bd);border-radius:12px;padding:24px 26px;text-align:left;position:relative}
.prompt-label{font-family:'Geist Mono',monospace;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.1em;color:var(--brand);margin-bottom:14px;display:flex;align-items:center;gap:8px}
.prompt-dot{width:6px;height:6px;border-radius:50%;background:var(--brand);box-shadow:0 0 8px var(--brand);animation:pdot 2.5s ease-in-out infinite}
.prompt-text{font-size:14px;line-height:1.85;color:var(--tp);white-space:pre-wrap;font-family:var(--ff)}
.prompt-hl{color:var(--accent2)}
.prompt-copy{position:absolute;top:16px;right:16px;background:none;border:1px solid var(--bd);border-radius:6px;padding:5px 12px;font-size:11px;color:var(--ts);cursor:pointer;font-family:var(--ff);transition:all .15s}
.prompt-copy:hover{border-color:var(--bst);color:var(--tp)}
.prompt-copy.ok{color:var(--ok);border-color:rgba(52,211,153,.3)}

.sec-tag{font-family:'Geist Mono',monospace;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.12em;color:var(--brand);margin-bottom:14px;display:block}
.sec-h2{font-size:clamp(26px,3.5vw,42px);font-weight:var(--fh);letter-spacing:var(--ftk);line-height:1.1;margin-bottom:12px}
.sec-lead{font-size:16px;color:var(--ts);font-weight:300;line-height:1.7}

.cmd-grid{display:grid;grid-template-columns:1fr 1fr;gap:32px;margin-top:40px}
.cmd-label{font-family:'Geist Mono',monospace;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.1em;margin-bottom:14px}
.cmd-list{display:flex;flex-direction:column;gap:6px}
.cmd-row{background:var(--surface);border:1px solid var(--bd);border-radius:10px;overflow:hidden}
.cmd-top{display:flex;align-items:center;justify-content:space-between;padding:11px 16px;border-bottom:1px solid var(--bs)}
.cmd-name{font-family:'Geist Mono',monospace;font-size:12px;color:var(--brand)}
.cmd-arg{color:var(--accent2)}
.cbtn{background:none;border:1px solid var(--bd);border-radius:6px;padding:3px 9px;font-size:11px;color:var(--ts);cursor:pointer;font-family:var(--ff);transition:all .15s}
.cbtn:hover{border-color:var(--bst);color:var(--tp)}
.cbtn.ok{color:var(--ok);border-color:rgba(52,211,153,.3)}
.cmd-desc{padding:9px 16px;font-size:12px;color:var(--ts);line-height:1.6}
.skill-row{background:var(--surface);border:1px solid var(--bd);border-radius:10px;overflow:hidden;margin-bottom:6px}
.skill-top{display:flex;align-items:center;justify-content:space-between;padding:11px 16px;border-bottom:1px solid var(--bs)}
.skill-name{font-family:'Geist Mono',monospace;font-size:12px;color:var(--accent)}
.skill-badge{font-size:10px;color:var(--tm);font-family:'Geist Mono',monospace;background:var(--elevated);border:1px solid var(--bd);padding:2px 8px;border-radius:5px}
.skill-desc{padding:9px 16px;font-size:12px;color:var(--ts);line-height:1.6}

.agents{display:flex;flex-direction:column;gap:2px;margin-top:40px}
.agent-row{display:grid;grid-template-columns:190px 1fr;border:1px solid var(--bd);overflow:hidden}
.agent-row:first-child{border-radius:12px 12px 2px 2px}
.agent-row:last-child{border-radius:2px 2px 12px 12px}
.agent-row:not(:first-child):not(:last-child){border-radius:2px}
.agent-left{background:rgba(124,106,240,.07);border-right:1px solid var(--bd);padding:18px 22px;display:flex;flex-direction:column;justify-content:center}
.agent-name{font-family:'Geist Mono',monospace;font-size:12px;font-weight:500;color:var(--brand);margin-bottom:4px}
.agent-scope{font-size:11px;color:var(--tm)}
.agent-right{padding:18px 24px;background:var(--surface);font-size:13px;color:var(--ts);line-height:1.65;display:flex;align-items:center}
.mono{font-family:'Geist Mono',monospace;font-size:12px;color:var(--accent2)}

.start-box{background:linear-gradient(135deg,rgba(124,106,240,.07),rgba(232,121,160,.04));border:1px solid rgba(124,106,240,.18);border-radius:12px;padding:24px 28px;margin-top:40px}
.start-box h3{font-size:16px;font-weight:600;color:var(--tp);margin-bottom:6px}
.start-box p{font-size:13px;color:var(--ts);line-height:1.6}
.code-line{margin-top:12px;background:var(--elevated);border:1px solid var(--bd);border-radius:8px;padding:12px 16px;display:flex;align-items:center;justify-content:space-between;gap:16px}
.code-line span{font-family:'Geist Mono',monospace;font-size:13px;color:var(--tp)}

.tunnel-card{background:linear-gradient(135deg,rgba(56,189,248,.07),rgba(124,106,240,.04));border:1px solid rgba(56,189,248,.25);border-radius:12px;padding:20px 24px;margin-top:16px;display:flex;align-items:center;gap:24px;flex-wrap:wrap}
.tunnel-qr{flex-shrink:0;background:#fff;border-radius:8px;padding:6px;display:flex}
.tunnel-qr canvas,.tunnel-qr img{display:block;border-radius:4px}
.tunnel-info{flex:1;min-width:0}
.tunnel-label{font-family:'Geist Mono',monospace;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.1em;color:var(--accent2);margin-bottom:8px}
.tunnel-url{font-family:'Geist Mono',monospace;font-size:13px;color:var(--tp);word-break:break-all;margin-bottom:10px}
.tunnel-note{font-size:12px;color:var(--tm);line-height:1.6}

.fu2{opacity:0;transform:translateY(24px);transition:opacity .6s ease,transform .6s ease}
.fu2.v{opacity:1;transform:none}

footer{text-align:center;padding:40px 32px;border-top:1px solid var(--bs);font-size:13px;color:var(--tm);position:relative;z-index:2}
footer a{color:var(--ts);text-decoration:none;transition:color .15s}
footer a:hover{color:var(--tp)}

@media(max-width:700px){
  .sec{padding:64px 20px}
  .div{margin:0 20px}
  .cmd-grid{grid-template-columns:1fr}
  .agent-row{grid-template-columns:1fr}
  .agent-left{border-right:none;border-bottom:1px solid var(--bd)}
  .nav{padding:0 20px}
}
</style>
</head>
<body>

<div id="sp"></div>
<div class="mesh"><div class="orb o1"></div><div class="orb o2"></div></div>
<div class="noise"></div>

<nav class="nav">
  <div class="nav-left">
    <div class="ldot"></div>
    <span class="nav-name"><?= htmlspecialchars(\$project) ?></span>
    <span class="nav-ver">ViaVi Forge v${FORGE_VERSION}</span>
  </div>
  <a href="https://viavi.dk/" class="nav-link">viavi.dk</a>
</nav>

<div class="page">

<!-- HERO -->
<section class="hero">
  <span class="hero-tag">ViaVi Forge &middot; <?= htmlspecialchars(\$project) ?></span>
  <h1><span class="gb"><?= htmlspecialchars(\$project) ?></span><br><span class="gsu">er klar.</span></h1>
  <p class="hero-sub">Login og grundstruktur er sat op. Beskriv hvad systemet skal gøre &mdash; Claude klarer resten.</p>

  <div style="width:100%;max-width:680px;margin-bottom:24px;opacity:0;animation:fu .9s .35s cubic-bezier(.16,1,.3,1) forwards">
    <div style="background:rgba(52,211,153,.06);border:1px solid rgba(52,211,153,.25);border-radius:10px;padding:14px 20px;font-size:13px;color:var(--ts);line-height:1.7;text-align:left">
      <strong style="color:var(--ok)">Klar til at erstatte denne side?</strong> Opret <span style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--accent2)">app/views/index.php</span> &mdash; routeren viser den automatisk på <span style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--accent2)">/</span>. Du behøver ikke røre <span style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--accent2)">public/index.php</span>.
    </div>
  </div>

  <div class="prompt-wrap">
    <div style="font-family:'Geist Mono',monospace;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.1em;color:var(--brand);margin-bottom:10px;text-align:left;display:flex;align-items:center;gap:8px">
      <div class="ldot" style="width:6px;height:6px"></div>
      Første prompt til Claude Code
    </div>
    <div class="prompt-box">
      <button class="prompt-copy" onclick="copyPrompt(this)">Kopiér</button>
      <p class="prompt-text">Læs CLAUDE.md og DESIGN.md &mdash; bekr&aelig;ft du forst&aring;r projektet og designsystemet.

Vi skal bygge <span class="prompt-hl">[beskriv hvad systemet skal g&oslash;re]</span>

Login og brugeradministration er allerede sat op af Forge.</p>
    </div>
  </div>

<?php if (\$tunnelUrl !== ''): ?>
  <div style="width:100%;max-width:680px;margin-top:20px;opacity:0;animation:fu .9s .5s cubic-bezier(.16,1,.3,1) forwards">
    <div class="tunnel-card">
      <div class="tunnel-qr" id="qr-container"></div>
      <div class="tunnel-info">
        <div class="tunnel-label">Cloudflare Tunnel &mdash; aktiv</div>
        <div class="tunnel-url"><?= htmlspecialchars(\$tunnelUrl) ?></div>
        <a href="<?= htmlspecialchars(\$tunnelUrl) ?>" target="_blank" rel="noopener" style="display:inline-block;font-size:12px;color:var(--accent2);text-decoration:none;border:1px solid rgba(56,189,248,.3);border-radius:6px;padding:4px 12px;margin-bottom:10px;transition:all .15s" onmouseover="this.style.borderColor='rgba(56,189,248,.6)'" onmouseout="this.style.borderColor='rgba(56,189,248,.3)'">Åbn &rarr;</a>
        <div class="tunnel-note">URL er unik for denne session &mdash; ny URL ved næste <span style="font-family:'Geist Mono',monospace;font-size:11px">bash start.sh --tunnel</span></div>
      </div>
    </div>
  </div>
<?php endif; ?>

</section>

$(_whp_superpowers_section)

<div class="div"></div>

<!-- COMMANDS -->
<section class="sec fu2" id="commands">
  <span class="sec-tag">Commands og skills</span>
  <h2 class="sec-h2">Hvad du skriver til Claude.</h2>
  <p class="sec-lead">Skills trigger automatisk &mdash; commands skriver du når du vil styre det selv.</p>

  <div class="cmd-grid">
    <div>
      <div class="cmd-label" style="color:var(--brand)">/project commands</div>
      <div class="cmd-list">

        <div class="cmd-row">
          <div class="cmd-top">
            <span class="cmd-name">/project:review</span>
            <button class="cbtn" onclick="copyLine(this,'/project:review')">Kopiér</button>
          </div>
          <div class="cmd-desc">Fuld review på tværs af alle review-dimensioner. Kører parallelt, blokerer ved CRITICAL.</div>
        </div>

        <div class="cmd-row">
          <div class="cmd-top">
            <span class="cmd-name">/project:fix-issue</span>
            <button class="cbtn" onclick="copyLine(this,'/project:fix-issue')">Kopiér</button>
          </div>
          <div class="cmd-desc">Retter fund fra seneste review. Critical først, derefter Major, derefter Minor.</div>
        </div>

        <div class="cmd-row">
          <div class="cmd-top">
            <span class="cmd-name">/project:new-page <span class="cmd-arg">[navn]</span></span>
            <button class="cbtn" onclick="copyLine(this,'/project:new-page ')">Kopiér</button>
          </div>
          <div class="cmd-desc">Opretter controller + view + route. Følger MVC-strukturen fra CLAUDE.md.</div>
        </div>

        <div class="cmd-row">
          <div class="cmd-top">
            <span class="cmd-name">/project:new-module <span class="cmd-arg">[navn]</span></span>
            <button class="cbtn" onclick="copyLine(this,'/project:new-module ')">Kopiér</button>
          </div>
          <div class="cmd-desc">Fuldt feature-modul: plan &rarr; schema &rarr; model &rarr; service &rarr; sider. Venter på godkendelse af plan.</div>
        </div>

        <div class="cmd-row">
          <div class="cmd-top">
            <span class="cmd-name">/project:db-init</span>
            <button class="cbtn" onclick="copyLine(this,'/project:db-init')">Kopiér</button>
          </div>
          <div class="cmd-desc">Initialiserer databasen fra <span class="mono">schema.sql</span>. Verificerer tabeller og admin-bruger.</div>
        </div>

        <div class="cmd-row">
          <div class="cmd-top">
            <span class="cmd-name">/project:deploy</span>
            <button class="cbtn" onclick="copyLine(this,'/project:deploy')">Kopiér</button>
          </div>
          <div class="cmd-desc">Produktions-tjekliste. Checker .env, .htaccess og alle review-dimensioner.</div>
        </div>

        <div class="cmd-row">
          <div class="cmd-top">
            <span class="cmd-name">/project:setup-python</span>
            <button class="cbtn" onclick="copyLine(this,'/project:setup-python')">Kopiér</button>
          </div>
          <div class="cmd-desc">Opretter Python venv, installerer <span class="mono">requirements.txt</span> og tilføjer <span class="mono">.venv/</span> til .gitignore.</div>
        </div>

        <div class="cmd-row" style="border-color:rgba(16,185,129,.3);background:linear-gradient(135deg,rgba(16,185,129,.06),rgba(56,189,248,.03))">
          <div class="cmd-top">
            <span class="cmd-name" style="color:#10b981">/project:sanity-check</span>
            <button class="cbtn" onclick="copyLine(this,'/project:sanity-check')">Kopiér</button>
          </div>
          <div class="cmd-desc">Verificerer dashboard/rapport: matematisk konsistens, business-plausibilitet og krydscheck mod rå API-data. PASS / WARN / CRITICAL per metrik.</div>
        </div>

        <div class="cmd-row" style="border-color:rgba(56,189,248,.3);background:linear-gradient(135deg,rgba(56,189,248,.06),rgba(124,106,240,.03))">
          <div class="cmd-top">
            <span class="cmd-name" style="color:var(--accent2)">/project:health</span>
            <button class="cbtn" onclick="copyLine(this,'/project:health')">Kopiér</button>
          </div>
          <div class="cmd-desc">Tjekker MCP-servere, agenter og CLI-afhængigheder. Verificerer at hele Forge-stacken er i drift.</div>
        </div>

        <div class="cmd-row" style="border-color:rgba(167,139,250,.3);background:linear-gradient(135deg,rgba(167,139,250,.06),rgba(56,189,248,.03))">
          <div class="cmd-top">
            <span class="cmd-name" style="color:#a78bfa">forge agents <span class="cmd-arg">[list|search|update]</span></span>
            <button class="cbtn" onclick="copyLine(this,'forge agents list')">Kopiér</button>
          </div>
          <div class="cmd-desc">CLI-kommando: list kategorier, søg efter en specifik agent (fx <span class="mono">forge agents search nextjs</span>) eller opdater cache.</div>
        </div>

      </div>
    </div>

    <div>
      <div class="cmd-label" style="color:var(--accent)">Skills &middot; auto-trigger</div>

      <div class="skill-row">
        <div class="skill-top">
          <span class="skill-name">pre-commit</span>
          <span class="skill-badge">auto</span>
        </div>
        <div class="skill-desc">Trigger: "commit", "klar til commit", "push". K&oslash;rer alle relevante review-agenter (Forge stack + awesome curated) og foresl&aring;r commit-besked.</div>
      </div>

      <div class="skill-row">
        <div class="skill-top">
          <span class="skill-name">security-review</span>
          <span class="skill-badge">auto</span>
        </div>
        <div class="skill-desc">Trigger: &aelig;ndringer til auth, sessions eller API-services. Spawner <span class="mono">security-auditor</span>-agent (awesome). Blokerer ved CRITICAL-fund.</div>
      </div>

      <div class="skill-row">
        <div class="skill-top">
          <span class="skill-name">deploy</span>
          <span class="skill-badge">auto</span>
        </div>
        <div class="skill-desc">Trigger: "klar til produktion", "deploy". K&oslash;rer fuld review og outputter deployment-tjekliste.</div>
      </div>

      <div class="skill-row">
        <div class="skill-top">
          <span class="skill-name">document</span>
          <span class="skill-badge">auto</span>
        </div>
        <div class="skill-desc">Trigger: efter hvert modul + trin 1 i pre-commit. Opdaterer PROJECT.md med hvad der faktisk er bygget.</div>
      </div>
$([ "$INCLUDE_UIUX" = "Y" ] && [ "$UIUX_INSTALLED" = "Y" ] && cat <<'UIUX_EOF'

      <div class="skill-row">
        <div class="skill-top">
          <span class="skill-name">ui-ux-pro-max</span>
          <span class="skill-badge">auto</span>
        </div>
        <div class="skill-desc">Trigger: ved UI/UX-arbejde. 67 design-styles, 96 paletter, 57 font-par &mdash; validerer kontrast og tilg&aelig;ngelighed automatisk.</div>
      </div>
UIUX_EOF
)

      <div style="margin-top:16px;padding:16px 18px;background:linear-gradient(135deg,rgba(124,106,240,.06),rgba(232,121,160,.03));border:1px solid rgba(124,106,240,.15);border-radius:10px">
        <div style="font-family:'Geist Mono',monospace;font-size:11px;color:var(--brand);text-transform:uppercase;letter-spacing:.08em;margin-bottom:10px">PROJECT.md &mdash; din bro til andre AI-systemer</div>
        <div style="font-size:12px;color:var(--ts);line-height:1.7">Holdes automatisk opdateret af <span style="font-family:'Geist Mono',monospace;font-size:11px;color:var(--accent)">document</span>-skill'en. Claude loader den automatisk. Skifter du til Copilot eller Cursor &mdash; se guiden nedenfor.</div>
      </div>

      <div style="margin-top:16px;padding:16px 18px;background:var(--surface);border:1px solid var(--bd);border-radius:10px">
        <div style="font-family:'Geist Mono',monospace;font-size:11px;color:var(--tm);text-transform:uppercase;letter-spacing:.08em;margin-bottom:12px">Proaktiv adfærd</div>
        <div style="display:flex;flex-direction:column;gap:8px">
          <div style="font-size:12px;color:var(--ts);padding-bottom:8px;border-bottom:1px solid var(--bs)">"Det virker" &rarr; kører pre-commit automatisk</div>
          <div style="font-size:12px;color:var(--ts);padding-bottom:8px;border-bottom:1px solid var(--bs)">"Vi skal bygge X" &rarr; laver plan, venter på godkendelse</div>
          <div style="font-size:12px;color:var(--ts);padding-bottom:8px;border-bottom:1px solid var(--bs)">"Noget virker ikke" &rarr; diagnosticerer og retter selv</div>
          <div style="font-size:12px;color:var(--ts);padding-bottom:8px;border-bottom:1px solid var(--bs)">"Hvad mangler?" &rarr; opsummerer og foreslår næste skridt</div>
          <div style="font-size:12px;color:#10b981">"Dashboardet er klar" / "vis data" &rarr; kører sanity-check automatisk</div>
        </div>
      </div>
    </div>
  </div>
</section>

<div class="div"></div>

<!-- AGENTER -->
<section class="sec fu2" id="agenter">
  <span class="sec-tag">Stack-specifikke agents</span>
  <h2 class="sec-h2">PHP/SQLite-specialister. Forge-domæne.</h2>
  <p class="sec-lead">Frontend (Tailwind+PHP partials), database (SQLite WAL), data-integritet (Forge schema), browser (Chrome MCP) og MCP-helbred. Hver én ejer sit dom&aelig;ne &mdash; ingen overlap med Superpowers eller awesome.</p>

  <div class="agents">
    <div class="agent-row">
      <div class="agent-left">
        <div class="agent-name">frontend-reviewer</div>
        <div class="agent-scope">Tailwind &middot; JS &middot; WCAG</div>
      </div>
      <div class="agent-right">DESIGN.md-compliance, responsivt layout, JavaScript-kvalitet og accessibility. Flager <span class="mono" style="margin:0 3px">innerHTML</span> med brugerdata som CRITICAL.</div>
    </div>
    <div class="agent-row">
      <div class="agent-left">
        <div class="agent-name">db-reviewer</div>
        <div class="agent-scope">SQLite &middot; Schema &middot; WAL</div>
      </div>
      <div class="agent-right">Schema-design, prepared statements, WAL-mode og FK-constraints. N+1-queries flagges som CRITICAL.</div>
    </div>
    <div class="agent-row" style="border-color:rgba(16,185,129,.3)">
      <div class="agent-left" style="background:rgba(16,185,129,.06)">
        <div class="agent-name" style="color:#10b981">data-integrity-auditor</div>
        <div class="agent-scope">API-data &middot; tal &middot; sanity</div>
      </div>
      <div class="agent-right">Validerer data fra eksterne API'er inden aggregering: valuta, tidszoner, metrik-definitioner, null vs. zero. Kører også sanity-check på færdige dashboards &mdash; matematisk konsistens og business-plausibilitet. Blokerer ved CRITICAL.</div>
    </div>
$(_whp_browser_tester_row)
$(_whp_mcp_health_check_row)
  </div>
</section>

$(_whp_awesome_agents_section)

$(_whp_mcp_section)
<!-- SKIFT AI-SYSTEM -->
<section class="sec fu2" id="skift">
  <span class="sec-tag">Skift AI-system</span>
  <h2 class="sec-h2">Vil du fortsætte i Copilot eller Cursor?</h2>
  <p class="sec-lead">PROJECT.md indeholder alt hvad et nyt AI-system skal vide. Kopier den nyeste version &mdash; document-skill'en holder den opdateret automatisk.</p>

  <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-top:28px">

    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:12px;padding:18px">
      <div style="font-size:18px;margin-bottom:8px">&#x1f419;</div>
      <div style="font-size:14px;font-weight:600;color:var(--tp);margin-bottom:8px">GitHub Copilot</div>
      <div style="display:flex;flex-direction:column;gap:7px">
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">1.</span>Åbn projektmappen i VS Code</div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">2.</span>Opret filen <span class="mono" style="margin:0 2px">.github/copilot-instructions.md</span></div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">3.</span>Kopier alt fra PROJECT.md ind i den</div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">4.</span>Copilot læser den automatisk fremover</div>
      </div>
    </div>

    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:12px;padding:18px">
      <div style="font-size:18px;margin-bottom:8px">&#x2328;&#xfe0f;</div>
      <div style="font-size:14px;font-weight:600;color:var(--tp);margin-bottom:8px">Cursor</div>
      <div style="display:flex;flex-direction:column;gap:7px">
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">1.</span>Åbn projektmappen i Cursor</div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">2.</span>Opret filen <span class="mono" style="margin:0 2px">.cursorrules</span> i roden</div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">3.</span>Kopier alt fra PROJECT.md ind i den</div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">4.</span>Cursor bruger den fra første besked</div>
      </div>
    </div>

    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:12px;padding:18px">
      <div style="font-size:18px;margin-bottom:8px">&#x1f4ac;</div>
      <div style="font-size:14px;font-weight:600;color:var(--tp);margin-bottom:8px">ChatGPT eller andet</div>
      <div style="display:flex;flex-direction:column;gap:7px">
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">1.</span>Åbn PROJECT.md i et tekstprogram</div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">2.</span>Kopier hele indholdet</div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">3.</span>Paste det som første besked i chatten</div>
        <div style="display:flex;gap:8px;font-size:12px;color:var(--ts)"><span style="color:var(--brand);font-weight:600;flex-shrink:0">4.</span>Beskriv derefter hvad du vil bygge</div>
      </div>
    </div>

  </div>

  <div style="margin-top:14px;background:rgba(124,106,240,.05);border:1px solid rgba(124,106,240,.13);border-radius:8px;padding:12px 16px;font-size:12px;color:var(--ts);line-height:1.65">
    <strong style="color:var(--brand)">Husk:</strong> Kopier altid den version der ligger i din projektmappe &mdash; document-skill'en sørger for at den er opdateret.
  </div>
</section>

<div class="div"></div>

<!-- LOKAL SERVER -->
<section class="sec fu2">
  <span class="sec-tag">Lokal server</span>
  <h2 class="sec-h2">Se projektet i browseren.</h2>
  <div class="start-box">
    <h3>Start udviklingsserveren</h3>
    <p>Åbn en ny terminal, gå til projektmappen og kør:</p>
    <div class="code-line">
      <span>bash start.sh</span>
      <button class="cbtn" onclick="copyLine(this,'bash start.sh')">Kopiér</button>
    </div>
    $([ "$USE_TUNNEL" = "Y" ] && echo '<p style="margin-top:8px;font-size:13px;color:var(--ok)">Cloudflare Tunnel er aktiveret &mdash; ekstern URL vises i terminalen når serveren starter.</p>')
    <p style="margin-top:10px;font-size:12px;color:var(--tm)">Standard port: $PORT &nbsp;&middot;&nbsp; Admin: admin@example.com / Admin123! &nbsp;&mdash;&nbsp; <strong style="color:var(--accent)">skift inden produktion</strong></p>
  </div>
</section>

$(_whp_aceternity_section)
<div class="div"></div>

<!-- TILGÅ DENNE SIDE IGEN -->
<section class="sec fu2">
  <span class="sec-tag">Denne side</span>
  <h2 class="sec-h2">Tilgå Forge-guiden igen.</h2>
  <p class="sec-lead">Når du har bygget din app og denne velkomstside er erstattet, kan du stadig åbne guiden direkte med parameteret <span style="font-family:'Geist Mono',monospace;font-size:14px;color:var(--accent2)">?__forge</span>.</p>

  <div style="margin-top:32px;display:flex;flex-direction:column;gap:12px">

    <div style="background:var(--surface);border:1px solid var(--bd);border-radius:12px;padding:20px 24px">
      <div style="font-family:'Geist Mono',monospace;font-size:11px;color:var(--tm);text-transform:uppercase;letter-spacing:.08em;margin-bottom:12px">Lokalt</div>
      <div class="code-line" style="margin-top:0">
        <span>http://localhost:$PORT/?__forge</span>
        <button class="cbtn" onclick="copyLine(this,'http://localhost:$PORT/?__forge')">Kopiér</button>
      </div>
    </div>

<?php if (\$tunnelUrl !== ''): ?>
    <div style="background:linear-gradient(135deg,rgba(56,189,248,.06),rgba(124,106,240,.03));border:1px solid rgba(56,189,248,.2);border-radius:12px;padding:20px 24px">
      <div style="font-family:'Geist Mono',monospace;font-size:11px;color:var(--accent2);text-transform:uppercase;letter-spacing:.08em;margin-bottom:12px">Via Cloudflare Tunnel</div>
      <div class="code-line" style="margin-top:0">
        <span><?= htmlspecialchars(\$tunnelUrl) ?>/?__forge</span>
        <button class="cbtn" onclick="copyLine(this,<?= json_encode(\$tunnelUrl . '/?__forge') ?>)">Kopiér</button>
      </div>
    </div>
<?php endif; ?>

    <div style="background:rgba(124,106,240,.04);border:1px solid rgba(124,106,240,.12);border-radius:8px;padding:13px 16px;font-size:13px;color:var(--ts);line-height:1.65">
      <strong style="color:var(--brand)">Tip:</strong> Parameteret virker fra enhver side i appen &mdash; også <span style="font-family:'Geist Mono',monospace;font-size:12px;color:var(--accent2)">http://localhost:$PORT/dashboard?__forge</span> åbner guiden.
    </div>

  </div>
</section>

</div>

<footer>
  <?= htmlspecialchars(\$project) ?> &middot; bygget med ViaVi Forge v${FORGE_VERSION} &middot; <a href="https://viavi.dk/">viavi.dk</a>
</footer>

<?php if (\$tunnelUrl !== ''): ?>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<?php endif; ?>
<script>
<?php if (\$tunnelUrl !== ''): ?>
window.addEventListener('load', function() {
  var el = document.getElementById('qr-container');
  if (el) {
    new QRCode(el, {
      text: <?= json_encode(\$tunnelUrl) ?>,
      width: 96,
      height: 96,
      colorDark: '#000000',
      colorLight: '#ffffff',
      correctLevel: QRCode.CorrectLevel.M
    });
  }
});
<?php endif; ?>
window.addEventListener('scroll',function(){
  var p=(window.scrollY/(document.body.scrollHeight-window.innerHeight))*100;
  document.getElementById('sp').style.width=p+'%';
});

var obs=new IntersectionObserver(function(entries){
  entries.forEach(function(e){
    if(e.isIntersecting){e.target.classList.add('v');obs.unobserve(e.target);}
  });
},{threshold:.1});
document.querySelectorAll('.fu2').forEach(function(el,i){
  el.style.transitionDelay=((i%4)*0.08)+'s';
  obs.observe(el);
});

function copyPrompt(btn){
  var text="Læs CLAUDE.md og DESIGN.md — bekræft du forstår projektet og designsystemet.\n\nVi skal bygge [beskriv hvad systemet skal gøre]\n\nLogin og brugeradministration er allerede sat op af Forge.";
  navigator.clipboard.writeText(text).then(function(){flashOk(btn);});
}
function copyLine(btn,text){
  navigator.clipboard.writeText(text).then(function(){flashOk(btn);});
}
function flashOk(btn){
  var orig=btn.textContent;
  btn.textContent='✓ Kopiéret';
  btn.classList.add('ok');
  setTimeout(function(){btn.textContent=orig;btn.classList.remove('ok');},2200);
}
</script>
</body>
</html>
WELCOMEOF
}

finalize_project() {
  # welcome.php (altid genereret — erstattes af index.php når appen er klar)
  if [ "$UPGRADE" = "false" ]; then
    start_spinner "Genererer velkomstside..."
    generate_welcome_php
    stop_spinner "Velkomstside genereret"
  fi

  # PROJECT.md
  generate_project_md

  # CLAUDE.local.md
  generate_claude_local_md

  # Initial git commit
  if [ "$UPGRADE" = "false" ]; then
    start_spinner "Initialiserer git..."
    git -C "$PROJECT" add -A
    # Sæt midlertidig identitet hvis ingen global config
    if ! git -C "$PROJECT" config user.email &>/dev/null; then
      git -C "$PROJECT" config user.email "forge@viavi.dk"
      git -C "$PROJECT" config user.name "ViaVi Forge"
    fi
    git -C "$PROJECT" commit -q -m "Initial project scaffold — ViaVi Forge v${FORGE_VERSION}" 2>/dev/null || true
    stop_spinner "Git initialiseret"
  fi
}

print_summary() {
  echo ""
  if [ "$UPGRADE" = "true" ]; then
    echo "  ✓  Forge-konfiguration opgraderet i '$(basename "$PROJECT")'"
    echo "     (CLAUDE.md, rules, agents, commands, skills, DESIGN.md)"
  else
    local deploy_path="${SUBPATH:-/}"
    if [ "$USE_ROUTER" = "Y" ]; then
      echo "Projekt '$(basename "$PROJECT")' oprettet (deployment-sti: $deploy_path)"
    else
      echo "Projekt '$(basename "$PROJECT")' oprettet (uden Apache routing)"
    fi
    echo ""
    echo "  Konfiguration:"
    echo "    Tailwind:       ${USE_TAILWIND:-N}"
    echo "    DESIGN.md:      ${DESIGN_SOURCE:-ingen}"
    echo "    MCP-servere:    $([ "${USE_VIAVI_SKILLS:-N}" = "Y" ] && echo "ViaVi Skills" || true)$([ "${USE_CONTEXT7:-N}" = "Y" ] && echo " Context7" || true)$([ "${USE_CHROME_DEVTOOLS:-N}" = "Y" ] && echo " Chrome" || true)"
    local ace_label="ingen"
    case "${USE_ACETERNITY:-none}" in
      full)   ace_label="Aceternity + Motion JS" ;;
      motion) ace_label="Motion JS" ;;
    esac
    echo "    Animationer:    $ace_label"
    echo ""
    find "$PROJECT" | grep -v '\.git' | sort
  fi
  echo ""
  echo "Start: cd $(basename "$PROJECT") && claude"
  echo ""
}
