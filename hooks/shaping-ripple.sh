#!/bin/bash
# shaping-ripple.sh — Reminds Claude to check ripple effects when editing shaping docs.
# Requires: jq

if ! command -v jq &>/dev/null; then
  echo "WARNING: jq is not installed. Skipping shaping-ripple hook." >&2
  exit 0
fi

FILE=$(jq -r '.tool_input.file_path // empty')
if [[ "$FILE" == *.md && -f "$FILE" ]]; then
  # Check for YAML frontmatter delimited by ---
  # Use head -20 to cover multi-line frontmatter, then extract content
  # between opening --- and closing ---
  if head -20 "$FILE" 2>/dev/null | awk '/^---$/{n++; next} n==1{print}' | grep -q '^shaping: true'; then
    cat >&2 <<'MSG'
Ripple check:
- Updated a Breadboard diagram? → Affordance tables are the source of truth. Update tables FIRST, then render to Mermaid
- Changed Requirements? → update Fit Check + any Gaps, Open Questions by Part
- Changed Shape (A, B...) Parts? → update Fit Check + any Gaps, Open Questions by Part
- Changed Work Streams Detail? → update Work Streams Mermaid
MSG
    exit 2
  fi
fi
exit 0
