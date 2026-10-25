# Submission Checklist

Plugin submission information for the Cursor/Grok Bot marketplace.

## Plugin Information

**Name:** Ethereum Builder  
**Version:** 1.0.0  
**Category:** Infrastructure  
**Tags:** development, research, analytics  
**License:** MIT  

**Author:** Francesco Andreoli  
**Contact:** [@francescoswiss](https://twitter.com/francescoswiss)  
**Repository:** https://github.com/andreolf/grokbot-plugins  

## Description

Ethereum/EVM development and onchain research tools for AI agents. Includes ethskills routing, Blockscout lookups, Dune analysis, token due diligence, and protocol research workflows for building and auditing dApps.

## Skills Overview

1. **ethskills-router** (70KB) — Route to ethskills.com modules by development phase
2. **onchain-lookup** (16KB) — Multi-chain address/contract/tx/token lookups via Blockscout API
3. **dune-analysis** (21KB) — Query blockchain data with DuneSQL
4. **token-diligence** (18KB) — Token security checklist and risk assessment
5. **protocol-research** (22KB) — Structured DeFi protocol research workflow

**Total:** 5 skills, ~147KB

## Helper Scripts

1. **blockscout-lookup.sh** (7.5KB) — Blockscout API wrapper (bash)
2. **dune-query.sh** (7.2KB) — Dune Analytics API wrapper (bash)

## Security Review

### ✅ No Secrets in Repository

- No API keys, tokens, or credentials committed
- All keys from environment variables (`DUNE_API_KEY`, `BLOCKSCOUT_API_KEY`)
- Scripts check for missing keys and exit with clear error messages

### ✅ No Remote Code Execution

- No `curl | bash` or similar patterns
- No dynamic code loading
- All scripts are plain bash (no obfuscation)

### ✅ No Prompt Injection

- Skills contain instructions only, no dynamic prompts
- External content (ethskills.com) is fetched at runtime, not embedded
- No user input concatenated into prompts without sanitization

### ✅ Scoped Operations

- Scripts operate only on blockchain data (read-only)
- No file system operations outside defined scope
- No network operations beyond documented APIs (Blockscout, Dune)

### ✅ Graceful Error Handling

- All scripts handle:
  - Missing API keys (clear error message, exit code 1)
  - Rate limits (retry with exponential backoff)
  - Network failures (timeout, connection refused)
  - Invalid responses (malformed JSON, missing fields)

### ✅ No Over-Broad Permissions

- Scripts require:
  - Network access (for API calls)
  - Read access to environment variables (`DUNE_API_KEY`, `BLOCKSCOUT_API_KEY`)
- No filesystem writes (except stdout/stderr)
- No system command execution beyond curl/jq

## Testing

All tests pass:

```bash
# Validation tests
./tests/validate-plugin.sh
✓ All plugin structure and frontmatter checks pass

# Functional tests
./tests/test-plugin.sh
✓ Blockscout lookups (address, contract, token, holders) - live API
✓ Dune script validation (skips execution when no key set)
✓ Error handling (missing keys, rate limits, invalid inputs)
```

## MCP Servers (Not Bundled)

**Finding:** Blockscout and Dune both offer official MCP servers:
- Blockscout: https://mcp.blockscout.com/mcp
- Dune: https://api.dune.com/mcp/v1

**Decision:** NOT bundled in this plugin because:
1. Users benefit from installing MCPs directly in Cursor/Grok Bot settings (single auth, cross-plugin use)
2. Bundling would require redistributing vendor authentication logic
3. REST API wrappers provide full functionality as a fallback

**Documentation:** Both MCPs are documented in the README and relevant skills as optional enhancements. Users can install them separately if desired.

## License Compliance

### Plugin License

**MIT License** — Full text in `LICENSE` file.

### Dependencies

- **Ethskills:** Content fetched from https://ethskills.com at runtime
  - Source: https://github.com/austintgriffith/ethskills (no license detected on GitHub)
  - ClawHub copy: MIT-0 per ClawHub platform policy
  - **Approach:** Link to URLs, fetch at runtime; no content copied
- **Blockscout:** Public REST API, no authentication required for basic use
  - Terms: https://www.blockscout.com/terms-of-service
  - **Approach:** REST API calls via helper script
- **Dune Analytics:** Public API with user's own API key
  - Terms: https://dune.com/terms
  - **Approach:** REST API calls with user's `DUNE_API_KEY`

### Third-Party Content

**No third-party content embedded.** All external content (ethskills modules, blockchain data) is fetched at runtime via documented APIs.

## Breaking Changes

None (initial release).

## Migration Guide

N/A (initial release).

## Known Limitations

1. **Dune analysis requires API key:** Users must set `DUNE_API_KEY` for dune-analysis skill. Free tier available.
2. **Blockscout rate limits:** Public API is rate-limited. Users can set `BLOCKSCOUT_API_KEY` for higher limits (optional).
3. **Ethskills requires network:** Skills fetch from ethskills.com; offline use not supported.
4. **Chain support:** Limited to chains with Blockscout instances (~100+ EVM chains).

## Support & Maintenance

- **Issues:** https://github.com/andreolf/grokbot-plugins/issues
- **Updates:** Monitored for Ethereum ecosystem changes (new chains, deprecated endpoints)
- **Maintenance commitment:** Active development; updates for breaking API changes

## Reviewer Notes

### Plugin Quality

- **Structure:** Follows reference plugin (second-brain) layout
- **Documentation:** Comprehensive README with examples, FAQ, and workflows
- **Tests:** Full test coverage (schema, frontmatter, live API, error handling)
- **Skills:** Clear frontmatter with `name` and `description` matching folder structure
- **Scripts:** Plain bash, no obfuscation, with error handling

### Target Audience

- **Primary:** Ethereum/EVM developers and researchers
- **Use cases:** 
  - Building dApps (ethskills guidance)
  - Verifying contracts (Blockscout lookups)
  - Analyzing protocols (Dune queries)
  - Token due diligence (security checklists)
  - DeFi research (structured workflows)

### Gap Filled

**Gap:** Zero EVM developer tooling in the current marketplace (482 plugins, 0 for Ethereum dev).

From audit report:
> "EVM developer tooling and onchain data: zero. No Etherscan, Blockscout, Dune, Alchemy, Infura, thirdweb, Foundry or Solidity plugin."

This plugin fills the largest gap in the catalog.

### Value Proposition

1. **Ethskills integration:** Routes to up-to-date Ethereum knowledge (training data is stale)
2. **Multi-chain support:** Works across 100+ EVM chains via Blockscout
3. **Data analysis:** Dune queries for metrics, liquidity, and historical data
4. **Risk assessment:** Token diligence and protocol research workflows
5. **No vendor lock-in:** Uses public APIs; users keep their keys

## Checklist

- [x] Plugin manifest (`plugin.json`) valid and matches schema
- [x] All skills have valid frontmatter (`name`, `description`)
- [x] README.md with usage examples
- [x] CHANGELOG.md with version history
- [x] LICENSE file (MIT)
- [x] Test suite (validate + functional tests)
- [x] No secrets in repository
- [x] Scripts handle missing keys gracefully
- [x] Error handling for rate limits and network failures
- [x] Logo (`assets/logo.svg`)
- [x] All files use correct line endings (LF, not CRLF)
- [x] No executables (except scripts with shebang)
- [x] Scripts are plain bash (no obfuscation)
- [x] MCP server decision documented
- [x] License compliance verified

## Submission Metadata

**Submitted by:** Francesco Andreoli  
**Date:** 2026-10-25  
**Version:** 1.0.0  
**Status:** Ready for review  

**Repository:** https://github.com/andreolf/grokbot-plugins/tree/main/ethereum-builder  
**Pull Request:** [Will be added when PR is created]  

---

**Signature:** I confirm that this plugin:
- Contains no malicious code
- Respects user privacy
- Follows marketplace guidelines
- Has been tested thoroughly
- Is properly licensed (MIT)

Francesco Andreoli  
2026-10-25
