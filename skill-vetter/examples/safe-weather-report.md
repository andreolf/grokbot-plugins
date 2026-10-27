# Skill Vetter Report: safe-weather

Example vetting report for a safe weather skill.

## Skill Information

- **Name:** safe-weather
- **Source:** Local test fixture
- **Author:** Test author
- **Version:** 1.0.0

## Vetting Process

### Static Analysis

```bash
$ ./scripts/vet.sh tests/fixtures/good/safe-weather/
Vetting skill: safe-weather
─────────────────────────────────────────
ℹ Checking for data exfiltration patterns...
✓ No data exfiltration patterns
ℹ Checking for credential reads...
✓ No credential reads
ℹ Checking for remote code execution...
✓ No remote execution patterns
ℹ Checking for hidden instructions...
✓ No hidden instructions
ℹ Checking for over-broad permissions...
✓ Permissions are scoped

RESULT: PASS (exit 0)
```

## Vetting Report

```
SKILL VETTING REPORT
═══════════════════════════════════════
Skill: safe-weather
Source: Local test fixture
Author: Test author
Version: 1.0.0
───────────────────────────────────────
METRICS:
• Downloads/Stars: N/A (test fixture)
• Last Updated: 2026-10-27
• Files Reviewed: 2
• Lines of Code: ~10
───────────────────────────────────────
STATIC ANALYSIS: ✓ PASS
Exit code: 0

RED FLAGS FOUND: None
───────────────────────────────────────
PERMISSIONS DECLARED (frontmatter):
• Env vars: None
• Binaries: curl
• Config files: None

PERMISSIONS USED (in code):
• Files read: None
• Files written: None
• Network calls: wttr.in (public weather API)
• Commands run: curl

MISMATCHES: None
───────────────────────────────────────
RISK LEVEL: 🟢 LOW

VERDICT: ✅ SAFE TO INSTALL

NOTES: Simple read-only API wrapper. Calls wttr.in public weather
API with no authentication. No file writes, no credential access,
no data exfiltration. Safe to install.
═══════════════════════════════════════
```

## Manual Review Notes

- **API calls:** Only to wttr.in, a well-known public weather API
- **File operations:** None (doesn't write files)
- **Credentials:** None required
- **Execution scope:** Minimal - just curl to fetch weather
- **Risk assessment:** Very low risk

## Recommendation

✅ **SAFE TO INSTALL**

This is a simple, read-only skill that fetches public data from a reputable API. No security concerns.
