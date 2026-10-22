#!/bin/bash

# Add vibi.top provider to Hermes and set it as default.
# Appends to ~/.hermes/config.yaml and ~/.hermes/.env.

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

if ! command -v hermes >/dev/null; then
  echo "hermes is not installed" >&2
  exit 1
fi

if [ ! -f "$DOTFILES/.env" ]; then
  echo ".env not found, create it from .env.example first" >&2
  exit 1
fi

set -a
. "$DOTFILES/.env"
set +a

if [ -z "${VIBI_HERMES_API_KEY:-}" ]; then
  echo "VIBI_HERMES_API_KEY is empty in $DOTFILES/.env" >&2
  exit 1
fi

# Add vibi provider to config.yaml if not already there
if ! grep -q '  vibi:' ~/.hermes/config.yaml 2>/dev/null; then
  # Check if providers: section exists
  if ! grep -q '^providers:' ~/.hermes/config.yaml 2>/dev/null; then
    cat >> ~/.hermes/config.yaml << 'EOF'

# Vibi.top gateway provider
providers:
  vibi:
    base_url: "https://vibi.top/v1"
    key_env: "VIBI_HERMES_API_KEY"
EOF
  else
    # providers: section exists, just add vibi under it
    cat >> ~/.hermes/config.yaml << 'EOF'
  vibi:
    base_url: "https://vibi.top/v1"
    key_env: "VIBI_HERMES_API_KEY"
EOF
  fi
  echo "Added vibi provider to ~/.hermes/config.yaml"
else
  echo "vibi provider already in ~/.hermes/config.yaml"
fi

# Set vibi as default provider
if grep -q '^  provider:' ~/.hermes/config.yaml; then
  if ! grep -q '^  provider: "vibi"' ~/.hermes/config.yaml; then
    sed -i 's/^  provider: .*/  provider: "vibi"/' ~/.hermes/config.yaml
    echo "Set vibi as default provider"
  else
    echo "vibi is already the default provider"
  fi
fi

# Add key to Hermes .env if not there
if ! grep -q 'VIBI_HERMES_API_KEY' ~/.hermes/.env 2>/dev/null; then
  echo "VIBI_HERMES_API_KEY=$VIBI_HERMES_API_KEY" >> ~/.hermes/.env
  echo "Added VIBI_HERMES_API_KEY to ~/.hermes/.env"
else
  echo "VIBI_HERMES_API_KEY already in ~/.hermes/.env"
fi

echo ""
echo "Vibi provider configured for Hermes. Available models:"
hermes model --provider vibi 2>&1 | head -30 || echo "Run 'hermes model --provider vibi' to see available models"
