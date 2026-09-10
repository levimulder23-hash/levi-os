# Workflow: session close (manual, run when Levi says "wrap up")

Objective: leave the OS truer than you found it. Replaces the Jarvis-era /finish and /shutdown (archived).

Steps
1. Decisions: append any confirmed decision from this session to `decisions/log.md` (format in that file).
2. Context: if Levi said "remember that I prefer X" or a fact changed, update the right file in `context/`; then run `scripts/sync-agents.sh`.
3. Alerts: tick handled lines in `alerts.md`; leave unresolved ones.
4. Backlog: add at most one item to `ai-os/os-improvement.md` if something repeatedly hurt.
5. Commit `~/OS` with a one-line message. Do not push unless Levi has said so.

Definition of Done: `git status` clean in `~/OS` and every new decision has a log entry.
On failure: append `- [ ] <date> session-close FAILED: <reason>` to `alerts.md`.
