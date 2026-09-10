# scripts (WAT layer 3: deterministic tools)

| Script | Runs when | Gate |
|---|---|---|
| `alerts-count.sh` | every session start in `~/OS` (hook) | approved 2026-09-10 |
| `sync-agents.sh` | after editing `CLAUDE.md`, any skill, or `context/*` | none |
| `sync-codex-skills.sh` | called by sync-agents (kit) | none |
| `amplify-smoke-test.sh` | before and after any system change that could touch Claude Code | none (read-only) |
| `freeze-jarvis.sh` | Phase 3, once, after cloud tasks are disabled | **Levi's explicit go** |
