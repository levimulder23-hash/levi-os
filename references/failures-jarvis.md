# failures.md — Known Anti-Patterns & Mistakes

A living log of bugs, wrong turns, and anti-patterns that have occurred in this codebase. Read this before making changes. Add entries when something breaks.

---

## Supabase

### Anon Key Insert Failures with RLS

**What happened:** API routes that used the anon `supabase` client (not `supabaseAdmin()`) to insert rows silently failed when Row Level Security was enabled on the table. No error was thrown in development; data just didn't appear.

**What not to do:** Never use `import { supabase } from '@/lib/supabase'` inside API routes for writes (or reads on RLS-protected tables).

**The fix:** Always use `supabaseAdmin()` (service role) in server-side API routes. It bypasses RLS. Reserve the anon `supabase` client for client components where RLS is intentional.

---

## Gmail / Email

### send_email Skill Fails — Wrong OAuth Scope

**What happened:** The `send_email` Jarvis skill (`app/api/jarvis/skills/send-email.ts`) returns "permission denied" at runtime. The OAuth refresh token was generated with `gmail.readonly` scope only.

**What not to do:** Don't call `sendEmail()` from `lib/gmail.ts` until the token is regenerated.

**The fix:** Regenerate the OAuth refresh token with `gmail.send` scope added. See the comment block at the top of `lib/gmail.ts` for upgrade steps.

---

## Google Calendar

### create_calendar_event Doesn't Sync to Google Calendar

**What happened:** The `create_calendar_event` Jarvis skill writes to the Supabase `calendar_events` table only. Events appear in the alahmar-os dashboard but not in the native Google Calendar app.

**What not to do:** Don't tell Levi that a calendar event was "added to your calendar" without clarifying it's the alahmar-os dashboard calendar only.

**The fix:** Implement Google Calendar API write scope and push the event via the Google Calendar REST API after inserting into Supabase. Blocked on OAuth scope expansion.

---

## Dispatch / Routing

### Gemini Tier Hallucinates Tool-Call XML for Email Queries

**What happened:** Email-intent queries were previously routed to the Gemini tier (`GOOGLE_ECOSYSTEM_INTENT`). Gemini has zero real tool access on this route — it responded with hallucinated tool-call XML text (e.g., `<tool_call>check_email...</tool_call>`) instead of actually reading the inbox.

**What not to do:** Don't add email/inbox patterns back to `GEMINI_PATTERNS` in `lib/dispatch-router.ts`. Gemini on this path cannot use the real `check_email` tool (only Sonnet can, via `JARVIS_TOOLS`).

**The fix:** Removed all Gmail/email patterns from `GEMINI_PATTERNS` on 2026-06-20. Email queries now fall through to Sonnet by default.

---

## Vercel Cron

### Free Tier Cron Runs Once Daily, Not Every 15 Minutes

**What happened:** `vercel.json` schedules `jarvis-monitor` at `*/15 * * * *` (every 15 minutes). On the Vercel free tier, cron jobs are limited to once per day. The schedule silently runs at a reduced frequency without error.

**What not to do:** Don't assume `jarvis-monitor` is running every 15 minutes in production unless Vercel Pro is confirmed active.

**The fix:** Either upgrade to Vercel Pro for fine-grained cron, or use an external cron service (e.g., cron-job.org, Render) that can hit the endpoint every 15 minutes.

---

## GitHub

### Wrong Repo Owner in CLAUDE.md / AGENTS.md

**What happened:** Both `CLAUDE.md` and `AGENTS.md` reference the GitHub repo as `levimulder/alahmar-os`. The actual repo owner in `.env.local` (and verified working) is `levimulder23-hash/alahmar-os`.

**What not to do:** Don't use `levimulder` as the GitHub repo owner in API calls. GitHub API calls to `levimulder/alahmar-os` will 404.

**The fix:** Use `GITHUB_OWNER=levimulder23-hash` and `GITHUB_REPO=alahmar-os` from `.env.local`. Do not commit `.env.local`. The CLAUDE.md and AGENTS.md GitHub Push Pattern examples should be updated to reflect the correct owner.

---

## Cowork / Scheduled Tasks

