#!/usr/bin/env bash
# Installs the footprint skill into a Claude Code skills directory and
# records the install (version + date) to a local, untracked log.
set -euo pipefail

REPO_URL="https://github.com/somasundarv/footprint.git"
TARGET_DIR="${SKILLS_DIR:-$HOME/.claude/skills}/footprint"
INSTALL_LOG="$TARGET_DIR/.install-log"

version_of() {
  grep -m1 '^version:' "$1/SKILL.md" | awk '{print $2}'
}

if [ -d "$TARGET_DIR/.git" ]; then
  echo "footprint already installed at $TARGET_DIR — updating."
  git -C "$TARGET_DIR" pull --ff-only -q
  ACTION="update"
else
  echo "Installing footprint to $TARGET_DIR"
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone -q "$REPO_URL" "$TARGET_DIR"
  ACTION="install"
fi

VERSION="$(version_of "$TARGET_DIR")"
COMMIT="$(git -C "$TARGET_DIR" rev-parse --short HEAD)"
DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

printf '%s\t%s\tversion=%s\tcommit=%s\n' "$DATE" "$ACTION" "$VERSION" "$COMMIT" >> "$INSTALL_LOG"

echo "footprint $VERSION ($COMMIT) $ACTION recorded at $DATE"
echo "Install log: $INSTALL_LOG"
