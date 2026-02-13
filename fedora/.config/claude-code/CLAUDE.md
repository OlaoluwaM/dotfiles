# Global Claude Code Context

## Agent Context Hub

`/home/olaolu/Desktop/agent-context` is a persistent shared context space. Before starting any task, check it for:

- `user-context.md` — Olaolu's profile, stack, preferences, and communication style
- `decisions.md` — Log of important decisions
- `quick-reference/` — Reusable guides and references
- Project directories — Session artifacts grouped by topic, each with its own README

This space is where you (Claude) create, ideate, and store whatever you need to better assist Olaolu across sessions. Use it freely — it exists for that purpose.

## Terminology

- **"Your space"** / **"your directory"** — refers to `/home/olaolu/Desktop/agent-context`, the agent context hub above.

## Digital Brain / Notes

When Olaolu refers to his "digital brain", "my notes", or similar — he means his Obsidian vault at `/home/olaolu/Desktop/digital-brain/`. This is a Zettelkasten-style collection of 500+ notes in his own voice, covering programming, philosophy, systems design, and more. Also useful for calibrating his tone and phrasing when writing on his behalf.

### Creating Notes in the Vault

- **"Create a note in my vault"** means place it in the **Agent's Desk** folder: `/home/olaolu/Desktop/digital-brain/Agent's Desk/`
- **Frontmatter style**: Use the current Obsidian properties format (no banners). Reference the template at `Extras/Templates/Basic.md` for the pattern:
  ```yaml
  ---
  aliases:
  Up:
  tags:
  Related Notes:
  External Links:
  ---
  ```
  Include only the fields that are relevant (e.g., `tags` is usually sufficient for Agent's Desk notes).
- **Tags**: Never create new tags without Olaolu's explicit permission. Only use tags that already exist in the vault.
