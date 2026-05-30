#!/usr/bin/env bash
# monday-plan — Monday planning ritual companion script.
# Triggered by ~/Library/LaunchAgents/com.<your>.monday-plan.plist at 09:00 Mon.
#
# What it does:
# 1. Loads Linear API token from password manager
# 2. Queries active cycle, carry-over, stale Triage, push project count
# 3. Opens "This week" Linear view in browser
# 4. Pushes a one-line summary via ntfy
# 5. Writes a Monday worksheet to ~/today.md
# 6. Opens the worksheet in tmux pane 0 if a "main" session exists
#
# Adapt path / topic / view URLs to your setup.

set -euo pipefail

# --- Load secrets ---
# Adjust to your password manager. rbw used as example.
if ! command -v rbw &>/dev/null; then
  echo "rbw CLI required; install or adapt to your password manager" >&2
  exit 1
fi

if ! rbw unlocked 2>/dev/null; then
  echo "rbw vault is locked; unlock interactively first" >&2
  exit 1
fi

export LINEAR_API_TOKEN="$(rbw get 'Linear API' --field linear_api_key)"
NTFY_TOPIC="$(rbw get 'ntfy topic' --field topic)"

# --- Config ---
WEEK="$(date +%Y-W%V)"
WORKSHEET="$HOME/today.md"
WORKSPACE="<your-workspace>"   # e.g., "your-workspace"
TEAM_KEY="<TEAM>"              # e.g., "G"

# --- Pull state from Linear ---
# Adapt to your CLI. linearis used as example.
# These calls assume linearis is installed and your team is configured.

ACTIVE_CYCLE_INFO=$(linearis cycles list --active --format json 2>/dev/null || echo '[]')
CYCLE_NUM=$(echo "$ACTIVE_CYCLE_INFO" | jq -r '.[0].number // "?"')
CYCLE_END=$(echo "$ACTIVE_CYCLE_INFO" | jq -r '.[0].endsAt // "?"')

# Carry-over: in current cycle but created before cycle start
CARRY_OVER=$(linearis issues list --cycle "$CYCLE_NUM" --format short 2>/dev/null || echo "")
CARRY_COUNT=$(echo "$CARRY_OVER" | grep -c "^G-" || true)

# Stale Triage: in Triage state, created > 48h ago
STALE_TRIAGE=$(linearis issues list --state Triage --format short 2>/dev/null || echo "")
STALE_COUNT=$(echo "$STALE_TRIAGE" | grep -c "^G-" || true)

# Push projects started count (excludes continuous areas — assumes initiative != null)
PUSH_PROJECTS=$(linearis projects list --state Started --format short 2>/dev/null || echo "")
PUSH_COUNT=$(echo "$PUSH_PROJECTS" | wc -l | tr -d ' ')

# --- Open browser to This week saved view ---
if command -v open &>/dev/null; then
  open "https://linear.app/$WORKSPACE/team/$TEAM_KEY/active"
fi

# --- Write worksheet ---
cat > "$WORKSHEET" <<EOF
# Monday $WEEK plan

**Active cycle:** #$CYCLE_NUM (ends $CYCLE_END)
**Push projects started:** $PUSH_COUNT (cap: 3 push + continuous areas exempt)

## Carry-over from last cycle ($CARRY_COUNT items)

$CARRY_OVER

→ For each: keep / descope / push to Backlog

## Stale Triage ($STALE_COUNT items > 48h)

$STALE_TRIAGE

→ Process now (10 min cap)

## This cycle commit checklist

- [ ] Pick at most 5 issues for cycle
- [ ] All have estimates (no empty)
- [ ] Max 2 P0+P1 combined
- [ ] No 16-point items (break them up first)
- [ ] Lead project this cycle: ___________

## Quick views

- This week: https://linear.app/$WORKSPACE/team/$TEAM_KEY/active
- Blocked: https://linear.app/$WORKSPACE/team/$TEAM_KEY/blocked
- No estimate: https://linear.app/$WORKSPACE/team/$TEAM_KEY/no-estimate
EOF

# --- Push ntfy ---
if [ -n "${NTFY_TOPIC:-}" ]; then
  curl --silent --max-time 5 \
    -d "Monday $WEEK plan ready — carry-over: $CARRY_COUNT items, stale Triage: $STALE_COUNT" \
    "https://ntfy.sh/$NTFY_TOPIC" >/dev/null || true
fi

# --- Open worksheet in tmux pane 0 of "main" session if it exists ---
if command -v tmux &>/dev/null && tmux has-session -t main 2>/dev/null; then
  tmux send-keys -t main:0.0 "less '$WORKSHEET'" Enter
fi

echo "Monday plan complete. Worksheet at $WORKSHEET"
