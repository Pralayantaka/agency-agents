# 📖 The Agency — Repository Handbook

> A practical guide to understanding, using, and contributing to
> [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) —
> a curated library of **254 AI agent personalities** organized into **17 divisions**,
> installable into **16 different AI coding tools**.

---

## Table of Contents

1. [What This Repository Is](#1-what-this-repository-is)
2. [Repository Map](#2-repository-map)
3. [Anatomy of an Agent File](#3-anatomy-of-an-agent-file)
4. [The Divisions (Agent Roster)](#4-the-divisions-agent-roster)
5. [Installing & Using the Agents](#5-installing--using-the-agents)
6. [The Scripts Toolchain](#6-the-scripts-toolchain)
7. [Sources of Truth: divisions.json & tools.json](#7-sources-of-truth-divisionsjson--toolsjson)
8. [Multi-Tool Integrations](#8-multi-tool-integrations)
9. [NEXUS — The Orchestration Layer](#9-nexus--the-orchestration-layer)
10. [Examples & Workflows](#10-examples--workflows)
11. [Continuous Integration](#11-continuous-integration)
12. [Contributing](#12-contributing)
13. [License & Security](#13-license--security)

---

## 1. What This Repository Is

**The Agency** is not an application — it is a **content library**. Every agent is a
Markdown file that defines a specialized AI persona: its identity, mission, rules,
deliverables, and communication style. You install these files into your AI coding
tool (Claude Code, Cursor, Copilot, Gemini CLI, etc.) and then "activate" an agent
in conversation:

> *"Hey Claude, activate Frontend Developer mode and help me build a React component."*

Key characteristics:

- **Markdown-first**: agents are plain `.md` files with YAML frontmatter — readable, diffable, forkable.
- **Personality-driven**: each agent has a distinct voice, not just a task list.
- **Tool-agnostic**: a converter pipeline (`scripts/convert.sh`) renders each agent
  into the native format of 16 supported tools.
- **Community-maintained**: MIT-licensed, PR-driven, with CI linting that enforces
  the agent template.
- **There is also a native desktop app** ([agencyagents.app](https://agencyagents.app),
  separate repo: `agency-agents-app`) that browses and installs the roster with a click.

---

## 2. Repository Map

```
agency-agents/
├── README.md                ← Full roster tables + quick start
├── HANDBOOK.md              ← This file
├── CONTRIBUTING.md          ← Agent template + PR process (also zh-CN)
├── SECURITY.md              ← Vulnerability reporting policy
├── LICENSE                  ← MIT
├── divisions.json           ← SOURCE OF TRUTH: the division set (label/icon/color)
├── tools.json               ← SOURCE OF TRUTH: the supported-tool set (install contracts)
│
├── <division>/              ← 17 agent divisions, one directory each:
│   academic/  design/  engineering/  finance/  game-development/
│   gis/  healthcare/  marketing/  paid-media/  product/
│   project-management/  sales/  security/  spatial-computing/
│   specialized/  support/  testing/
│   └── *.md                 ← One agent per file (game-development also nests
│                              per-engine subdirs: unity/, unreal-engine/, godot/,
│                              roblox-studio/, blender/)
│
├── strategy/                ← NOT a division. NEXUS multi-agent orchestration
│   ├── nexus-strategy.md      playbook: 7 phases (0–6), handoff templates,
│   ├── phase-0…6-*.md         activation prompts, scenario runbooks
│   └── runbooks.json
│
├── examples/                ← NOT a division. End-to-end workflow walkthroughs
│
├── integrations/            ← NOT a division. Per-tool conversion OUTPUT dirs.
│   └── <tool>/README.md       Only the READMEs are committed; generated agent
│                              files are .gitignored (regenerate via convert.sh)
│
├── scripts/                 ← Bash toolchain: convert, install, lint, CI checks
│
└── .github/
    ├── workflows/           ← 4 CI checks (see §11)
    ├── ISSUE_TEMPLATE/      ← bug report + new-agent request forms
    └── PULL_REQUEST_TEMPLATE.md
```

**Important distinction** — top-level directories are *not* all divisions:

| Directory | Role |
|---|---|
| 17 division dirs | Source agent files (must contain ≥1 frontmatter agent) |
| `strategy/` | Playbooks/runbooks — no agent frontmatter |
| `integrations/` | Generated per-tool output (from `convert.sh`) |
| `examples/`, `scripts/` | Docs and tooling |

---

## 3. Anatomy of an Agent File

Every agent follows a strict template (enforced by `scripts/lint-agents.sh` in CI):

```markdown
---
name: Agent Name                  # Human-readable display name
description: One-line specialty   # Used by tools for agent routing/selection
color: cyan                       # Named color or "#hexcode"
emoji: 🎯
vibe: One-line personality hook
services:                         # OPTIONAL — only if external services required
  - name: Service Name
    url: https://service-url.com
    tier: free                    # free | freemium | paid
---

# Agent Name

## 🧠 Your Identity & Memory
- **Role**: what the agent is
- **Personality**: voice and communication style
- **Memory**: what it remembers/learns
- **Experience**: domain perspective

## 🎯 Your Core Mission
- 3–5 responsibility areas, each with concrete deliverables
- **Default requirement**: always-on best practices

## 🚨 Critical Rules You Must Follow
Domain-specific constraints that define the agent's approach

## 📋 Your Technical Deliverables
Real, working code samples / templates / processes

## 📊 Success Metrics          (typical — later sections vary slightly)
## 💬 Communication Style
```

Design principles (from CONTRIBUTING.md):

- **Specialized, not generic** — deep domain expertise, not a reworded ChatGPT prompt.
- **Deliverable-focused** — real code examples and measurable outcomes.
- **Personality matters** — the `vibe:` line and voice make agents memorable.
- **Originality checked** — `scripts/check-agent-originality.sh` guards against
  near-duplicate agents.

A good reference example: [`engineering/engineering-frontend-developer.md`](engineering/engineering-frontend-developer.md).

---

## 4. The Divisions (Agent Roster)

Counts as of this handbook's writing (recursive, frontmatter files only):

| Division | Agents | Focus |
|---|---:|---|
| 💻 `engineering/` | 49 | Frontend, backend, mobile, AI/ML, DevOps, SRE, embedded, blockchain, CMS, data, prompts |
| ✨ `specialized/` | 54 | Everything niche: legal, HR, real-estate, aviation, translation, compliance… |
| 📢 `marketing/` | 36 | Growth, SEO, content, social platforms (TikTok/Reddit/Instagram…), brand |
| 🎮 `game-development/` | 20 | Core design roles + per-engine experts (Unity, Unreal, Godot, Roblox, Blender) |
| 🗺️ `gis/` | 13 | Geospatial analysis, cartography, remote sensing |
| 🛡️ `security/` | 10 | AppSec, pentesting, threat modeling, compliance |
| 🎨 `design/` | 9 | UI, UX research, brand, visual storytelling, whimsy |
| 📈 `sales/` | 9 | Outbound, enablement, RevOps |
| 🧪 `testing/` | 9 | QA, API testing, performance benchmarking, test automation |
| 💰 `paid-media/` | 7 | PPC, ad platforms, media buying |
| 📋 `project-management/` | 7 | Producers, shippers, experiment trackers |
| 🎓 `academic/` | 6 | Research, literature review, scholarly writing |
| 🥽 `spatial-computing/` | 6 | AR/VR/XR, visionOS |
| 🎧 `support/` | 6 | Customer support, docs, community |
| 💵 `finance/` | 5 | FP&A, accounting, financial modeling |
| 📦 `product/` | 5 | Feedback synthesis, prioritization, trend research |
| ⚕️ `healthcare/` | 3 | Health-tech strategy and innovation |
| **Total** | **254** | |

The full per-agent roster with "when to use" guidance lives in [README.md](README.md).

---

## 5. Installing & Using the Agents

### Option A — The desktop app (easiest)

[Agency Agents](https://agencyagents.app) (macOS/Linux/Windows) browses the roster
and installs into any supported tool. `brew install --cask msitarzewski/agency-agents/agency-agents` on a Mac.

### Option B — Claude Code, one-liner

```bash
./scripts/install.sh --tool claude-code       # all agents → ~/.claude/agents/
# or manually:
cp engineering/*.md ~/.claude/agents/
```

### Option C — Any other tool

```bash
./scripts/convert.sh              # 1. render integration files for all tools
./scripts/install.sh              # 2. interactive wizard (auto-detects your tools)
```

### Selective installs (recommended — you rarely want all 254)

```bash
./scripts/install.sh --tool claude-code --division engineering,security
./scripts/install.sh --tool cursor --agent frontend-developer,ui-designer
./scripts/install.sh --agents-file my-picks.txt   # see scripts/agents-to-install.example
./scripts/install.sh --list teams                 # what's available
./scripts/install.sh --tool opencode --division engineering --dry-run
```

Useful flags: `--link` (symlink so `git pull` updates propagate), `--path <dir>`
(custom destination), `--dry-run`, `--parallel`.

> ⚠️ **OpenCode**: its runtime silently caps at ~119 registered agents — install a
> subset with `--division`. The installer warns you.

### Activating an agent

Once installed, agents appear in the tool's native mechanism (Claude Code subagents,
Cursor rules, Copilot agents…). In chat-style tools, invoke by name:
*"Activate the Backend Architect and design the API for…"*

---

## 6. The Scripts Toolchain

All scripts are Bash (run from repo root; Windows users: use Git Bash or WSL).

| Script | Purpose |
|---|---|
| `scripts/convert.sh` | Renders source agents → `integrations/<tool>/` for all 16 tools. Never touches your home config. Flags: `--tool <name>`, `--parallel`, `--jobs N`. |
| `scripts/install.sh` | Copies/symlinks converted files into each tool's real config dir. Interactive wizard by default; fully scriptable via flags (see §5). Auto-runs convert if outputs are missing. |
| `scripts/lint-agents.sh` | Enforces the agent template (frontmatter fields, required sections, header levels). Run before submitting a PR. |
| `scripts/check-divisions.sh` | Verifies `divisions.json` ⇄ directories ⇄ `AGENT_DIRS` arrays ⇄ CI path filters all agree. |
| `scripts/check-tools.sh` | Verifies `tools.json` ⇄ `install.sh`'s `ALL_TOOLS` ⇄ `convert.sh`'s converter set all agree. |
| `scripts/check-runbooks.sh` | Validates `strategy/runbooks.json` against the strategy docs. |
| `scripts/check-agent-originality.sh` | Flags near-duplicate agents. |
| `scripts/build-hermes-plugin.py` | Builds the Hermes lazy-router plugin artifact (the one `installKind: plugin` tool). |
| `scripts/lib.sh` | Shared helpers sourced by the other scripts. |
| `scripts/i18n/` | Chinese localization tooling (`localize-agents-zh.ps1`, name mappings). |

The invariant to remember: **convert.sh writes only inside the repo
(`integrations/`); install.sh is the only script that writes to your machine's
config directories.**

---

## 7. Sources of Truth: divisions.json & tools.json

Two JSON catalogs at the repo root drive everything — the scripts, the CI, and the
desktop app all consume them.

### `divisions.json`
Maps each division directory → display label, Lucide icon, brand hex color.
CI (`check-divisions.yml`) fails if this list disagrees with the directories on
disk or the `AGENT_DIRS` arrays in `convert.sh` / `lint-agents.sh`.

### `tools.json`
One entry per supported tool, carrying the full **install contract**:

- `format` — the renderer contract (`identity`, `codex-toml`, `skill-md`, `cursor-mdc`…).
  Two tools may share a format **only if their rendered output is byte-identical.**
- `installKind` — the mechanism:
  - `per-agent` — one rendered file/dir per agent (most tools)
  - `roster` — one combined file for all agents (Aider's `CONVENTIONS.md`, Windsurf's `.windsurfrules`)
  - `plugin` — a built artifact, CLI-only (Hermes router)
- `detect` / `dest` — how the installer finds the tool and where files land
  (user scope vs. project scope).

CI (`check-tools.yml`) fails if `tools.json` drifts from `install.sh`/`convert.sh`.

**Rule of thumb: never hand-edit a script's tool/division list without updating the
JSON catalog (and vice versa) — CI will catch you.**

---

## 8. Multi-Tool Integrations

Supported targets (from `tools.json`): **Claude Code, Codex, Gemini CLI, GitHub
Copilot, Qwen Code, Cursor, OpenCode, Osaurus, Aider, Antigravity, Kimi, OpenClaw,
Windsurf, Hermes, Mistral Vibe, ZCode.**

Each `integrations/<tool>/README.md` documents that tool's specifics. The generated
agent files themselves are **gitignored** — always regenerate locally:

```bash
./scripts/convert.sh --tool cursor
```

Special integration: [`integrations/mcp-memory/`](integrations/mcp-memory/README.md)
shows how to give agents persistent memory via an MCP memory server (with a
worked example agent).

---

## 9. NEXUS — The Orchestration Layer

[`strategy/`](strategy/nexus-strategy.md) contains **NEXUS** (*Network of EXperts,
Unified in Strategy*) — a deployment doctrine for running many agents as a
coordinated team instead of isolated specialists.

- **7 phases**: Discovery (0) → Strategy (1) → Foundation (2) → Build (3) →
  Hardening (4) → Launch (5) → Operate (6). One doc per phase
  (`phase-0-discovery.md` … `phase-6-operate.md`) defining which agents activate,
  what they produce, and the quality gate to pass before advancing.
- **`handoff-templates.md`** — structured artifacts agents pass between phases.
- **`agent-activation-prompts.md`** — copy-paste prompts to activate each role.
- **Scenario runbooks** — pre-built playbooks: startup MVP, enterprise feature,
  incident response, marketing campaign (indexed in `runbooks.json`, validated by CI).
- **`QUICKSTART.md` / `EXECUTIVE-BRIEF.md`** — short entry points.

Start with `strategy/QUICKSTART.md` if you want the 5-minute version.

---

## 10. Examples & Workflows

[`examples/`](examples/README.md) contains end-to-end walkthroughs of multi-agent
workflows:

- `workflow-startup-mvp.md` — idea → shipped MVP using multiple divisions
- `workflow-landing-page.md` — design + engineering + marketing collaboration
- `workflow-book-chapter.md` — long-form content production
- `workflow-with-memory.md` — combining agents with the MCP memory integration
- `nexus-spatial-discovery.md` — a NEXUS Phase-0 run in the spatial-computing domain

These are the best way to learn the "activate → hand off → deliver" rhythm.

---

## 11. Continuous Integration

Four GitHub Actions workflows (`.github/workflows/`):

| Workflow | Runs | Fails when… |
|---|---|---|
| `lint-agents.yml` | `scripts/lint-agents.sh` | An agent file violates the template (frontmatter, sections, headers) |
| `check-divisions.yml` | `scripts/check-divisions.sh` | `divisions.json` drifts from disk/scripts/CI filters |
| `check-tools.yml` | `scripts/check-tools.sh` | `tools.json` drifts from `install.sh`/`convert.sh` |
| `check-runbooks.yml` | `scripts/check-runbooks.sh` | `strategy/runbooks.json` drifts from the strategy docs |

Run the same scripts locally before pushing a PR — they are the exact CI gate.

---

## 12. Contributing

Full details in [CONTRIBUTING.md](CONTRIBUTING.md). The short version:

### Add a new agent
1. Fork the repo.
2. Pick the right division (browse `divisions.json`); name the file
   `<division>-<agent-name>.md` following the division's convention.
3. Follow the template in §3 exactly — CI lints it.
4. Test the agent in real scenarios.
5. Run `./scripts/lint-agents.sh` and `./scripts/check-agent-originality.sh`.
6. Open a PR using the PR template.

### Propose a new division
Create the directory **and** add it to: `divisions.json`, `AGENT_DIRS` in
`scripts/convert.sh`, `AGENT_DIRS` in `scripts/lint-agents.sh`, and the path
filters in `lint-agents.yml`. Then run `scripts/check-divisions.sh`.

### Add support for a new tool
Add an entry to `tools.json`, a `convert_<tool>` renderer in `convert.sh` (or
reuse an existing `format`), an `install_<tool>` in `install.sh`, then run
`scripts/check-tools.sh`.

### Other ways to help
Improve existing agents, add examples, share success stories in
[Discussions](https://github.com/msitarzewski/agency-agents/discussions), report
issues via the issue templates, or translate (zh-CN, vi already exist).

---

## 13. License & Security

- **License**: [MIT](LICENSE) — free to use, modify, and redistribute.
- **Security**: report vulnerabilities per [SECURITY.md](SECURITY.md). Note that
  `fix/477-scrub-test-creds`-style history shows the maintainers actively scrub
  credentials; never commit real secrets in agent examples.
- **Sponsorship**: the project accepts sponsors via GitHub Sponsors (`.github/FUNDING.yml`).

---

*This handbook was generated from an analysis of the repository at commit `00fb28a`
(main, July 2026). Counts and file lists reflect that snapshot — the roster grows
weekly, so cross-check README.md for the latest.*
