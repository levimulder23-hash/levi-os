#!/usr/bin/env bash
# PHASE 3 FREEZE — DO NOT RUN WITHOUT LEVI'S EXPLICIT GO (schedule/hook/deploy gate).
# Local half of the freeze. Cloud tasks (Cowork scheduled tasks, Claude Code scheduled-tasks MCP,
# Vercel crons, Railway services) are disabled separately, BEFORE this runs.
# Everything here is reversible: plists are moved, not deleted; settings files are backed up first.
set -uo pipefail
STAMP=2026-09
LA="$HOME/Library/LaunchAgents"; FROZEN="$LA/_frozen_$STAMP"; mkdir -p "$FROZEN"
BK="$HOME/OS/archives/dot-claude-$STAMP"; mkdir -p "$BK"
echo "== 0. backups"
cp -p "$HOME/.claude/settings.json" "$BK/settings.json.pre-freeze"
cp -p "$HOME/.claude/settings.local.json" "$BK/settings.local.json.pre-freeze"

echo "== 1. strip ALL hooks from both global settings files (backups above)"
python3 - <<'PY'
import json,os
for p in (os.path.expanduser('~/.claude/settings.json'), os.path.expanduser('~/.claude/settings.local.json')):
    d=json.load(open(p)); n=sum(len(v) for v in d.get('hooks',{}).values())
    d['hooks']={}; json.dump(d,open(p,'w'),indent=2); print(f"{p}: removed {n} hook groups")
PY

echo "== 2. tracker + calendar/interval agents"
for l in com.levimulder.tracker com.alahmar.tracker \
         com.levimulder.battery-watcher com.levimulder.usage-limit-watcher com.levimulder.watchlist-refresh \
         com.levimulder.vault-sync com.levimulder.idle-agent com.levimulder.security-scanner \
         com.levimulder.jarvis-morning com.levimulder.jarvis-deadline-alert com.levimulder.jarvis-weekly-digest \
         com.levimulder.options-screener com.levimulder.health-weekly com.levimulder.health-monthly \
         com.levimulder.health-med-morning com.levimulder.health-med-evening com.levimulder.jarvis-med-noon \
         com.levimulder.health-hydration com.levimulder.jarvis-voice com.levimulder.dashboard com.levimulder.sidebar Glaido; do
  launchctl bootout "gui/$(id -u)/$l" 2>/dev/null && echo "booted out $l" || echo "not loaded: $l"
  [ -f "$LA/$l.plist" ] && mv "$LA/$l.plist" "$FROZEN/" && echo "  moved $l.plist"
done

echo "== 3. proxy + env together (order matters: unset the base URL or Claude Code breaks)"
launchctl bootout "gui/$(id -u)/com.levimulder.env-setup" 2>/dev/null; launchctl unsetenv ANTHROPIC_BASE_URL
launchctl bootout "gui/$(id -u)/com.levimulder.ruflo-proxy" 2>/dev/null && echo "booted out ruflo-proxy"
for l in com.levimulder.env-setup com.levimulder.ruflo-proxy; do [ -f "$LA/$l.plist" ] && mv "$LA/$l.plist" "$FROZEN/"; done
echo "ANTHROPIC_BASE_URL now: '$(launchctl getenv ANTHROPIC_BASE_URL)' (expect empty)"

echo "== 4. ollama"
launchctl bootout "gui/$(id -u)/com.levimulder.ollama" 2>/dev/null && echo "booted out ollama"
[ -f "$LA/com.levimulder.ollama.plist" ] && mv "$LA/com.levimulder.ollama.plist" "$FROZEN/"

echo "== 5. NOT done here (needs sudo, do by hand last): /Library/LaunchDaemons/com.levimulder.pfctl — read /etc/ruflo-pf.conf first"
echo "== verify"
launchctl list | grep -E 'levimulder|alahmar|Glaido' || echo "no Levi agents loaded"
ls "$FROZEN" | wc -l | xargs echo "plists frozen:"
echo "Now run: bash ~/OS/scripts/amplify-smoke-test.sh   and open a new Claude Code session in ~/OS (expect ALERTS: line)."
