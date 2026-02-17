# Architecture Notes

## The Problem

Non-technical users on Macs have none of the prerequisites for Claude Code:
- No Xcode CLI tools
- No Homebrew
- No Node / npm / npx
- No git configured

Getting from zero to a running Claude Code session is a 20+ minute process with multiple admin prompts, potential reboots, and multiple failure points.

## The Solution

Two-phase approach:

### Phase 1: Bootstrap (local, one-time)
`bootstrap.sh` runs on the user's Mac and installs exactly four things:
1. Xcode Command Line Tools
2. Homebrew
3. Node.js
4. Claude Code
5. Sprites CLI

This is unavoidable — something has to run locally to reach the remote environment. But it only happens once.

### Phase 2: Dev work (remote, in a Sprite)
All actual development happens inside a [Sprite](https://sprites.dev) — a persistent Linux VM on fly.io.

Benefits:
- Consistent environment regardless of user's machine
- Persists between sessions (filesystem survives sleep/wake)
- Live preview URL out of the box (`*.sprites.app`)
- ~$0.44 per 4-hour session (pay per second, free when idle)
- Pre-installed: Claude Code, Node, Python, git

## Component Roles

| Component | Role |
|---|---|
| [cc4d](https://github.com/tombensim/claude-for-dummies) | Claude Code skill that guides user from idea to deployed app |
| [babysitter](https://github.com/entireio/cli) | Screenshot-based visual feedback — lets Claude see the browser |
| Sprites | Remote persistent dev environment |
| Vercel | Final deployment target |

## Open Questions

- B2B use case: Sprites won't work for users who need access to internal network resources. On-premise alternative: same architecture but with a self-hosted Fly-equivalent on k8s + gvisor.
- Authentication flow: How does the user's Anthropic API key get into the Sprite? Needs a clean UX answer.
- cc4d + Sprite: cc4d currently assumes local dev. Need to verify the skill works correctly when Claude Code is running inside a Sprite.
