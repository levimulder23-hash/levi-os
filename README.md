# Levi's OS

One folder that knows Levi, routes to his businesses, and runs one proven skill at a time. Built 2026-09-10 on Nate Herk's AIS-OS kit (`archives/README-aisos-kit.md`). The operating manual is `CLAUDE.md`; start there.

## Status (2026-09-10)
| Phase | State |
|---|---|
| 0 Snapshot | done — bundles in `~/Amplify-Backups/` |
| 1 Home + interview | done — `context/` filled, `~/CLAUDE.md` generated, alerts heartbeat verified, private GitHub `levi-os` |
| 2 Archive map | done — vault and Amplify-Design left in place by design |
| 3 Freeze | local half done; Levi: Railway ×5, Vercel cron toggle, pfctl (sudo); verify nothing fires 2026-09-11 07:37 |
| 4 daily-brief | hand run 1 of 5 done |
| 5 rebuild small | not started (fie-logistics → health-checkin → email-triage → scheduled brief → small dashboard) |

## Daily use
- "brief" → `.claude/skills/daily-brief` (manual). Corrections go into `decisions/log.md`.
- New fact or preference → edit `context/`, run `scripts/sync-agents.sh`.
- Weekly → `/audit`, then `/level-up` (one improvement). Backlog: `ai-os/os-improvement.md`.
- Never schedule anything until the gate in `CLAUDE.md` is met.
