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

check_path() {
  local path="$1"
  local kind="${2:-file}"

  [[ -e "$path" ]] || {
    echo "Missing $kind: $path" >&2
    exit 1
  }
}

list_tree_files() {
  local dir="$1"
  (
    cd "$dir"
    find . -type f | LC_ALL=C sort
  )
}

compare_tree() {
  local source_dir="$1"
  local target_dir="$2"
  local label="$3"
  local rel

  check_path "$source_dir" "directory"
  check_path "$target_dir" "directory"

  if ! diff -u <(list_tree_files "$source_dir") <(list_tree_files "$target_dir") >/dev/null; then
    echo "File layout drift detected in $label" >&2
    diff -u <(list_tree_files "$source_dir") <(list_tree_files "$target_dir") >&2 || true
    exit 1
  fi

  while IFS= read -r rel; do
    cmp -s "$source_dir/$rel" "$target_dir/$rel" || {
      echo "Content drift detected in $label: $rel" >&2
      exit 1
    }
  done < <(list_tree_files "$source_dir")
}

for skill in "${SKILLS[@]}"; do
  check_path "$ROOT/$skill/SKILL.md"
  check_path "$ROOT/$skill/agents/openai.yaml"

  rg -q '^name:' "$ROOT/$skill/SKILL.md"
  rg -q '^description:' "$ROOT/$skill/SKILL.md"

  compare_tree \
    "$ROOT/$skill" \
    "$ROOT/.agents/skills/$skill" \
    ".agents/skills/$skill"
  compare_tree \
    "$ROOT/$skill" \
    "$ROOT/plugins/shaping-skills/skills/$skill" \
    "plugins/shaping-skills/skills/$skill"
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
