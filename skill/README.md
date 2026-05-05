# menutodo Claude Code skill

Adds a `/menutodo` skill to Claude Code for reading and writing todos in [menutodo](https://github.com/starc007/menutodo) — a native macOS menu bar todo app.

## Install

```bash
/plugin marketplace add starc007/menutodo
/plugin install menutodo
```

Or with the `skill` CLI (if you use it):

```bash
npx skills add starc007/menutodo
```

> **Note:** The marketplace install path assumes this repo is published at `github.com/starc007/menutodo`. For local install, clone and add the `skill/` subfolder as a local marketplace.

## Local install

```bash
# Clone the repo
git clone https://github.com/starc007/menutodo

# Add skill/ as a local marketplace in Claude Code
/plugin marketplace add /path/to/menutodo/skill
/plugin install menutodo
```

## Usage

Once installed, Claude Code can manage your todos:

```
add todo: review the PR
add todo: deploy staging, tag: work
list my todos
what's pending?
show todos tagged work
mark "review the PR" as done
delete "deploy staging"
clear completed
```

The skill reads and writes `~/.menutodo.json` directly. Changes appear in the app the next time you open the menu bar popover.

## Requirements

- [menutodo](https://github.com/starc007/menutodo) installed and running
- macOS with python3 (pre-installed on all Macs)
