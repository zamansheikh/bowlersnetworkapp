# BowlersNetwork — Mobile App Skill Docs

These docs are designed to be installed as **Claude Code skills** on your machine. Once installed, Claude Code will load them automatically when you reference them via slash commands (e.g., `/ui-ux-design`).

---

## What's In This Folder

| File | Purpose | Load when... |
|---|---|---|
| `system-knowledge.md` | Platform overview — what BowlersNetwork is, how it's structured, what the mobile app fits into. | Starting any session. Always load first. |
| `app-knowledge.md` | Flutter stack, architecture, API integration, auth, WebSocket, routing, performance. | Implementing any feature. |
| `ui-ux-design.md` | Visual design system translated to Flutter — colors, typography, spacing, component patterns, anti-patterns. | Building any UI widget. |

These three docs together give Claude Code the full context to build the BowlersNetwork mobile app consistently with the web frontend's design language.

---

## How to Install as Claude Code Skills

Claude Code skills live in `~/.claude/skills/`. Each skill is a folder containing a `SKILL.md` file.

### Step 1: Create the skills folder structure

```bash
mkdir -p ~/.claude/skills/system-knowledge
mkdir -p ~/.claude/skills/app-knowledge
mkdir -p ~/.claude/skills/ui-ux-design
```

### Step 2: Copy each doc to its skill folder, renaming to `SKILL.md`

```bash
cp ~/path/to/app-docs/system-knowledge.md ~/.claude/skills/system-knowledge/SKILL.md
cp ~/path/to/app-docs/app-knowledge.md ~/.claude/skills/app-knowledge/SKILL.md
cp ~/path/to/app-docs/ui-ux-design.md ~/.claude/skills/ui-ux-design/SKILL.md
```

### Step 3: Verify

In Claude Code, type `/system-knowledge`, `/app-knowledge`, or `/ui-ux-design`. The skill should load and Claude should respond with "Loaded."

---

## Recommended Workflow

At the start of every Claude Code session for the BowlersNetwork mobile app:

```
/system-knowledge
/app-knowledge
/ui-ux-design
```

That's about 30 seconds of setup, and then Claude has the full context it needs for the rest of the session.

If your session is short and focused on UI work only, loading just `/ui-ux-design` is fine. For backend integration, `/app-knowledge` is the most important.

---

## Keeping Docs in Sync

These docs are **derived from the web frontend's skill docs**. If the web design system changes (new color, new component pattern, new typography rule), the mobile docs should be updated to match.

Coordinate with Mumit Boss when the web frontend gets a major design update — the mobile docs should be re-generated or manually patched to keep parity.

---

## API Documentation

These skill docs cover the **mobile app architecture and design language**. They do NOT include the full backend API contracts.

For endpoint specs (request/response shapes, query params, error codes), you'll receive a separate `bn_v2_frontend_docs/` folder containing one markdown file per system (access, profiles, newsfeed, etc.). Place that folder anywhere accessible and reference it when building features.

The skill docs assume the API docs exist. If you don't have them, request them from Mumit Boss.

---

## Questions?

If anything in these docs is unclear, ambiguous, or contradicts what you're seeing in the actual app, **ask before assuming**. The web frontend at `https://bb.bowlersnetwork.com` (staging) is the visual reference — when in doubt about a pattern, study the equivalent web screen.
