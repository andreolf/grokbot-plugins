---
name: safe-weather
description: A simple, safe weather skill that calls a public API
---

# Safe Weather Skill

Get weather information from wttr.in (a free, public weather API).

## Usage

```bash
curl "https://wttr.in/London?format=3"
```

This skill:
- Only reads from a public API (wttr.in)
- Doesn't write any files outside /tmp
- Doesn't access credentials
- Doesn't execute remote code
- Has no hidden instructions

Safe to install. ✓
