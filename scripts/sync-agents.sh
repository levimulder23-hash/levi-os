#!/usr/bin/env bash
# Regenerate the Codex mirrors. CLAUDE.md is canonical; AGENTS.md is generated.
set -euo pipefail
cd "$(dirname "$0")/.."
{ echo "<!-- GENERATED from CLAUDE.md by scripts/sync-agents.sh — edit CLAUDE.md, not this file -->"; cat CLAUDE.md; } > AGENTS.md
bash scripts/sync-codex-skills.sh
echo "AGENTS.md and .agents/skills regenerated"
