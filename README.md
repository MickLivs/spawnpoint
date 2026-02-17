# spawnpoint

> Zero-to-dev for non-technical users.

A POC that gets any Mac user from a blank machine to a live deployed app — without touching a package manager, writing a Dockerfile, or knowing what Node.js is.

## How it works

1. User runs a single bootstrap command on their Mac
2. Bootstrap installs the minimum required tooling (brew, node, claude code)
3. Claude Code provisions a [Sprite](https://sprites.dev) — a persistent remote Linux dev environment
4. [cc4d](https://github.com/tombensim/claude-for-dummies) guides the user from idea to deployed app on Vercel
5. [babysitter](https://github.com/entireio/cli) handles screenshot-based visual feedback loop

All actual development happens inside the Sprite. The user's machine is just a terminal.

## Architecture

```
Mac (terminal only)
  └── bootstrap.sh  ← one-time setup
        └── Claude Code (local)
              └── Sprite (remote Linux VM on fly.io)
                    ├── cc4d skill (guides build process)
                    ├── babysitter (visual feedback)
                    ├── git + node + npm + vercel CLI
                    └── web app (live preview via *.sprites.app URL)
                          └── Vercel (final deploy)
```

## Quick Start

```bash
curl https://raw.githubusercontent.com/MickLivs/spawnpoint/main/bootstrap.sh | bash
```

## What's in this repo

- `bootstrap.sh` — one-liner Mac setup script
- `sprite-init.sh` — provisions and configures a Sprite with all required tools
- `docs/` — architecture notes and design decisions

## Status

POC / early exploration. Not production ready.