### Cowork Sandbox Cannot Write to /Users/levimulder/Claude/Scheduled/

**What happened:** Cowork mode's Linux sandbox does not have write access to `/Users/levimulder/Claude/Scheduled/`. Attempts to create or Update scheduled task SKILL.md files there from the sandbox will fail silently or with a permission error.

**What not to do:** Don't try to write scheduled task files from the Bash tool inside a Cowork session.

**The fix:** Use the `mcp__scheduled-tasks__create_scheduled_task` or `mcp__scheduled-tasks__update_scheduled_task` MCP tools, which operate through the native layer with correct permissions.

---

## Next.js / TypeScript

### AGENTS.md Note — This Is Not Standard Next.js

**What happened:** This repo uses Next.js 16 (cutting-edge), which has breaking API and convention changes from Next.js 13/14 that agents may have in training data.

**What not to do:** Don't assume standard Next.js patterns from training data are correct here. Don't use deprecated `getServerSideProps` or Pages Router patterns.

**The fix:** Read the relevant guide in `node_modules/next/dist/docs/` before writing new routes or layouts. Heed deprecation notices.

---

## Finance Component

### Finance Component Code Corruption

**What happened:** The Finance dashboard component suffered code corruption in a previous session (exact cause unknown — likely a partial write that truncated the file).

**What not to do:** Don't write large component files in a single pass without verifying the result. Don't use streaming writes for critical files.

**The fix:** Write large files iteratively, verify line counts after each write, and check for truncation before committing.

---

## Wheel / Trading Schema

### `wheel_candidates.score` Does Not Exist

**What happened:** The CLAUDE.md "Data & Resource Routing" example and the daily-improvement-loop SKILL.md (Phase 1D / Phase 2) query `wheel_candidates?select=ticker,score`. There is no `score` column — Supabase returns `42703 column wheel_candidates.score does not exist` (HTTP 400) and the query yields nothing. Confirmed live 2026-06-25.

**What not to do:** Don't select `score` from `wheel_candidates`. Don't assume a single numeric score field exists.

