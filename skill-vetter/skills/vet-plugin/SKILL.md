---
name: vet-plugin
description: Security vetting for entire Cursor/Grok Bot plugins. Checks all skills, manifests, hooks, scripts, and MCP servers in a plugin folder. Outputs a comprehensive security report with per-skill and plugin-level findings.
---

# Vet Plugin 🔒

Security-first vetting for entire Cursor/Grok Bot plugins. Checks the complete plugin bundle (manifest, skills, scripts, hooks, MCP servers) before installation.

## When to Use

Use `vet-plugin` before installing a complete plugin from:
- Cursor/Grok Bot plugin marketplace
- GitHub plugin repositories
- Locally developed plugins (before publishing)
- Plugins shared by other developers
- Forked or community-maintained plugins

## What It Checks

For the entire plugin:
1. **Plugin manifest** (`.cursor-plugin/plugin.json`) for over-broad permissions
2. **All skills** (every `SKILL.md` in `skills/`) using vet-skill checks
3. **Hooks** (startup, shutdown, workspace hooks) for unsafe code
4. **Scripts** (any `.sh`, `.py`, `.js` files) for exfiltration and remote execution
5. **MCP server configs** for unrestricted command execution
6. **Rules** (`.cursor-plugin/rules.json`) for excessive scope
7. **Variables** for hardcoded secrets

## Vetting Process

### Step 1: Run Plugin-Level Static Analysis

Run the vetter on the plugin root:

```bash
/path/to/skill-vetter/scripts/vet.sh --plugin /path/to/plugin-folder
```

This:
- Validates plugin.json schema
- Checks each skill individually
- Scans all scripts for red flags
- Analyzes hooks and MCP configs
- Aggregates findings into a plugin report

Exit codes:
- `0` = pass (all skills pass)
- `1` = warn (at least one skill warns)
- `2` = fail (at least one skill fails or plugin-level issue)

### Step 2: Manual Review

Review the plugin's structure:

```
plugin-name/
├── .cursor-plugin/
│   ├── plugin.json          ← Check permissions, category, keywords
│   ├── rules.json           ← Check scope (files, folders, wildcards)
│   └── hooks/               ← Check for unsafe shell commands
│       ├── on-startup.sh
│       └── on-file-save.sh
├── skills/                  ← Each skill vetted individually
│   ├── skill-1/SKILL.md
│   └── skill-2/SKILL.md
├── scripts/                 ← Check for curl|sh, data exfiltration
│   └── helper.sh
└── mcp-servers/             ← Check for unrestricted command access
    └── config.json
```

### Step 3: Check Plugin-Level Red Flags

```
🚨 PLUGIN-LEVEL RED FLAGS:
─────────────────────────────────────────
Manifest Issues:
• Missing required fields (name, version, author)
• Invalid schema (additionalProperties)
• Suspicious keywords (hack, bypass, exploit)

Hooks:
• on-startup hook runs arbitrary shell commands
• on-file-save hook sends file contents externally
• Hooks with sudo/elevated permissions

MCP Servers:
• Bundled MCP server with unrestricted shell access
• MCP config with wildcard command permissions
• Remote MCP URLs to unknown domains

Rules:
• Wildcard file patterns (/** or ~/*) without clear need
• Overly broad folder access
• Rules that override security settings

Scripts:
• Same red flags as individual skills
  (exfiltration, credential reads, remote execution, etc.)
─────────────────────────────────────────
```

### Step 4: Aggregate Risk Assessment

Plugin risk = MAX(all skill risks, plugin-level risk)

- If any skill is EXTREME, plugin is EXTREME
- If any skill is HIGH, plugin is at least HIGH
- Plugin-level issues (hooks, MCP) can elevate risk

## Output Format

After vetting, produce this report:

```
PLUGIN VETTING REPORT
═══════════════════════════════════════
Plugin: [name]
Display Name: [displayName]
Version: [version]
Author: [author.name]
Source: [GitHub URL or marketplace]
───────────────────────────────────────
PLUGIN STRUCTURE:
• Skills: [count]
• Hooks: [list or "None"]
• Scripts: [count]
• MCP Servers: [count or "None"]
───────────────────────────────────────
MANIFEST CHECK: [✓ PASS / ✗ FAIL]
Issues: [None / List]

SKILL CHECKS:
─────────────────────────────────────────
Skill: skill-1
  Static Analysis: ✓ PASS
  Red Flags: None
  Risk: 🟢 LOW

Skill: skill-2
  Static Analysis: ⚠ WARN
  Red Flags: Reads ~/.config (line 42)
  Risk: 🟡 MEDIUM
─────────────────────────────────────────

HOOKS CHECK: [✓ PASS / ⚠ WARN / ✗ FAIL]
Issues: [None / List]

SCRIPTS CHECK: [✓ PASS / ⚠ WARN / ✗ FAIL]
Issues: [None / List]

MCP SERVERS CHECK: [✓ PASS / ⚠ WARN / ✗ FAIL]
Issues: [None / List]

RULES CHECK: [✓ PASS / ⚠ WARN / ✗ FAIL]
Issues: [None / List]
───────────────────────────────────────
AGGREGATE RISK: [🟢 LOW / 🟡 MEDIUM / 🔴 HIGH / ⛔ EXTREME]

VERDICT: [✅ SAFE TO INSTALL / ⚠️ INSTALL WITH CAUTION / ❌ DO NOT INSTALL]

NOTES: [Summary, recommendations, manual review findings]
═══════════════════════════════════════
```

