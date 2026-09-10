#!/usr/bin/env bash
# Amplify smoke test: proves the website project still works after a system change. Read-only.
set -euo pipefail
cd "$HOME/Amplify/amplify-website"
echo "== git"; git status --short | head -5; git log --oneline | head -1
echo "== instruction parity"; diff -q AGENTS.md CLAUDE.md && echo "AGENTS.md == CLAUDE.md"
echo "== project check"; node scripts/check-project.mjs
echo "== headless Claude session"; claude -p --model haiku "One line: who am I and what does this project's CLAUDE.md say site/ is?" 2>/dev/null | grep -v 'Permission allow rule' | tail -3
echo "SMOKE TEST PASSED"