**The fix:** The real gating columns are `iv_pct`, `henry_checklist` (jsonb: iv_ok/price_ok/trend_ok/sector_ok/catalyst_ok/liquidity_ok), `henry_pass`, `gate_pass`, `gate_notes`, allocation_pct`, `status`, `scan_date`, plus `kronos_direction/interval/timeframes/raw`. To rank inspect candidates use `select=ticker,iv_pct,henry_pass,gate_pass,gate_notes&order=created_at.desc`.

---

## Gemini / AI Model Tiers

### `gemini-2.0-flash` Deprecated 2026-06-01

**What happened:** The Gemini tier in `lib/dispatch-router.ts` and `lib/dispatch.ts` used `gemini-2.0-flash` as the model string. Google deprecated this model on 2026-06-01, causing Gemini-tier calls to fail or fall through to Sonnet, negating the cost-saving intent of the Gemini route.

**What not to do:** Don't use `gemini-2.0-flash` as the model string — it no longer exists.

**The fix:** Replaced with `gemini-2.0-flash-lite` on 2026-06-25 in both `selectRoute()` and `estimateCost()` in dispatch-router.ts, and in `callGeminiStream()`/`callGeminiDirect()` in dispatch.ts.

### GEMINI_API_KEY Missing from Railway Env Vars

**What happened:** The Gemini free tier (via `callGeminiStream`/`callGeminiDirect` in `dispatch.ts`) requires `GEMINI_API_KEY` to be set. Without it, the code checks `process.env.GEMINI_API_KEY` and falls through to Sonnet even when the Gemini route is selected. The key is not currently in Railway env vars.

**What not to do:** Don't assume Gemini calls are working in production without confirming `GEMINI_API_KEY` is set in Railway.

**The fix:** Add `GEMINI_API_KEY` to Railway environment variables (Settings → Variables). Get the key from Google AI Studio at https://aistudio.google.com/apikey. The free tier supports `gemini-2.0-flash-lite` at no cost.

---

### IV-Rank Gate Starvation (insufficient snapshot history)

**What happened:** Every `wheel_candidates` row scans with `gate_pass=false`. As of 2026-06-25 the gate_notes explain why: IV rank is computed from only ~2 `iv_snapshots` per ticker, so it degenerates to 100% (statistically meaningless) and lands above the 30–65% wheel band. The scanner itself is healthy — `iv_snapshots` now has full 6-ticker coverage (AMD/DKNG/HOOD/NFLX/PLTR/SOFI) as of 6/24 20:35, up from 3 tickers on 6/23.

**What not to do:** Don't treat the all-false gate as a scanner bug, and don't loosen the IV band to force passes — that defeats the strategy.

**The fix:** Let IV history accumulate before the IV-rank gate is meaningful. Add a guard that the IV-rank sub-gate stays NEUTRAL (not auto-fail) until there are ≥10–20 snapshots per ticker, or seed historical IV. Expect real gate decisions ~1 week after daily snapshots run consistently.

---

## Infrastructure / Improvement Loop

### Phase 0 localhost checks ARE verifiable — use the Chrome MCP browser, not the sandbox

**What happened:** Multiple improvement-loop runs (6/23, 6/24 ×3, 6/25 am) reported Phase 0 infra (Ruflo proxy :4001, Ollama :11434, ~/.claude hook files) as "UNVERIFIABLE from the Cowork sandbox" and sent no alert. That's only half true: the bash sandbox genuinely cannot reach the Mac's localhost or filesystem — but the **Chrome MCP runs in the user's browser on the Mac**, so a `fetch('http://localhost:4001/health')` (or a direct `navigate` to it) from a Chrome MCP tab DOES reach the Mac's local services.

**What not to do:** Don't declare localhost infra "unverifiable" and skip the check. Don't rely on the bash sandbox for any localhost:* or `/Users/levimulder/.claude/*` probe — those will always look down/missing from the sandbox (false negative). Beware CORS: a cross-origin `fetch` to Ollama from a `chrome://newtab` context returns "Failed to fetch" even when Ollama is up — a TimeoutError (~4s) is a real down signal, a fast TypeError can be CORS. Cross-check timing, or `navigate` directly to the endpoint and read the page body.

**The fix:** Run Phase 0 :4001 / :11434 checks via Chrome MCP `javascript_tool` (`fetch` with `AbortSignal.timeout`) or `navigate` to the endpoint. Reserve real DOWN alerts for confirmed timeouts. Hook-file existence (`~/.claude/...`) and `launchctl` state remain genuinely unverifiable from both sandbox and browser — note them as "unchecked", don't assert missing. Restarting Ruflo still needs the Mac (launchctl/`install-ruflo.command`), so remediation is a Telegram alert to Levi.

### Ruflo proxy (:4001) found DOWN —  2026-06-25 ~3 PM PT (browser-verified)

**What happened:** First browser-verified Phase 0 check found Ruflo proxy unresponsive: `http://localhost:4001/health` times out at ~4.6s (ERR_CONNECTION_TIMED_OUT), root path fails — while Ollama on the same host answers in 6ms (200). A timeout (not instant connection-refused) suggests the process is half-up/wedged or firewalled, not cleanly stopped. Same window: `iv_snapshots` stuck at 9 rows with no 6/25 scan row — the daily IV snapshot did not write today, plausibly downstream of Ruflo routing being degraded.

**What not to do:** Don't assume Ruflo is healthy just because the LaunchAgent was once loaded. Don't try to restart it from the Cowork sandbox (`launchctl` unreachable).

**The fix:** Levi restarts it on the Mac — `launchctl kickstart -k gui/$(id -u)/com.levimulder.ruflo-proxy` or double-click `~/Desktop/ruflo-rebuild/install-ruflo.command`. Then confirm the 6/25 IV snapshot backfills.

---

## Dispatch / Code Task Execution

### `start_code_task` Silently Times Out Waiting for Workspace Approval

**What happened (2026-06-30):** Dispatch called `start_code_task` for two parallel code tasks (routing audit + local executor bridge). Both calls timed out after 180s with no output. Root cause: `start_code_task` opens a Claude Code session which prompts Levi to approve workspace trust in the Code tab. If Levi is not watching the Code tab, the approval prompt sits unanswered and the tool call times out. The 180s timeout fires, Dispatch gets an error, and the work simply didn't happen — but the Dispatch UI showed no indication that approval was needed.

**Why it timed out:**
1. `start_code_task` is a blocking call in the Dispatch session — it waits up to 180s for the Code session to start.
2. The Code session cannot start without workspace trust approval from the user.
3. The approval prompt appears in the Code tab, not in the Dispatch chat window.
4. Dispatch has no API to query whether a Code session is blocked on approval vs. actually running.
5. The 180s elapsed, the tool returned an error, and Dispatch had no information to show the user.

**What not to do:**
- Don't call `start_code_task` without first warning the user to watch the Code tab for an approval prompt.
- Don't silently retry `start_code_task` after a timeout — this creates duplicate sessions.
- Don't report the task as "running" if `start_code_task` returned a timeout error.
- Don't assume the user is watching the Code tab while the Dispatch session is active.

**Required Dispatch behavior — before calling `start_code_task`:**
1. **Warn in advance**: Call `SendUserMessage` with: "Starting a code task in [path] — if you see an approval prompt in the Code tab, please approve it. This will time out in ~3 minutes without approval."
2. **On timeout**: Catch the timeout error and immediately call `SendUserMessage` with:
   - What task was waiting
   - That it timed out waiting for workspace approval
   - Where to approve (Code tab)
   - What permission mode it was requesting (workspace trust for [path])
   - Whether it is safe (yes — read/write access to your repo only)
   - That it has NOT started; user should say "retry" or approve first
3. **Create a blocked record**: On timeout, write to `jarvis_facts` (category: `blocked_tasks`) with the task title, repo path, reason=workspace_approval_timeout, timestamp.
4. **No duplicate spawn**: Before calling `start_code_task`, check `jarvis_facts` for a recent blocked_tasks entry for the same repo path — if found and <10 min old, do not respawn.

**Template message to show user on code task approval wait:**
```
Starting a code task in /Users/levimulder/alahmar-os — please watch the Code tab for an approval prompt.
• Permission requested: workspace trust (read/write to repo)
• Safe: yes — core network access, no credentials
• Times out if not approved within ~3 minutes
```

**Template message on timeout:**
```
The code task "[title]" timed out — it was likely waiting for workspace approval in the Code tab and didn't get it.
• Repo: /Users/levimulder/alahmar-os
• Permission needed: workspace trust
• Status: NOT started — work has not begun
• To retry: say "retry [task name]" or approve the Code tab prompt first
```

**The fix:** The work was done inline instead (using bash + file tools in the Dispatch session directly). That path works correctly for alahmar-os because the workspace is already mounted.

---

## Railway / Cron

### Railway Ignores `vercel.json` Crons — Must Configure in Railway Dashboard

**What happened (2026-07-01):** `/api/health` reported `railway_crons: degraded` and Supabase `jarvis_facts` had zero rows for cron categories. Root cause: `vercel.json` defines crons in Vercel-specific syntax (`{ "crons": [{ "path": "...", "schedule": "..." }] }`). Railway does NOT read `vercel.json` for scheduling — it has its own Cron tab in the dashboard. `railway.toml` also had no cron config. Result: all 4 cron routes (`/api/cron/*`) never fired automatically on Railway.

**What not to do:** Don't assume `vercel.json` cron definitions are respected on Railway. Don't add cron schedules to `vercel.json` expecting them to work on Railway.

**The fix:** Configure cron jobs in the Railway dashboard → project → Cron tab. Alternatively, use an external scheduler (cron-job.org, Render cron) pointing to `https://alahmar-os-production.up.railway.app/api/cron/{name}`. The 4 crons needed:

| Path | Schedule (UTC) |
|------|----------------|
| `/api/cron/morning-brief` | `0 15 * * *` |
| `/api/cron/weekly-synthesis` | `0 8 * * 0` |
| `/api/cron/refresh-stocks` | `30 19 * * 1-5` |
| `/api/cron/jarvis-monitor` | `*/15 * * * *` |

**Also fixed in the same audit:** All 4 cron routes now write a fire-and-forget completion record to `jarvis_facts` (category = cron name). The health check `checkRailwayCrons()` was also querying for `iv_snapshot` (wrong — that's a trading route) instead of `jarvis_monitor`. Both fixed in commits b5416749–d8eb88da.

---

## Execution / Last-Mile

### Cowork Computer-Use Cannot Type Into Terminal (Click-Only Tier)

**What happened (2026-06-30):** When Ruflo was down, the Dispatch/Cowork session used the computer-use MCP to try to interact with Terminal. Terminal is in the "click-only" tier — visible and left-clickable, but typing and key presses are blocked. The session correctly diagnosed the Ruflo issue but ended up telling Levi to paste commands manually.

**Why this is wrong:** Cowork/Dispatch sessions have direct bash access via `mcp__workspace__bash`. There is NO need to use computer-use to type into Terminal. The bash tool runs in a sandboxed Linux env (not on the Mac) but has the Mac's filesystem mounted at `/sessions/optimistic-sweet-darwin/mnt/`. Mac-local commands (lsof, launchctl, curl localhost) CANNOT be run from this sandbox — they only work from the Mac shell.

**The capability boundary:**
- `mcp__workspace__bash`  — runs in a Linux sandbox; CAN: read/write mounted Mac files, run npm/node/git, typecheck; CANNOT: reach Mac localhost services, run launchctl, lsof Mac processes
- Chrome MCP `javascript_tool` — runs in Mac browser; CAN: fetch Mac localhost services (Ruflo :4001, Ollama :11434); CANNOT: write files, run shell commands
- Computer-use `mcp__computer-use__*` — controls Mac GUI; Terminal is click-only (no typing); browsers are read-only; everything else is full

**What not to do:**
- Don't try to type into Terminal via computer-use — it's click-only.
- Don't tell Levi to "paste this command" when bash can do the file work directly.
- Don't use bash to probe Mac localhost services — use Chrome MCP `javascript_tool` for that.
- Don't declare Mac-local ops impossible — they go through the `LOCAL_OPS` whitelist (see `lib/local-ops.ts`).

**The fix:** Use `lib/local-ops.ts` named operations. For read-only Mac-local checks (port, Ruflo, Ollama): Chrome MCP `javascript_tool`. For filesystem work: bash. For Mac process management (launchctl, kill): create an execution ticket or ask for explicit approval, then guide the user to approve and execute via the named op.

---

## Scheduled Tasks / Telegram

### morning-market-brief Failed Silently — Dashboard Session Expired AND Telegram Bot Token Invalid

**What happened (2026-07-21 ~6am PT):** The `morning-market-brief` scheduled task's Step 0 preflight gate (`GET /api/jarvis/preflight-gate`) redirected to `/login` instead of returning JSON — the dashboard session cookie had expired, so `credentials: 'include'` sent no valid auth. Per the task's own error handling, this should trigger a Telegram failure notification. But the fallback notification *also* failed: `https://api.telegram.org/bot8902988618:AAFcMT.../getMe` returned `{"ok":false,"error_code":401,"description":"Unauthorized"}` — the bot token itself is revoked or wrong, not a one-off request error. Confirmed via direct `getMe` call (no chat_id involved), so this isn't a chat_id/permissions issue — the token is dead.

**Why this is bad:** Both the primary check (preflight gate) and the designated failure-escape-hatch (Telegram alert) were down at the same time, so the run produced zero signal to Levi. A scheduled task can fail completely invisibly if the notification channel itself is broken.

**What not to do:** Don't assume the Telegram bot token in `morning-market-brief`'s SKILL.md (or any scheduled task file) is still valid without testing `getMe` occasionally. Don't rely solely on Telegram as the single point of failure notification for scheduled tasks — if Cowork can't reach Levi via Telegram, there's currently no secondary channel.

**The fix (not yet applied — needs Levi):**
1. Regenerate/verify the Telegram bot token via @BotFather and update it in the `morning-market-brief` SKILL.md (and any other scheduled task files using the same token).
2. Log into `https://alahmar-os-production.up.railway.app` in Chrome to renew the dashboard session so `/api/jarvis/preflight-gate` stops redirecting to `/login`.
3. Consider adding a secondary out-of-band alert path (e.g. writing a `NEEDS_LEVI` flag file or `jarvis_facts` row) for cases where Telegram itself is unreachable, so failures aren't fully silent.
