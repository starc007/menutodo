---
name: menutodo
description: >
  Manage todos in menutodo — native macOS menu bar todo app.
  Use when user asks to add, list, complete, delete, or filter todos.
  Todos stored at ~/.menutodo.json. Read/write directly — no MCP needed.
version: "1.0.0"
argument-hint: "add todo: review PR | list todos | mark done: deploy | clear completed"
allowed-tools: Read, Write, Bash
user-invocable: true
author: starc007
homepage: https://github.com/starc007/menutodo
---

# menutodo skill

Todos are stored at `~/.menutodo.json` as a JSON array. Read and write this file directly.

## Schema

```json
[
  {
    "id": "uuid-string",
    "text": "todo text",
    "done": false,
    "tag": "optional-tag",
    "created": "2026-05-05T12:00:00Z"
  }
]
```

- `id` — UUID string (generate with `uuidgen` or `python3 -c "import uuid; print(uuid.uuid4())"`)
- `text` — todo content
- `done` — boolean
- `tag` — optional string, omit field when null (do not write `"tag": null`)
- `created` — ISO 8601 UTC timestamp

## Read operations

**List all todos:**
Read `~/.menutodo.json` and display as a formatted list.

**List pending only:**
Filter where `done == false`.

**Filter by tag:**
Filter where `tag == requested_tag`.

**Show tags:**
Collect unique `tag` values from all items (excluding null/missing).

## Write operations

Always follow this pattern:
1. Read current `~/.menutodo.json`
2. Mutate the array in memory
3. Write the full array back atomically

**Add a todo:**
```bash
python3 -c "
import json, uuid, datetime, pathlib

path = pathlib.Path.home() / '.menutodo.json'
todos = json.loads(path.read_text()) if path.exists() else []
todos.append({
    'id': str(uuid.uuid4()),
    'text': 'YOUR TEXT HERE',
    'done': False,
    'created': datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
})
path.write_text(json.dumps(todos, indent=2))
print('Added.')
"
```

Add with tag — include `'tag': 'tagname'` in the dict.

**Mark done (by partial text match):**
```bash
python3 -c "
import json, pathlib

path = pathlib.Path.home() / '.menutodo.json'
todos = json.loads(path.read_text())
query = 'SEARCH TEXT'
matched = 0
for t in todos:
    if query.lower() in t['text'].lower() and not t['done']:
        t['done'] = True
        matched += 1
path.write_text(json.dumps(todos, indent=2))
print(f'Marked {matched} todo(s) done.')
"
```

**Delete a todo (by partial text match):**
```bash
python3 -c "
import json, pathlib

path = pathlib.Path.home() / '.menutodo.json'
todos = json.loads(path.read_text())
query = 'SEARCH TEXT'
before = len(todos)
todos = [t for t in todos if query.lower() not in t['text'].lower()]
path.write_text(json.dumps(todos, indent=2))
print(f'Deleted {before - len(todos)} todo(s).')
"
```

**Clear completed:**
```bash
python3 -c "
import json, pathlib

path = pathlib.Path.home() / '.menutodo.json'
todos = json.loads(path.read_text())
before = len(todos)
todos = [t for t in todos if not t['done']]
path.write_text(json.dumps(todos, indent=2))
print(f'Cleared {before - len(todos)} completed todo(s).')
"
```

## Notes

- App reloads from disk each time the popover opens — changes appear immediately on next open.
- File may not exist yet if no todos have been added via the app. Treat missing file as empty array.
- Preserve all existing fields when writing back — never drop unknown fields.
- Use the Bash tool with python3 for all write operations (python3 is always available on macOS).
