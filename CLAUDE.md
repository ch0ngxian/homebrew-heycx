# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains `heycx`, an opinionated CLI toolkit for Git workflow automation. It's distributed via Homebrew.

## Architecture

### CLI Structure

```
heycx
├── hotfix
│   ├── start    # Prompts for name, creates hotfix/<name> from master
│   └── finish   # Merges hotfix → master → develop
├── sync         # Updates master & develop branches
└── docker
    └── enter    # Enter a running Docker container by name
```

The CLI is a single bash script (`heycx`) with subcommand routing.

### Git Branching Model

- **master** - Production branch, receives hotfix merges
- **develop** - Development branch, receives master merges after hotfix
- **hotfix/*** - Temporary branches for urgent production fixes

All merges use `--no-ff` to preserve branch history.

## Common Commands

### Start a Hotfix

```bash
heycx hotfix start
```

Prompts for hotfix name interactively, then:
- Stashes uncommitted changes
- Updates master and develop branches
- Creates `hotfix/<name>` from master
- Applies stashed changes
- Pushes branch to remote

### Finish a Hotfix

```bash
heycx hotfix finish
```

Requirements:
- Must be run from a `hotfix/*` branch
- No uncommitted changes allowed

### Sync Branches

```bash
heycx sync
```

Updates master and develop from remote, returns to original branch.

### Enter Docker Container

```bash
heycx docker enter <name-part>
```

Searches running containers for a partial name match and opens an interactive shell (tries zsh, then bash, then sh).

## Dependencies

- **Git** - Required for hotfix and sync commands
- **Docker** - Required for docker-enter command
- **gh** (GitHub CLI) - Optional, used by `hotfix finish` to trigger deployment workflows

## Homebrew Distribution

The Formula is in `Formula/heycx.rb`. To release:

1. Tag a new version: `git tag -a v1.x.x -m "Release"`
2. Push tag: `git push origin v1.x.x`
3. Create GitHub Release
4. Update SHA256 in formula: `curl -sL <tarball-url> | shasum -a 256`

## Important Patterns

### Error Handling

The script uses `set -e` to exit immediately on errors:
- Failed git commands stop execution
- Merge conflicts require manual resolution

### Interactive Prompts

`heycx hotfix start` prompts for the branch name and shows planned actions before proceeding.

### Workflow Triggering

`heycx hotfix finish` searches for a production deployment workflow:
```bash
gh workflow list | grep -i "prod" | grep -i "deployment"
```

If found, triggers it on master. If not found or gh unavailable, continues without error.

### Documentation

Always update README.md when adding, updating, or removing scripts.
