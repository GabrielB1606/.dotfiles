#!/bin/bash

# Link Hermes skills into OpenCode with proper ID renaming for conflict resolution.
# This script can be run independently or called by setup-opencode.sh.

set -euo pipefail

if [ ! -d ~/.hermes/skills ]; then
  echo "Hermes not installed, skipping skill symlink"
  exit 0
fi

SKILLS_DIR="${1:-$HOME/.config/opencode/skills}"
mkdir -p "$SKILLS_DIR"

# Rebuild the hermes folder from scratch to pick up new skills
if [ -d "$SKILLS_DIR/hermes" ]; then
  rm -rf "$SKILLS_DIR/hermes"
fi
mkdir -p "$SKILLS_DIR/hermes"

# Symlink each Hermes category
for category in ~/.hermes/skills/*/; do
  category_name=$(basename "$category")
  
  # Skip hidden files, manifests, and system-symlinked skills
  if [[ "$category_name" == .* ]] || [[ "$category_name" == "diagnose-crash" ]] || [[ "$category_name" == "omarchy" ]]; then
    continue
  fi
  
  # For autonomous-ai-agents, handle skills individually to rename the opencode skill
  if [[ "$category_name" == "autonomous-ai-agents" ]]; then
    mkdir -p "$SKILLS_DIR/hermes/autonomous-ai-agents"
    
    for skill_dir in "$category"*/; do
      skill_name=$(basename "$skill_dir")
      
      if [[ "$skill_name" == "opencode" ]]; then
        # Rename to hermes-opencode-delegate to avoid conflict with OpenCode's built-in
        ln -s "$skill_dir" "$SKILLS_DIR/hermes/autonomous-ai-agents/hermes-opencode-delegate"
      else
        # Link other skills with original names
        ln -s "$skill_dir" "$SKILLS_DIR/hermes/autonomous-ai-agents/$skill_name"
      fi
    done
  else
    # Symlink entire category for all others
    ln -s "$category" "$SKILLS_DIR/hermes/$category_name"
  fi
done

echo "Linked Hermes skills to $SKILLS_DIR/hermes (opencode skill renamed to hermes-opencode-delegate)"
