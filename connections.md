# Connections

Registry of every system this OS can reach. "Documented" is not "connected". Update **Last verified** only after a successful read. Never store credentials here; save query patterns under `references/{tool}-api.md` once verified.

| # | Domain | Tool | Mechanism | Auth | Status | Last verified |
|---|---|---|---|---|---|---|
| 1 | Revenue / financials | Bank accounts (personal, Alahmar Relay), Whop/Stripe (Amplify), Xero (Alahmar) | not yet connected | — | documented | — |
| 2 | Customer interactions | Slack (Amplify), iMessage (Alahmar clients), Whop community | not yet connected | — | documented | — |
| 3 | Calendar | Google Calendar (levimulder23@gmail.com) | mcp (Claude connector) | connector | **read verified** (4 calendars listed; events read for 10–11 Sep) | 2026-09-10 |
| 4 | Communication | Gmail (levimulder23@gmail.com) | mcp (Claude connector) | connector | **read verified** (Sent search + message read) | 2026-09-10 |
| 5 | Project / task tracking | none (chat + head); Amplify `workstreams/index.md`; Alahmar `_PA/` | local files | — | available | 2026-09-10 |
| 6 | Meeting intelligence | none in use | — | — | gap | — |
| 7 | Knowledge / files | Google Drive (Alahmar), local `~/Amplify`, `~/Alahmar`, Obsidian vault (archive), `~/Desktop/Claude Notes` (archive) | Drive mcp connector; local filesystem | connector | Drive connector present, no read yet | — |
| 8 | Web research | Firecrawl, Supadata (transcripts), Context7 (docs) | mcp | keys in Claude app config | used in this session | 2026-09-10 |
| 9 | Browser | Claude in Chrome, Playwright plugin, in-app Browser pane | mcp | — | used in this session | 2026-09-10 |
| 10 | Scheduling | Claude Code scheduled-tasks MCP; Cowork scheduled tasks | mcp | — | present; **do not schedule anything until the automation gate is met** | 2026-09-10 |
| 11 | Legacy (frozen) | Supabase (alahmar-os), Alpaca, Plaid, Telegram bot, Ruflo proxy, Ollama, Obsidian REST MCP | archived | — | see `ai-os/parts-bin.md` | — |
