# AGENTS.md — spawnpoint

Guidance for AI agents working in this repository.

## What this project is

**spawnpoint** is a zero-to-dev bootstrapper for non-technical Mac users. Its single job: take someone from a blank Mac to a live deployed web app without them ever touching a package manager or writing a Dockerfile.

The architecture is intentionally split into two phases:

1. **Local bootstrap** (`bootstrap.sh`) — runs on the user's Mac once to install the minimum toolchain needed to reach a remote environment.
2. **Remote dev** (`sprite-init.sh`) — provisions a [Sprite](https://sprites.dev) (a persistent Linux VM on fly.io) and installs all development tooling inside it. All actual coding happens there.

The user's Mac remains a thin terminal. Nothing heavy lives on it.

## Repo layout

```
spawnpoint/
├── bootstrap.sh       # Phase 1: runs on the user's Mac
├── sprite-init.sh     # Phase 2: run inside a Sprite to set up the dev environment
├── docs/
│   └── architecture.md  # Detailed design decisions and open questions
└── README.md
```

There is no build system, no dependencies file, and no test suite — this is a shell-script POC.

## Component responsibilities

| Component | Where it runs | What it does |
|---|---|---|
| `bootstrap.sh` | User's Mac | Installs Xcode CLT, Homebrew, Node.js, Claude Code, Sprites CLI |
| `sprite-init.sh` | User's Mac (orchestrates) | Creates a Sprite, SSHes in, installs Node (via nvm), Vercel CLI, GitHub CLI; exposes port 3000 |
| [cc4d](https://github.com/tombensim/claude-for-dummies) | Inside the Sprite | Claude Code skill that guides user from idea → deployed app |
| [babysitter](https://github.com/entireio/cli) | Inside the Sprite | Screenshot-based visual feedback loop so Claude can see the browser |
| Sprites | Remote (fly.io) | Persistent Linux VM; provides `*.sprites.app` live preview URL |
| Vercel | Cloud | Final deployment target |

## Key constraints and conventions

- **Shell compatibility**: Both scripts target `bash` and use `set -e`. Keep them POSIX-friendly where possible; avoid bashisms that break on older macOS defaults.
- **Idempotency**: Every install step in both scripts checks whether the tool already exists before installing. Preserve this — users may re-run the scripts.
- **Non-technical audience**: Error messages and echo output should be plain English, no jargon. Assume the user has never opened a terminal before.
- **Minimal local footprint**: `bootstrap.sh` installs only what is absolutely required to reach the Sprite. Do not add local dev tooling here.
- **Sprite name as argument**: `sprite-init.sh` accepts the Sprite name as `$1` (defaults to `my-dev`). Keep this parameterized.
- **No secrets in scripts**: API keys (Anthropic, Vercel, GitHub) are intentionally out of scope for these scripts. Authentication flow is an open design question — don't hard-code credentials.

## How to make changes

Since this is shell scripts + markdown:

- **Edit scripts** with care for idempotency and the non-technical audience.
- **Test `bootstrap.sh` logic** mentally against a clean macOS install (no brew, no node, no claude). Each block must be safe to skip if already installed.
- **Test `sprite-init.sh` logic** against a fresh Sprite (Debian/Ubuntu base, has Python and git pre-installed, does NOT have Node or Vercel).
- **Update `docs/architecture.md`** when making architectural decisions or resolving the open questions listed there.
- **Update `README.md`** if the quick-start command or file list changes.

## Open questions (do not resolve silently)

These are tracked in `docs/architecture.md` and should be surfaced to the human before acting on them:

1. **Auth flow** — how does the user's Anthropic API key get into the Sprite cleanly?
2. **cc4d compatibility** — cc4d currently assumes local dev; verify it works when Claude Code runs inside a Sprite.
3. **B2B / on-premise** — users needing internal network access can't use Sprites; alternative architecture needed.

If a task touches any of these areas, flag it and ask for direction rather than making assumptions.
