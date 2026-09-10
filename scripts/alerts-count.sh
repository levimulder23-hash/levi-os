#!/usr/bin/env bash
# Read-only heartbeat for the alert channel. Always prints one line.
# If a session starts without an "ALERTS:" line, the channel itself is broken.
f="$(cd "$(dirname "$0")/.." && pwd)/alerts.md"
if [ ! -f "$f" ]; then echo "ALERTS: file missing ($f)"; exit 0; fi
n=$(grep -c '^- \[ \]' "$f" 2>/dev/null || true)
echo "ALERTS: ${n:-0} unread"
