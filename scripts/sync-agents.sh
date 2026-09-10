#!/usr/bin/env bash
# Regenerate everything derived from canonical sources:
#   CLAUDE.md            -> AGENTS.md (Codex mirror, same folder)
#   .claude/skills       -> .agents/skills (kit script)
#   context/*.md         -> ~/CLAUDE.md (home router: inlined expertise context so every project under ~ knows Levi)
set -euo pipefail
cd "$(dirname "$0")/.."
OS="$(pwd)"

{ echo "<!-- GENERATED from CLAUDE.md by scripts/sync-agents.sh — edit CLAUDE.md, not this file -->"; cat CLAUDE.md; } > AGENTS.md
bash scripts/sync-codex-skills.sh

{
  cat scripts/home-router.template.md
  for f in context/about-me.md context/priorities.md context/preferences.md; do
    echo; echo "<!-- from ~/OS/$f -->"; cat "$f"
  done
  echo; echo "<!-- from ~/OS/alerts.md -->"
  bash scripts/alerts-count.sh
  echo "(open ~/OS/alerts.md for details)"
} > "$HOME/CLAUDE.md"

{ echo "<!-- GENERATED from ~/CLAUDE.md by ~/OS/scripts/sync-agents.sh — Codex mirror; edit ~/OS/context instead -->"; cat "$HOME/CLAUDE.md"; } > "$HOME/AGENTS.md"
mkdir -p "$HOME/.codex" && cp "$HOME/AGENTS.md" "$HOME/.codex/AGENTS.md"
echo "AGENTS.md, .agents/skills, ~/CLAUDE.md and ~/AGENTS.md regenerated ($(wc -c < "$HOME/CLAUDE.md") bytes in ~/CLAUDE.md)"
