# Workflow: daily-brief

Objective: one trustworthy page, `today.md`, that tells Levi what matters today. Ported from `~/Alahmar/.claude/skills/daily-brief` (May 2026) and the Jarvis morning-brief tiers. Phase 4 of the OS plan: run BY HAND at least 5 times, logging "wrong: …" each time, before it is ever scheduled.

Inputs (read; never invent)
1. `context/priorities.md` — check `valid-until`; if past, say so at the top.
2. `alerts.md` — unread lines.
3. Google Calendar (MCP `list_events`): today and tomorrow, Levi's timezone (Europe/London while in London).
4. Gmail (MCP `search_threads`): `is:unread newer_than:2d` — subjects and senders only; no bodies unless needed to classify.
5. `school-os/fie-london.md`, `life-os/admin-travel.md`, `alahmar-os/README.md`, `amplify-os/README.md` — open items.
6. Yesterday's `today.md` (if present) — carry forward unchecked items.

Steps
1. Read all inputs. If a source cannot be read, write "not checked: <source> (<reason>)" — never fill the gap.
2. Classify every item into one tier: **must_interrupt** (deadline today, money, health, someone blocked), **important_today**, **nice_to_know**, **background_only**.
3. Write `today.md` with the template below. Keep it under 40 lines.
4. Print the "Must-do" section to chat, then one question if there is something only Levi can decide.
5. Append one line to `decisions/log.md` under "## daily-brief hand runs": `- <date> run #N — wrong: <what Levi corrected, or "nothing yet">`.

Template (`today.md`)
```
# Today — <Weekday, D Month YYYY> (<timezone>)
priorities valid-until: <date> <OK | STALE>
alerts: <N unread>

## Must-do (must_interrupt)
- …

## Today (important_today)
- Calendar: <time> <event>  (or "no events" / "not checked")
- Inbox: <sender> — <subject> — <why it matters>

## Tomorrow
- …

## Nice to know
- …

## Not checked
- <source>: <reason>

## One question for Levi
- …
```

Definition of Done: `today.md` exists for today, every section is either filled from a read source or says "not checked", and a hand-run line was appended to `decisions/log.md`.
On failure: append `- [ ] <date> <time> daily-brief FAILED: <reason>` to `alerts.md`.

Hard rules: never send anything; never claim an email was answered or a task done; money items ≥ $500 for Alahmar carry the Article 3.3(b) reminder (75% vote).
