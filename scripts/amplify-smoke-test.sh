#!/usr/bin/env bash
# Amplify smoke test: proves the website project still works after a system change. Read-only.
set -uo pipefail
fail(){ echo "SMOKE TEST FAILED: $1"; exit 1; }
cd "$HOME/Amplify/amplify-website"
echo "== git"; git status --short | head -5; git log --oneline | head -1
echo "== instruction parity"; diff -q AGENTS.md CLAUDE.md && echo "AGENTS.md == CLAUDE.md" || fail "AGENTS.md and CLAUDE.md differ (website project decides; not a system fault)"
echo "== project check"; node scripts/check-project.mjs || fail "check-project.mjs failed"
echo "== headless Claude session"; claude -p --model haiku "One line: who am I and what does this project's CLAUDE.md say site/ is?" 2>/dev/null | grep -v 'Permission allow rule' | tail -3
echo "SMOKE TEST PASSED"
