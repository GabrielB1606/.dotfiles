# OpenCode Skills

## Hermes Skills Integration

All Hermes skills are available in OpenCode via symlinks:
- Skill categories symlinked from `~/.hermes/skills` to `~/.config/opencode/skills/hermes/`
- 59 Hermes skills with original IDs
- The conflicting `opencode` skill renamed to `hermes-opencode-delegate` by folder structure

This provides access to 60 Hermes skills including:
- **Software development**: codebase-inspection, github, systematic-debugging, test-driven-development, code-review, hermes-opencode-delegate
- **Creative**: architecture-diagram, ascii-video, design-md, manim-video, p5js, humanizer
- **Productivity**: obsidian, notion, airtable, box, document-to-action-items, meeting-action-items
- **Media**: youtube-content, gif-search, songsee, rss-feeds
- **Research**: arxiv, grounded-citations, competitor-news-monitor, product-price-monitor
- **Email**: email-inbox-triage, himalaya
- **Integrations**: apple-notes, imessage, google-workspace, teams-meeting-pipeline
- **And many more...**

## Skill ID Conflict Resolution

The `opencode` skill exists in both Hermes and OpenCode with different purposes:

| Version | ID | Purpose | Use Case |
|---------|----|----|----------|
| **OpenCode (built-in)** | `opencode` | Documentation about OpenCode itself | Configuring and understanding OpenCode |
| **Hermes** | `hermes-opencode-delegate` | Delegate coding to OpenCode CLI | Running OpenCode as a tool from Hermes |

### How It Works

The Hermes skill is accessible through OpenCode's symlink structure:
- The skill lives in the real filesystem at `~/.hermes/skills/autonomous-ai-agents/opencode/`
- Inside OpenCode, it's linked under the folder name `hermes-opencode-delegate`
- This folder name becomes the skill ID, preventing the conflict
- OpenCode's built-in `opencode` skill remains untouched

**Use in OpenCode:**
- `@opencode` → OpenCode's built-in documentation skill
- `@hermes-opencode-delegate` → Hermes' delegation skill

## How It Works

1. **Symlink setup**: `link-hermes-skills.sh` creates:
   - Category-level symlinks for all Hermes skill categories
   - Per-skill symlinks for `autonomous-ai-agents`, with the `opencode` skill linked under `hermes-opencode-delegate`
2. **Auto-discovery**: OpenCode discovers all skills from the symlinked directory structure
3. **Skill IDs**: OpenCode derives IDs from the folder containing `SKILL.md`, so:
   - `hermes-opencode-delegate/SKILL.md` → ID: `hermes-opencode-delegate`
   - `architecture-diagram/SKILL.md` → ID: `architecture-diagram`
4. **All 60 skills available**: 59 with original IDs + 1 renamed

## Requirements

Hermes skills may require their prerequisites (tools/commands) to function:
- `codebase-inspection` requires `pygount`
- `github` requires git and GitHub CLI authentication
- `obsidian` requires Obsidian to be installed
- And so on...

If a skill's prerequisites aren't installed, the skill will load but fail gracefully when executed.

## Maintenance

- Symlinks are created and rebuilt by `link-hermes-skills.sh`
- Run `link-hermes-skills.sh` independently when Hermes adds new skill categories or agents
- `setup-opencode.sh` calls it during initial setup
- Hermes skill updates appear immediately in OpenCode (no restart needed)
- OpenCode's built-in skills remain unaffected

## Troubleshooting

**Missing skills?**
- Ensure Hermes is installed: `which hermes`
- Check symlinks: `ls -la ~/.config/opencode/skills/hermes/`
- Rebuild links: `~/.dotfiles/link-hermes-skills.sh`

**Skill loads but fails?**
- Check prerequisites: read the skill's SKILL.md documentation
- Verify tools are installed and configured
- Some skills require authentication (GitHub, Google, etc.)

**Can't find the Hermes opencode skill?**
- It's accessible as `@hermes-opencode-delegate` to avoid conflict with OpenCode's built-in `opencode` skill
- Use `@hermes-opencode-delegate` in your prompts



