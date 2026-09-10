# Jarvis Autonomy Policy

> Approved by Levi Mulder — 2026-06-30
> Stored here so any future session can read it and know what's allowed without asking.

---

## Core Principle

Continue inside approved safe scope without asking for every step. Stop only at real risk boundaries. Write checkpoints silently. Surface only failures, blocks, and things that need a decision.

---

## Autonomy Levels

### LEVEL 0 — Always allowed, no notification needed
- Read any repo file, config, log, or checkpoint
- Search the codebase
- Run `git status` / `git diff` / `git log`
- Run typecheck, lint, build, or tests
- Create or update internal planning/checkpoint files (e.g. `sprint-checkpoint.json`)
- Edit safe in-scope repo files for the currently approved task
- Create local reports, audit logs, or proposals
- Classify resources without implementing them
- Continue the current approved sprint scope

### LEVEL 1 — Allowed, batched summary at checkpoint or on request
- Make safe local code edits inside current approved scope
- Commit clean logical commits
- Update docs: `AGENTS.md`, `failures.md`, `AUTONOMY.md`, routing policy, local ops docs
- Create non-executing SQL files for review
- Add local-only status/health endpoints
- Add tests/checks
- Queue future proposals without executing them
- Update scheduled task prompts for clarity, noise reduction, or correctness (not new tasks)

**Do not notify Levi per-file. Summarize at checkpoints or when asked.**

### LEVEL 2 — Ask once per bounded project
- Starting a new major task outside the currently approved scope
- Enabling a new scheduled task
- Changing routing behavior that could affect cost
- Adding a new background loop
- Applying database migrations (Levi runs these manually at supabase.com)
- Modifying LaunchAgents
- Restarting or killing local services
- Connecting an existing integration in a new way
- Sending Telegram / system notifications (outside of approved scheduled tasks)

**Ask once. Once approved, proceed without re-asking within the same bounded project.**

### LEVEL 3 — Always ask explicitly, every time
- Spending money or adding paid APIs
- Using Opus or expensive models intentionally
- Deploying to production
- Deleting important files or data
- Changing credentials, secrets, auth, or security settings
- Connecting external accounts
- Running Supabase SQL directly against production
- Sending emails or messages on Levi's behalf
- Submitting school / Canvas / coursework
- Finance, tax, or trading actions
- Live broker connections
- Installing major new tools, repos, MCPs, or frameworks
- Any irreversible external action

---

## Notification Policy

**Do not notify for normal safe progress.**

Send a message only for:
1. Final verification reports when a sprint phase completes
2. Blocked or risk approval requests (Level 2+)
3. Failures that need a decision
4. Security, cost, or external-action warnings (Level 3)
5. Scheduled daily/batched summaries if pre-approved

**Do not stop just because a task has multiple steps.**

Keep going until the approved scope is complete, blocked, failed, or hits a risk boundary.

---

## Task Behavior

- If context or session ends: resume from `sprint-checkpoint.json` or the relevant persistent state file.
- Do not duplicate tasks. If a task is already running or complete, note it and move on.
- If approval is needed: mark the task `waiting_approval` in the checkpoint instead of retrying.
- If a task fails: log the failure and next action in the checkpoint. Continue with safe in-scope work.
- If risky: stop and ask.

## Approval-Block Handling (Required)

When a tool call returns "Denied by user" or stalls on a UI approval dialog while Levi is away:

1. **Mark the task `waiting_approval` in `sprint-checkpoint.json`** — include: task name, action attempted, reason blocked, risk level, fallback.
2. **Do NOT retry the same blocked action** in the same session.
3. **Skip to the next safe approved task** immediately.
4. **Do NOT stall the entire sprint** because one task is blocked.
5. **List all blocked approvals** in the final sprint summary.

Checkpoint format:
```json
{
  "blocked_tasks": [
    {
      "task": "update improvement loop prompt",
      "status": "waiting_approval",
      "action": "mcp__scheduled-tasks__update_scheduled_task",
      "reason": "UI approval dialog required; Levi was away",
      "risk_level": 1,
      "fallback": "skip and report in final summary"
    }
  ]
}
```

**Why:** On 2026-06-30, the sprint stalled for ~6 hours because `update_scheduled_task` required a UI approval and Levi was away. The system froze instead of continuing safe work. This must never happen again.

---

## Scheduled Task Authority Policy

> Approved 2026-07-07. Implemented in `lib/scheduled-task-policy.ts`.
> Run `classifyScheduledTaskAction` before any scheduled-task mutation and log the result.

### Rule

```
AUTO_ALLOW  — reducing usage, risk, noise, or load
NEEDS_LEVI  — increasing usage, frequency, model power, external action, or risk
AUTO_BLOCK  — dangerous or wasteful behavior (fail conservative on unknowns)
```

