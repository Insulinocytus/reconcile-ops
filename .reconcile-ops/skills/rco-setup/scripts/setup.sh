#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
RCO_DIR="$ROOT/.reconcile-ops"
CONFIG="$RCO_DIR/config.json"
EXAMPLES_DIR="$RCO_DIR/examples"
TOOLS=(gh jq rg curl)
EXAMPLE_FILES=(requirement.md goal.md goal-issue.md pr.md spec.md)

usage() {
  cat <<'USAGE'
Usage:
  setup.sh [--language en|zh|jp]

Idempotently installs required tools when possible, writes .reconcile-ops/config.json,
and points .reconcile-ops/examples/*.md symlinks at the selected language folder.
USAGE
}

LANGUAGE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --language)
      LANGUAGE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

install_tool() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    echo "ok: $tool already installed"
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    echo "install: $tool"
    brew install "$tool"
    return
  fi

  echo "missing: $tool" >&2
  echo "Install Homebrew or install $tool manually, then re-run this script." >&2
  exit 1
}

for tool in "${TOOLS[@]}"; do
  install_tool "$tool"
done

mkdir -p "$RCO_DIR" "$EXAMPLES_DIR/en" "$EXAMPLES_DIR/zh" "$EXAMPLES_DIR/jp"

if [[ -z "$LANGUAGE" ]]; then
  if [[ -f "$CONFIG" ]]; then
    LANGUAGE="$(jq -r '.preferred_language // empty' "$CONFIG")"
  fi
fi

if [[ -z "$LANGUAGE" ]]; then
  printf "Preferred language (en/zh/jp): "
  read -r LANGUAGE
fi

case "$LANGUAGE" in
  en|zh|jp) ;;
  *)
    echo "Invalid language: $LANGUAGE. Expected en, zh, or jp." >&2
    exit 1
    ;;
esac

tmp_config="$(mktemp)"
printf '{\n  "preferred_language": "%s"\n}\n' "$LANGUAGE" > "$tmp_config"
if [[ ! -f "$CONFIG" ]] || ! cmp -s "$tmp_config" "$CONFIG"; then
  mv "$tmp_config" "$CONFIG"
  echo "updated: $CONFIG"
else
  rm "$tmp_config"
  echo "ok: $CONFIG already set to $LANGUAGE"
fi

for file in "${EXAMPLE_FILES[@]}"; do
  link="$EXAMPLES_DIR/$file"
  target="$LANGUAGE/$file"

  if [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$target" ]]; then
    echo "ok: $link -> $target"
    continue
  fi

  if [[ -e "$link" ]] || [[ -L "$link" ]]; then
    rm "$link"
  fi

  ln -s "$target" "$link"
  echo "linked: $link -> $target"
done

echo "setup complete"
