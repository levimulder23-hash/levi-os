# Alerts

Append-only failure channel. Any workflow or scheduled task that fails appends one line here. A session-start heartbeat prints `ALERTS: N unread`; if a session starts without that line, the channel itself is broken.

Format: `- [ ] YYYY-MM-DD HH:MM <skill> FAILED: <reason>`  — tick the box when handled.

