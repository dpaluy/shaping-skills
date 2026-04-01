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

sync_skill_tree() {
  local source_dir="$1"
  local target_dir="$2"

  [[ -d "$source_dir" ]] || {
    echo "Missing source skill directory: $source_dir" >&2
    exit 1
  }

  case "$target_dir" in
    "$ROOT/.agents/skills/"*|"$ROOT/plugins/shaping-skills/skills/"*) ;;
    *)
      echo "Refusing to sync unexpected target: $target_dir" >&2
      exit 1
      ;;
  esac

  rm -rf "$target_dir"
  mkdir -p "$target_dir"
  cp -R "$source_dir/." "$target_dir/"
}

for skill in "${SKILLS[@]}"; do
  sync_skill_tree "$ROOT/$skill" "$ROOT/.agents/skills/$skill"
  sync_skill_tree "$ROOT/$skill" "$ROOT/plugins/shaping-skills/skills/$skill"
done

echo "Synced canonical skills into .agents/skills and plugins/shaping-skills/skills."
