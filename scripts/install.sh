#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage:
  scripts/install.sh [--dry-run]

Installs this repository's skills, harness rules, and automations into
${CODEX_HOME:-$HOME/.codex}.
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

copy_dir() {
  local src="$1"
  local dst="$2"
  if [ "$DRY_RUN" = "1" ]; then
    echo "Would sync ${src} -> ${dst}"
  else
    mkdir -p "$dst"
    rsync -a --exclude '.DS_Store' "${src}/" "${dst}/"
  fi
}

copy_file() {
  local src="$1"
  local dst="$2"
  if [ "$DRY_RUN" = "1" ]; then
    echo "Would copy ${src} -> ${dst}"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
  fi
}

copy_dir "$ROOT/skills" "$CODEX_HOME/skills"
copy_dir "$ROOT/harness/rules" "$CODEX_HOME/rules"
copy_file "$ROOT/harness/AGENTS.md" "$CODEX_HOME/AGENTS.md"
copy_dir "$ROOT/automations" "$CODEX_HOME/automations"

echo "Installed Harden harness into ${CODEX_HOME}"
