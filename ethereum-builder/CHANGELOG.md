# Changelog

All notable changes to the Ethereum Builder plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-25

### Added
- Initial release of Ethereum Builder plugin
- **ethskills-router** skill: Route to ethskills.com modules by development phase
- **onchain-lookup** skill: Address, transaction, contract, and token lookups via Blockscout API
- **dune-analysis** skill: Query and analyze onchain data with Dune Analytics
- **token-diligence** skill: Token security checklist and risk assessment
- **protocol-research** skill: Structured DeFi protocol research workflow
- Helper scripts:
  - `blockscout-lookup.sh`: Multi-chain Blockscout API wrapper
  - `dune-query.sh`: Dune Analytics API wrapper (requires `DUNE_API_KEY`)
- Comprehensive test suite:
  - Schema validation for plugin.json
  - Frontmatter validation for all skills
  - Live API tests for Blockscout public endpoints
  - Graceful Dune test skips when API key not set

### Security
- No secrets stored in repository
- API keys from environment variables only
- Scripts handle missing keys, rate limits, and errors gracefully
- All helper scripts are plain bash with no obfuscation

### Notes
- MCP servers (Blockscout, Dune): Not bundled; documented as optional user-installed alternatives
- All skills reference external resources (ethskills.com) rather than copying content
- "Onchain" (one word, no hyphen) follows Ethereum community convention
