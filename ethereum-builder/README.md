# Ethereum Builder

> **Ethereum/EVM development and onchain research tools for AI agents.** Route to ethskills, query Blockscout and Dune, perform token due diligence, and research DeFi protocols.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What is Ethereum Builder?

A Cursor/Grok Bot plugin that gives AI agents the tools and workflows to build and research Ethereum/EVM applications:

- **ethskills routing** — Navigate the ethskills.com knowledge base by development phase
- **Onchain lookups** — Verify addresses, contracts, transactions, and tokens via Blockscout
- **Dune analysis** — Query blockchain data with DuneSQL
- **Token due diligence** — Security checklist and risk assessment for ERC-20 tokens
- **Protocol research** — Structured workflow for researching DeFi protocols

**Works with:** Grok Bot, Cursor (IDE and Cloud Agents), Claude Desktop, and other agent orchestrators.

## Quick Start

### Installation

**Grok Bot:**
```
Install "Ethereum Builder" from the Grok Bot plugin marketplace
```

**Cursor:**
```
Settings → Plugins → Install "Ethereum Builder"
```

Or from marketplace:
```
cursor install ethereum-builder
```

### First Steps

#### 1. Route to Ethskills Modules

Ethskills (https://ethskills.com) provides up-to-date Ethereum development guidance. Your training data is stale. Use the router skill to find the right module:

```
In Grok Bot or Cursor:
"I'm building a new Uniswap integration. Which ethskills modules should I read?"

The agent will:
- Load the ethskills-router skill
- Recommend: ship, building-blocks, security, indexing
- Fetch each module's SKILL.md from ethskills.com
```

**Common starting points:**
- Building a new dApp? → `ship`, `concepts`, `l2s`
- Reviewing contracts? → `security`, `audit`, `crops`
- Choosing a chain? → `l2s`, `gas`
- Integrating DeFi? → `building-blocks`, `addresses`

#### 2. Look Up Onchain Data

Verify addresses, check contracts, view transactions:

```bash
# Verify Uniswap V2 Router on Ethereum
./scripts/blockscout-lookup.sh eth address 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

# Get USDC token info
./scripts/blockscout-lookup.sh eth token 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

# Check transaction status
./scripts/blockscout-lookup.sh eth tx 0x<txhash>

# Get top token holders
./scripts/blockscout-lookup.sh eth holders 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
```

**Supported chains:** Ethereum, Base, Optimism, Arbitrum, Polygon, Gnosis, Scroll, zkSync, Linea, and testnets.

**In agent chat:**
```
"Use onchain-lookup to verify the USDC contract on Base"

The agent will:
- Load the onchain-lookup skill
- Run the blockscout-lookup.sh script
- Return contract verification status and info
```

#### 3. Analyze with Dune

Query blockchain data using Dune Analytics (requires `DUNE_API_KEY`):

```bash
# Set your API key (get from https://dune.com/settings/api)
export DUNE_API_KEY="your-api-key-here"

# Get recent Uniswap V3 volume
./scripts/dune-query.sh query "
SELECT
    DATE_TRUNC('day', block_time) AS day,
    SUM(amount_usd) AS volume_usd
FROM dex.trades
WHERE blockchain = 'ethereum'
  AND project = 'uniswap'
  AND version = '3'
  AND block_time > NOW() - INTERVAL '7' DAY
GROUP BY 1
ORDER BY 1 DESC
"
```

**In agent chat:**
```
"Use dune-analysis to get Uniswap V3 daily volume for the last 30 days"

The agent will:
- Load the dune-analysis skill
- Write DuneSQL query
- Execute and return results
```

#### 4. Token Due Diligence

Check token security before integration:

```
In agent chat:
"Perform token due diligence on 0x<token-address> on Base"

The agent will:
- Load the token-diligence skill
- Check contract verification (onchain-lookup)
- Analyze holder distribution
- Verify liquidity (Dune)
- Cross-check official addresses
- Generate risk assessment report card
```

#### 5. Protocol Research

Research a DeFi protocol for integration:

```
"Research Aave V3 for integration on Ethereum. Produce a protocol research memo."

The agent will:
- Load the protocol-research skill
- Follow structured workflow (discovery → technical → metrics → integration → risks)
- Use onchain-lookup, dune-analysis, and ethskills
- Generate comprehensive research memo with recommendations
```

## Skills

| Skill | Use When | What It Does |
|-------|----------|--------------|
| **ethskills-router** | Starting any Ethereum development task | Routes to the right ethskills.com modules by phase (ship, security, audit, L2s, tools, standards, etc.) |
| **onchain-lookup** | Need to verify addresses, contracts, transactions, or tokens | Multi-chain Blockscout API wrapper for address verification, contract source, transaction details, token info, holder distribution |
| **dune-analysis** | Need to query blockchain data or analyze metrics | Dune Analytics API wrapper for DuneSQL queries, protocol metrics, liquidity analysis, historical data |
| **token-diligence** | Before integrating with a token | Security checklist: contract verification, proxy/ownership, holder concentration, liquidity, address verification, audit status. Produces risk report card |
| **protocol-research** | Researching a DeFi protocol for integration | Structured workflow: architecture, trust model, metrics, integration patterns, risk assessment. Produces research memo with recommendations |

## Helper Scripts

### blockscout-lookup.sh

Multi-chain blockchain explorer lookups.

**Usage:**
```bash
./scripts/blockscout-lookup.sh <chain> <lookup-type> <identifier>
```

**Lookup types:**
- `address` — Get address info (balance, tx count, contract status)
- `contract` — Get verified contract source code
- `tx` — Get transaction details
- `token` — Get token info (name, symbol, decimals, supply)
- `token-balance` — Get token balance for an address
- `holders` — Get top token holders

**Chains:** eth, base, optimism, arbitrum, polygon, gnosis, scroll, zksync, linea, sepolia, base-sepolia

**Optional:** Set `BLOCKSCOUT_API_KEY` for higher rate limits.

### dune-query.sh

Dune Analytics API wrapper.

**Prerequisites:** Set `DUNE_API_KEY` environment variable (get from https://dune.com/settings/api)

**Usage:**
```bash
./scripts/dune-query.sh <action> [args]
```

**Actions:**
- `search <keyword>` — Search for queries (note: directs to dune.com; API doesn't support text search)
- `execute <query-id>` — Execute a saved query by ID
- `query "<sql>"` — Execute custom DuneSQL
- `info <query-id>` — Get query metadata
- `status <execution-id>` — Check execution status
- `results <execution-id>` — Get results for completed execution

**DuneSQL tips:**
- Quote reserved words: `"from"`, `"to"`, `"value"`
- Divide by 1e18 for 18-decimal tokens, 1e6 for USDC/USDT
- Use time filters: `WHERE block_time > NOW() - INTERVAL '7' DAY`
- Addresses: lowercase with `0x` prefix

## Security & Best Practices

### No Secrets in Repository

- **Never commit API keys:** Use environment variables only
- **Helper scripts check for missing keys** and exit gracefully
- **Keys in `.env.local`** for local development (add to `.gitignore`)

### Safe API Usage

- **Rate limits:** Scripts include retry logic for Blockscout; Dune has per-plan limits
- **Error handling:** All scripts handle network failures, invalid responses, and API errors
- **Graceful degradation:** Missing API keys result in clear error messages, not crashes

### Verification Before Trust

- **Always verify contract addresses** using onchain-lookup before integration
- **Cross-check addresses** with official sources (protocol docs, CoinGecko, ethskills)
- **Wrong address = lost funds:** Double-check every address
- **Verified ≠ safe:** Verification means "code matches bytecode", not "code is secure"

## Environment Variables

| Variable | Required | Purpose | Get From |
|----------|----------|---------|----------|
| `DUNE_API_KEY` | For Dune analysis | Dune Analytics API access | https://dune.com/settings/api |
| `BLOCKSCOUT_API_KEY` | Optional | Higher Blockscout rate limits | https://www.blockscout.com/auth/profile |

**Set them:**
```bash
# Bash/Zsh
export DUNE_API_KEY="your-key-here"
export BLOCKSCOUT_API_KEY="your-key-here"

# Or in .env.local (add to .gitignore)
echo 'DUNE_API_KEY="your-key-here"' >> .env.local
source .env.local
```

## MCP Servers (Optional)

This plugin uses REST APIs by default. Dune and Blockscout also offer MCP servers for advanced integration:

### Blockscout MCP

- **URL:** https://mcp.blockscout.com/mcp
- **Auth:** PRO key header or rate-limited shared key
- **Docs:** https://mcp.blockscout.com/

**When to use:** User has MCP configured and needs complex workflows. Otherwise, use `blockscout-lookup.sh`.

### Dune MCP

- **URL:** https://api.dune.com/mcp/v1
- **Auth:** OAuth or `x-dune-api-key` header
- **Docs:** https://docs.dune.com/docs/agents/mcp

**When to use:** User has MCP configured and needs complex workflows. Otherwise, use `dune-query.sh`.

**Finding:** After checking Blockscout and Dune documentation, both vendors provide official MCP servers. However, this plugin does NOT bundle them because:
1. Bundling would require redistributing vendor authentication logic
2. Users benefit from configuring MCPs directly (single auth, cross-plugin use)
3. The skills document MCPs as optional alternatives to REST APIs

**Recommendation:** Users install MCPs via Cursor/Grok Bot settings. This plugin provides REST wrappers as a fallback.

## Workflows

### Building a New dApp

1. **Plan with ethskills:**
   - Use `ethskills-router` to fetch `ship` module
   - Follow the end-to-end guide
2. **Choose chain:**
   - Fetch `l2s` and `gas` modules for cost comparison
3. **Verify existing contracts:**
   - Use `onchain-lookup` to check protocol addresses
4. **Test integration:**
   - Use `dune-analysis` for liquidity and usage metrics
5. **Security review:**
   - Fetch `security` and `crops` modules

### Auditing a Protocol

1. **Research protocol:**
   - Use `protocol-research` skill for structured workflow
2. **Check contracts:**
   - Use `onchain-lookup` for verification and source review
3. **Analyze metrics:**
   - Use `dune-analysis` for TVL, volume, and user trends
4. **Token diligence:**
   - Use `token-diligence` if protocol has a token
5. **Follow ethskills audit:**
   - Fetch `audit` module for 500+ checklist items

### Token Integration

1. **Due diligence:**
   - Use `token-diligence` skill for full checklist
2. **Verify address:**
   - Cross-check with CoinGecko, protocol docs, and ethskills `addresses`
3. **Check liquidity:**
   - Use `dune-analysis` to find deepest pools
4. **Test on fork:**
   - Use Foundry or Hardhat to fork mainnet and test integration
5. **Monitor ongoing:**
   - Track holder concentration and liquidity changes

## FAQ

**Q: Do I need Dune API key for everything?**  
A: No. Only the `dune-analysis` skill requires it. All other skills (ethskills-router, onchain-lookup, token-diligence, protocol-research) work without Dune.

**Q: What if I don't have a Blockscout API key?**  
A: The `blockscout-lookup.sh` script works without one (rate-limited public API). An API key increases limits.

**Q: Can I use this plugin without connecting MCPs?**  
A: Yes. This plugin is fully functional with just the included scripts. MCPs are optional enhancements.

**Q: Is ethskills bundled in this plugin?**  
A: No. The `ethskills-router` skill fetches modules from https://ethskills.com at runtime. This ensures you always get the latest guidance (Ethereum changes rapidly).

**Q: Why "onchain" (one word)?**  
A: Ethereum community convention. It's "onchain" not "on-chain", just like "blockchain" not "block-chain".

**Q: What chains are supported?**  
A: Any EVM chain with a Blockscout instance. Common chains: Ethereum, Base, Optimism, Arbitrum, Polygon, Gnosis, Scroll, zkSync, Linea, plus testnets. Full list: https://www.blockscout.com/chains-and-projects

**Q: Can I use this for investment advice?**  
A: **No.** This plugin is for technical analysis only. The `token-diligence` skill explicitly states it's not financial advice. Always consult financial professionals for investment decisions.

**Q: How do I report bugs or request features?**  
A: Open an issue on GitHub: https://github.com/andreolf/grokbot-plugins/issues

## Testing

Run the test suite:

```bash
cd ethereum-builder

# Validate plugin structure and frontmatter
./tests/validate-plugin.sh

# Test functionality (includes live Blockscout API calls)
./tests/test-plugin.sh
```

**Tests cover:**
- Schema validation for plugin.json and marketplace.json
- Frontmatter validation for all skills
- Live Blockscout API lookups (address, contract, token, holders)
- Dune script validation (skips execution cleanly when `DUNE_API_KEY` not set)
- Error handling for missing keys and rate limits

## Contributing

This plugin is part of the `grokbot-plugins` monorepo. To contribute:

1. Fork: https://github.com/andreolf/grokbot-plugins
2. Create a branch: `git checkout -b feature/your-feature`
3. Make changes and test thoroughly
4. Submit a PR with description and test results

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT License — see [LICENSE](LICENSE)

## Author

Francesco Andreoli ([@francescoswiss](https://twitter.com/francescoswiss))

## Links

- [GitHub Repository](https://github.com/andreolf/grokbot-plugins)
- [Submit an Issue](https://github.com/andreolf/grokbot-plugins/issues)
- [Cursor Plugins](https://cursor.com/marketplace)
- [Grok Bot Marketplace](https://x.ai/bot/marketplace)
- [Ethskills](https://ethskills.com)
- [Blockscout](https://www.blockscout.com)
- [Dune Analytics](https://dune.com)

## Related Resources

- [Ethskills Documentation](https://ethskills.com)
- [Blockscout API Docs](https://docs.blockscout.com/)
- [Dune API Docs](https://docs.dune.com/)
- [Cursor Plugin Spec](https://cursor.com/docs/reference/plugins)
- [OpenClaw / ClawHub](https://openclaw.ai)