## Example: Vetting the Creator Voice Plugin

**Input:**
```
Agent, vet the creator-voice plugin before I install it:
/workspace/creator-voice/
```

**Process:**

1. Run static analysis:
```bash
$ ./scripts/vet.sh --plugin /workspace/creator-voice/
Checking plugin manifest...
✓ Manifest valid
✓ No over-broad permissions

Checking skills...
✓ voice-profile: PASS
✓ humanize: PASS
✓ x-post: PASS
✓ x-thread: PASS
✓ changelog-to-thread: PASS
✓ video-to-posts: PASS

Checking scripts...
✓ analyze-posts.sh: PASS (scoped file operations only)

No hooks found.
No MCP servers found.

RESULT: PASS (exit 0)
All 6 skills passed, no plugin-level issues.
```

2. Manual review:
- plugin.json: valid schema, category "productivity", no suspicious keywords
- 6 skills: all draft-only, no auto-publish, no credential access
- 1 script: analyze-posts.sh operates only on specified input files
- No hooks, no MCP servers, no rules

**Output:**
```
PLUGIN VETTING REPORT
═══════════════════════════════════════
Plugin: creator-voice
Display Name: Creator Voice
Version: 1.0.0
Author: Francesco Andreoli
Source: https://github.com/andreolf/grokbot-plugins
───────────────────────────────────────
PLUGIN STRUCTURE:
• Skills: 6
• Hooks: None
• Scripts: 1 (analyze-posts.sh)
• MCP Servers: None
───────────────────────────────────────
MANIFEST CHECK: ✓ PASS
Issues: None

SKILL CHECKS:
─────────────────────────────────────────
Skill: voice-profile
  Static Analysis: ✓ PASS
  Red Flags: None
  Risk: 🟢 LOW

Skill: humanize
  Static Analysis: ✓ PASS
  Red Flags: None
  Risk: 🟢 LOW

Skill: x-post
  Static Analysis: ✓ PASS
  Red Flags: None
  Risk: 🟢 LOW

Skill: x-thread
  Static Analysis: ✓ PASS
  Red Flags: None
  Risk: 🟢 LOW

Skill: changelog-to-thread
  Static Analysis: ✓ PASS
  Red Flags: None
  Risk: 🟢 LOW

Skill: video-to-posts
  Static Analysis: ✓ PASS
  Red Flags: None
  Risk: 🟢 LOW
─────────────────────────────────────────

HOOKS CHECK: ✓ PASS
Issues: None (no hooks present)

SCRIPTS CHECK: ✓ PASS
Issues: None (analyze-posts.sh: scoped file operations only)

MCP SERVERS CHECK: ✓ PASS
Issues: None (no MCP servers present)

RULES CHECK: ✓ PASS
Issues: None (no rules present)
───────────────────────────────────────
AGGREGATE RISK: 🟢 LOW

VERDICT: ✅ SAFE TO INSTALL

NOTES: Draft-only content creation plugin. No auto-publish, no
credential access, no exfiltration. All skills are informational
or draft-generating. Helper script operates only on specified input.
Safe to install.
═══════════════════════════════════════
```

## Comparison: vet-skill vs vet-plugin

| Feature | vet-skill | vet-plugin |
|---|---|---|
| **Scope** | Single SKILL.md + its folder | Entire plugin directory |
| **Checks** | Skill code, frontmatter | Skills + manifest + hooks + scripts + MCP |
| **Output** | Single skill report | Aggregated plugin report |
| **Use case** | Vetting one skill before install | Vetting complete plugin before install |
| **Exit code** | 0/1/2 for that skill | MAX of all component exit codes |

## Remember

- Plugin risk = worst component risk
- A single EXTREME skill makes the plugin EXTREME
- Hooks and MCP servers are high-risk surfaces
- Always review plugin.json permissions
- When in doubt, vet each skill individually first

## Credits

Adapted from **spclaudehome/skill-vetter** on ClawHub (MIT-0 license).  
Original: https://clawhub.ai/spclaudehome/skills/skill-vetter