### AUTO_ALLOW — act without asking

| Action | Example |
|---|---|
| Pause or disable a task | `enabled: false` |
| Reduce cron frequency | hourly → 2x/day |
| Remove Telegram skip-notify | remove spurious on-pause message |
| Add `background_jobs_paused` gate | missing gate → add it |
| Add `usage_mode` gate | missing gate → add it |
| Add Mac CPU load gate | skip if load > threshold |
| Add alert dedupe | check `last_alerted_at` before Telegram |
| Downgrade model tier | sonnet → haiku |
| Fix quiet skip behavior | exit silently when paused |
| Fix existing bug | no scope expansion |

### NEEDS_LEVI — always ask first

| Action | Notes |
|---|---|
| Re-enable a disabled task | Verify all 5 gates first |
| Increase cron frequency | Any more runs/day |
| Create a new scheduled task | Any kind |
| Add browser/computer-use to task | Chrome MCP or screen control |
| Use Fable or Opus in a task | Always — no exceptions |
| Canvas/school action from task | Always — even read framing |
| Finance/trading action from task | Always — even paper Alpaca |
| Outgoing email or message | On Levi's behalf |
| Git push or Railway deploy | From inside a task |
| Expand task scope | New steps, APIs, or outputs |

### AUTO_BLOCK — always reject, log, surface in report

- Telegram notify-on-pause (every skip burns a Claude session)
- Task missing `background_jobs_paused` gate
- Task missing `usage_mode` gate
- Task firing more than once per hour without P0 justification
- Task that autonomously creates new scheduled tasks
- Canvas form submission or assignment upload from any task
- Financial order, transfer, or live broker action from any task
- Task that sends email/Telegram to parties other than Levi without approval

### Gate requirements before re-enabling any task

1. `usage_mode` gate — exits silently if not `'normal'`
2. `background_jobs_paused` gate — exits silently if paused
3. Quiet skip behavior — no Telegram on skipped run
4. Alert dedupe — 4h minimum cooldown between Telegram fires (per task)
5. Clear justification for why it deserves to run automatically

### Logging

Every call to `classifyScheduledTaskAction` whose result triggers an actual mutation MUST be logged to Supabase `dispatch_log`:

```json
{
  "timestamp": "ISO8601",
  "task_id": "task-name",
  "action": "reduce_frequency",
  "classification": "AUTO_ALLOW",
  "old_value": "0 * * * *",
  "new_value": "0 8,18 * * *",
  "reason": "<result.reason from classifier>",
  "policy_version": "2026-07-07-v1",
  "initiated_by": "dispatch | levi | <task-name>"
}
```

---

## Scheduled Task Requirements

Before proposing any new recurring task, define:
- Exact purpose
- Exact allowed actions
- Exact forbidden actions
- Model and usage budget
- Max runtime
- Max resources/files processed per run
- Writeback location
- Failure behavior
- Notification behavior
- Approval boundaries

**Default nightly mode:** report-only, local/free model preferred, no paid usage unless approved, no external sending unless pre-approved, no auto-implementation unless the task is pre-approved, checkpoint everything.

---

## In-Scope Sprint Reference

The currently approved sprint scope (week of June 30, 2026):
- Fix1: Finance.tsx / Control / PendingDecisions — **COMPLETE**
- Fix2: ROUTIG_TIERS typo / Ollama fallback alert — **COMPLETE**
- P0.2: Shared state schema (routing_logs, task_registry, dashboard_health) — **COMPLETE**
- P0.3: /api/health endpoint + /api/exec gateway — **COMPLETE**
- P0.4: Noise reduction for scheduled tasks — **IN PROGRESS**
- Fix3: Wire Railway crons (config, no code) — **NEXT**

Any work within these items is Level 0/1. New major work outside this list is Level 2 — propose first.

---

## Known Safe Defaults

| Action | Level | Notes |
|--------|-------|-------|
| Editing alahmar-os repo files | 0-1 | Must be in-scope |
| Committing to GitHub | 1 | Never `.env.local`, never secrets |
| Updating scheduled task prompts | 1 | Clarity/bug fixes only, not new tasks |
| Running `npx tsc --noEmit` | 0 | Always safe to verify |
| Reading Supabase (anon key) | 0 | Read-only |
| Writing to Supabase (service key) | 1 | Logs/facts only, not migrations |
| Running Supabase SQL migrations | 3 | Always manual — Levi clicks Run |
| Sending Telegram messages | 2 | Only via pre-approved scheduled tasks |
| Chrome computer-use | 2 | Requires request_access |
| Deploying | 3 | Never auto-deploy |
| Deleting data | 3 | Always ask |
