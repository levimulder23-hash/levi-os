# Decisions Log

Append-only record of meaningful decisions and why they were made. `/level-up` Phase 2 (Method interview) writes scoped automation specs here. You can also append manually whenever you decide something worth remembering.

**Format per entry:**

```
## YYYY-MM-DD — Short title

**Decision:** what was decided.

**Why:** the reasoning, constraints, and what would change your mind.

**Alternatives considered:** what else was on the table.

**Owner:** who's accountable.
```

Keep it terse. Future-you will thank present-you for capturing the *why*, not just the *what*.

---

## 2026-09-06 - Audit evidence and routing maintenance

**Decision:** Ship audit rubric v2 and a small /link skill. Audit scores working evidence across the Four Cs, checks operating-manual routing and freshness, and passes one concrete gap into /level-up. A selected repair can improve an existing workflow instead of creating another skill.

**Why:** File counts, configured keys, named rituals, and recent edits do not prove an operational AIOS. Source findability and freshness need explicit checks.

**Alternatives considered:** Keeping presence-based scoring or requiring a hot cache. Neither reliably establishes retrieval quality or successful execution.

## 2026-09-06 - Portable skills and automatic audit history

**Decision:** Ship all four skills for Claude Code and Codex, with bundled resources, matching operating manuals, and a script for regenerating Codex copies. Audit reports are saved automatically, preserve previous runs, and track findings across comparable inspections.

**Why:** Students need the same shared guidance when switching assistants and evidence of actual improvements over time. Intentional runtime adaptations, unknown verification, and confirmed defects are reported separately.

## 2026-09-06 - Portable 3D Brain skill

**Decision:** Add `/3d-brain` for Claude Code and Codex. Ask for a name and categories, map selected local folders, and scaffold a bundled, configurable application with spherical placement, Cinema, and interactive growth replay.

**Why:** Shipping the working renderer preserves the intended appearance and interactions across AIOS installations. A prose-only prompt would produce inconsistent recreations. User config and graph data remain local; the public package includes only code, documentation, dependency notices, and fictional test inputs.

## 2026-09-06 - Add ongoing context interviews

**Decision:** Adapt Herk-2's grill-me skill for the student kit and ship matching Claude/Codex packages. Save every answer to brainstorms/, preserve resumable Q&A history, and update canonical context only with confirmed facts during requested context-building sessions.

**Why:** Onboarding is an initial snapshot. Ongoing interviews capture changing priorities, decisions, and preferences while keeping tentative ideas distinct from current business facts.

---

## 2026-09-10 — Restart the AI OS small, on the AIS-OS kit, keeping the vision

**Decision:** Create `~/OS` from Nate Herk's AIS-OS kit (commit ce9cb93, fresh git history) as the single home for Levi's context, skills, and workflows. Areas as sub-OS folders (amplify-os, alahmar-os, school-os, life-os, ai-os). `~/Amplify/*` and `~/Alahmar` stay in place as separate repos ("other worlds") linked from the router. Jarvis (`~/alahmar-os`) is frozen and mined for parts; the Obsidian vault becomes a read-only archive.

**Why:** Jarvis went cadence-first (36 schedules, 25 launch agents, hooks on every prompt) with stale context and a dead alert channel; the last 200 commits governed itself. Nate's order is Context → Connections/Capabilities → Cadence, lowest autonomy that works, one skill at a time. Nested repos are a trap for a non-coder.

**Alternatives considered:** Fix alahmar-os in place (121 lib files, 80 routes Levi cannot inspect); make the Obsidian vault the home (iCloud EINTR, 1,100 scraped intel files).

**Owner:** Levi (decision, 2026-09-10); implementation by Claude Code.

## 2026-09-10 — Automation gate

**Decision:** Nothing runs unattended until (a) the alert channel (`alerts.md` + session heartbeat) is verified and (b) the skill has run by hand successfully 5 times with a "wrong: …" line logged per run. Medication reminder timers are frozen with everything else (Levi: does not rely on them).

**Why:** The Bike Method. July's failure mode was silent failure at L4 autonomy.

**Owner:** Levi.

## 2026-09-10 — Amplify never stops

**Decision:** The migration never moves, renames, or edits `~/Amplify/*`. Structure is built before the old automation is frozen, and the freeze is bracketed by an Amplify smoke test.

**Owner:** Levi.

## daily-brief hand runs
- 2026-09-10 run #1 — by hand in chat (Claude Code). Sources read: primary + school + Alahmar + LMU calendars (MCP), Gmail unread 2d (MCP), alerts.md, context. wrong: (awaiting Levi's corrections)

## 2026-09-10 — Private GitHub backups for the OS and the three Amplify repos

**Decision:** `~/OS` → github.com/levimulder23-hash/levi-os; `~/Amplify/{amplify-ops,amplify-website,amplify-media}` → same-named private repos. SSH key `~/.ssh/github_ed25519` registered on GitHub and unlocked in the macOS keychain. Pushes still require Levi's go each time (gate); the remotes exist so a push is one command.

**Why:** None of the four had a remote; the only backup was a local bundle. Nate's rule: deliverables live in git.

**Owner:** Levi (approved 2026-09-10).

## 2026-09-10 — Phase 3 freeze executed (local half)

**Done (Levi's go, 14:5x London):** all hooks removed from `~/.claude/settings.json` and `settings.local.json` (backups in `archives/dot-claude-2026-09/`); 25 launch agents unloaded and their plists moved to `~/Library/LaunchAgents/_frozen_2026-09/`; `ANTHROPIC_BASE_URL` unset and the Ruflo proxy process stopped (port 4001 closed); Ollama launch agent unloaded (the Ollama desktop app itself can still relaunch its server; quit it from the menu bar if wanted). Amplify smoke test passed after. `~/.claude` Jarvis logs/OVERSIGHT/health-assistant archived.

**Not done / not verified:** `com.levimulder.pfctl` (root daemon, needs sudo) still loaded. Railway `railway down` for the web service + 4 cron services was blocked by the Claude app's permission classifier — Levi to run or click. Vercel crons: dashboard toggle (Levi). Cowork scheduled tasks: Levi disabling in the app. The 3 Claude Code scheduled tasks no longer appear in the scheduler list (only the disabled one-time task remains); cause unclear — verify tomorrow that nothing fired at 07:37.

**Rollback:** move plists back from `_frozen_2026-09/` and `launchctl bootstrap gui/$UID <plist>`; restore the two settings backups; `launchctl setenv ANTHROPIC_BASE_URL http://localhost:4001` only if the proxy is wanted again (it is not).
