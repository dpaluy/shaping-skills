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

check_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    echo "Missing file: $path" >&2
    exit 1
  }
}

for skill in "${SKILLS[@]}"; do
  check_file "$ROOT/$skill/SKILL.md"
  check_file "$ROOT/$skill/agents/openai.yaml"
  check_file "$ROOT/.agents/skills/$skill/SKILL.md"
  check_file "$ROOT/.agents/skills/$skill/agents/openai.yaml"
  check_file "$ROOT/plugins/shaping-skills/skills/$skill/SKILL.md"
  check_file "$ROOT/plugins/shaping-skills/skills/$skill/agents/openai.yaml"

  rg -q '^name:' "$ROOT/$skill/SKILL.md"
  rg -q '^description:' "$ROOT/$skill/SKILL.md"

  cmp -s "$ROOT/$skill/SKILL.md" "$ROOT/.agents/skills/$skill/SKILL.md"
  cmp -s "$ROOT/$skill/agents/openai.yaml" "$ROOT/.agents/skills/$skill/agents/openai.yaml"
  cmp -s "$ROOT/$skill/SKILL.md" "$ROOT/plugins/shaping-skills/skills/$skill/SKILL.md"
  cmp -s "$ROOT/$skill/agents/openai.yaml" "$ROOT/plugins/shaping-skills/skills/$skill/agents/openai.yaml"

  if [[ -d "$ROOT/$skill/references" ]]; then
    while IFS= read -r -d '' ref; do
      rel="${ref#$ROOT/$skill/}"
      check_file "$ROOT/.agents/skills/$skill/$rel"
      check_file "$ROOT/plugins/shaping-skills/skills/$skill/$rel"
      cmp -s "$ROOT/$skill/$rel" "$ROOT/.agents/skills/$skill/$rel"
      cmp -s "$ROOT/$skill/$rel" "$ROOT/plugins/shaping-skills/skills/$skill/$rel"
    done < <(find "$ROOT/$skill/references" -type f -print0)
  fi
done

jq -e '
  .name == "shaping-skills" and
  .skills == "./skills/" and
  .interface.displayName == "Shaping Skills"
' "$ROOT/plugins/shaping-skills/.codex-plugin/plugin.json" >/dev/null

jq -e '
  .name == "shaping-skills" and
  .interface.displayName == "Shaping Skills" and
  (.plugins | length) == 1 and
  .plugins[0].name == "shaping-skills" and
  .plugins[0].source.path == "./plugins/shaping-skills"
' "$ROOT/.agents/plugins/marketplace.json" >/dev/null

echo "Skill layout and Codex packaging look valid."
