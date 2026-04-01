#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS=(
  shaping
  framing-doc
  kickoff-doc
  breadboarding
  breadboard-reflection
)

for skill in "${SKILLS[@]}"; do
  mkdir -p \
    "$ROOT/.agents/skills/$skill/agents" \
    "$ROOT/plugins/shaping-skills/skills/$skill/agents"

  cp "$ROOT/$skill/SKILL.md" "$ROOT/.agents/skills/$skill/SKILL.md"
  cp "$ROOT/$skill/agents/openai.yaml" "$ROOT/.agents/skills/$skill/agents/openai.yaml"

  cp "$ROOT/$skill/SKILL.md" "$ROOT/plugins/shaping-skills/skills/$skill/SKILL.md"
  cp "$ROOT/$skill/agents/openai.yaml" "$ROOT/plugins/shaping-skills/skills/$skill/agents/openai.yaml"

  if [[ -d "$ROOT/$skill/references" ]]; then
    mkdir -p \
      "$ROOT/.agents/skills/$skill/references" \
      "$ROOT/plugins/shaping-skills/skills/$skill/references"

    cp -R "$ROOT/$skill/references/." "$ROOT/.agents/skills/$skill/references/"
    cp -R "$ROOT/$skill/references/." "$ROOT/plugins/shaping-skills/skills/$skill/references/"
  fi
done

echo "Synced canonical skills into .agents/skills and plugins/shaping-skills/skills."
