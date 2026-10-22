#!/bin/bash

# Link ~/.config/opencode to this repo and hand the vibi.top API key from
# .env to the opencode background service.
# Run it from a plain terminal: it restarts the opencode service, which ends
# any open opencode sessions.

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PKG="$DOTFILES/opencode/.config/opencode"
TARGET="$HOME/.config/opencode"

for cmd in stow opencode; do
  if ! command -v "$cmd" >/dev/null; then
    echo "$cmd is not installed" >&2
    exit 1
  fi
done

if [ ! -f "$DOTFILES/.env" ]; then
  install -m 600 "$DOTFILES/.env.example" "$DOTFILES/.env"
  echo "Created $DOTFILES/.env, add your VIBI_API_KEY to it and rerun" >&2
  exit 1
fi

set -a
. "$DOTFILES/.env"
set +a

if [ -z "${VIBI_API_KEY:-}" ]; then
  echo "VIBI_API_KEY is empty in $DOTFILES/.env" >&2
  exit 1
fi

if [ -L "$TARGET" ]; then
  if [ "$(readlink -f "$TARGET")" != "$PKG" ]; then
    echo "$TARGET already links to $(readlink -f "$TARGET"), remove it and rerun" >&2
    exit 1
  fi
elif [ -e "$TARGET" ]; then
  opencode service stop >/dev/null 2>&1 || true
  # Keep runtime state (service.json, node_modules, ...) but never overwrite
  # the config tracked in this repo
  cp -a --update=none "$TARGET"/. "$PKG"/
  BACKUP="$TARGET.bak.$(date +%s)"
  mv "$TARGET" "$BACKUP"
  echo "Moved the old $TARGET to $BACKUP"
fi

mkdir -p "$HOME/.config"
stow --dir "$DOTFILES" --target "$HOME" opencode
echo "Linked $TARGET -> $(readlink "$TARGET")"

# Stored in the service config (~/.config/opencode/service.json, gitignored).
# This stops the service; the next opencode command starts it with the key.
opencode service set env VIBI_API_KEY "$VIBI_API_KEY" >/dev/null

# Link Hermes skills into OpenCode (if Hermes is installed)
./link-hermes-skills.sh

opencode auth list
