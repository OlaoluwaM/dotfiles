# Global Claude Code Context

Cross-agent preferences and behavior are loaded from the canonical source of truth:

@~/Desktop/agent-context/Context/Global Preferences.md

The rest of this file is **Claude-specific extras** — mechanisms that don't port to other agents.

---

## Claude-Specific Extras

### Research delegation mechanism

Global Preferences says "delegate deep research to a subagent or helper if your agent supports it." For Claude Code, that means spawning via the `Agent` tool with `subagent_type=general-purpose` or `subagent_type=Explore`. Reserve inline searches for quick, directed lookups.

### Slash command index

Slash commands live in `~/.claude/commands/` as thin shims that direct Claude to read and follow the corresponding `SKILL.md` under `~/Desktop/agent-context/Skills/` (the vault-canonical source). Research Mode and Study Mode skills in turn delegate to their full protocols in `Reference/`.

| Command | Description |
|---|---|
| `/brainstorm` | Socratic thinking partner — nudges toward answers, doesn't give them |
| `/blog-ideas` | Surfaces blog post ideas from the digital-brain vault |
| `/post-ideas` | Surfaces social media post ideas from the digital-brain vault |
| `/write` | Writing assistant calibrated to Olaolu's voice |
| `/draft-first` | Learning-protective note creation — Olaolu drafts first, Claude fills gaps |
| `/research` | Full research mode — wraps `Reference/Research Framework.md` |
| `/study` | Study session mode — wraps `Reference/Study Mode.md` |
| `/adr` | Write an Architectural Decision Record in the Michael Nygard style |

### Agent Skills

Model-invoked Agent Skills under `~/.claude/skills/` are symlinks into the vault's `Skills/` zone (`~/Desktop/agent-context/Skills/`). Edit the vault canonical, never the symlinked copy. See [[Skills MOC]] for the skill lifecycle (add / update / remove) and the full symlink map.

### Auto-memory

Persistent memory lives at `~/.claude/projects/<project-id>/memory/`. `MEMORY.md` is the index; individual entries are separate files. Rules, structure, and when-to-save guidance come from the system's auto-memory instructions (loaded into every session automatically).

### Sub-agent usage

When a task spans multiple angles, is research-heavy, or would burn a lot of main-context tokens reading files, prefer spawning a sub-agent (`Agent` tool) over doing it inline — but only when the user explicitly asks or when it clearly pays for itself. Don't default to subagents for tasks a single well-targeted tool call can handle.

### Saving to memory

Before saving any preference or directive to memory, suggest the best placement options with reasoning for each (`Context/Global Preferences.md` in the vault, a memory file, the vault's `AGENTS.md`, etc.). Do not commit until Olaolu confirms.
