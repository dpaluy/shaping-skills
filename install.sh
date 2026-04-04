#!/bin/bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SKILLS=(shaping framing-doc kickoff-doc breadboarding breadboard-reflection)
SKILLS_ROOT="$REPO/skills"

if [[ ! -d "$SKILLS_ROOT" ]]; then
  SKILLS_ROOT="$REPO"
fi

usage() {
  cat <<EOF
Usage: install.sh [--project | --user]

  --project   Install into .agents/skills and .claude/skills in the current directory
  --user      Install into ~/.agents/skills and ~/.claude/skills (default)
EOF
  exit 1
}

LEVEL="${1:---user}"

case "$LEVEL" in
  --user)
    AGENTS_DIR="$HOME/.agents/skills"
    CLAUDE_DIR="$HOME/.claude/skills"
    ;;
  --project)
    AGENTS_DIR=".agents/skills"
    CLAUDE_DIR=".claude/skills"
    ;;
  *) usage ;;
esac

mkdir -p "$AGENTS_DIR" "$CLAUDE_DIR"

for skill in "${SKILLS[@]}"; do
  rm -rf "${AGENTS_DIR:?}/$skill"
  cp -R "$SKILLS_ROOT/$skill" "$AGENTS_DIR/$skill"
  ln -sfn "$AGENTS_DIR/$skill" "$CLAUDE_DIR/$skill"
done

echo "Installed ${#SKILLS[@]} skills to $AGENTS_DIR"
echo "Symlinked into $CLAUDE_DIR"
