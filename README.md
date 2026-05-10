# menutodo

Native macOS menu bar todo app. Lives in your menu bar, stays out of your way.

![macOS 15+](https://img.shields.io/badge/macOS-15%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![SwiftUI](https://img.shields.io/badge/SwiftUI-yes-green)

## Features

- **Menu bar only** — no dock icon, no full app window
- **Liquid glass UI** — native macOS 26 glass effect with ultraThinMaterial fallback
- **Tags** — organise todos by tag, filter with one click
- **Claude Code integration** — todos stored as plain JSON at `~/.menutodo.json`, read/write directly from Claude Code
- **Zero dependencies** — pure Swift + SwiftUI, no packages

## Usage

| Action | How |
|--------|-----|
| Add todo | Click menu bar icon → type → Return |
| Complete | Click circle on todo row |
| Delete | Hover row → click ✕ |
| Add tag | Click tag icon → type tag name → Return |
| Pick existing tag | Click tag icon → click ▾ |
| Filter by tag | Click tag chip at top |
| Clear completed | "Clear done" button in header |

## Claude Code integration

### Install the skill

```bash
# Claude Code plugin
/plugin marketplace add starc007/menutodo
/plugin install menutodo

# or via skill CLI
npx skills add starc007/menutodo
```

Then just ask Claude:

```
add todo: review PR
list my todos
mark "deploy staging" as done
clear completed
show todos tagged work
```

### How it works

Todos are stored at `~/.menutodo.json`:

```json
[
  {
    "id": "uuid",
    "text": "review PR",
    "done": false,
    "tag": "work",
    "created": "2026-05-05T12:00:00Z"
  }
]
```

Claude Code can read and write this file directly — no MCP needed.

```
add todo: deploy staging
mark "review PR" as done
list all pending todos
clear completed
```

## Install

### Download (easiest)

Grab the latest `menutodo.zip` from [Releases](https://github.com/starc007/menutodo/releases), unzip, drag `menutodo.app` to `/Applications`.

App is unsigned (no Apple Developer account). First launch:

- Right-click `menutodo.app` → **Open** (bypasses Gatekeeper warning)
- Or run once: `xattr -dr com.apple.quarantine /Applications/menutodo.app`

### Requirements (build from source)

- macOS 15.0+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Build from source

```bash
git clone https://github.com/saurabh10102/menutodo
cd menutodo
xcodegen generate
open menutodo.xcodeproj
```

Run the `menutodo` scheme. The app appears in your menu bar.

## Stack

- Swift 5.9 + SwiftUI
- `@Observable` for reactive state
- `MenuBarExtra` (macOS 13+) for menu bar presence
- `~/.menutodo.json` for persistence (atomic writes)
