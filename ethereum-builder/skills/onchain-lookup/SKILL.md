---
name: onchain-lookup
description: Look up addresses, transactions, contracts, and tokens onchain via Blockscout's public REST API (multi-chain). Use when you need to verify addresses, check contract code, view transaction details, or get token information.
---

# Onchain Lookup

**When to use:** When you need to verify onchain data — addresses, transactions, contracts, tokens, or balances — across any EVM chain supported by Blockscout.

## What is Blockscout?

Blockscout is an open-source blockchain explorer with a public REST API. It provides verified contract code, transaction details, token information, and more across 100+ EVM chains.

## Helper Script

The `scripts/blockscout-lookup.sh` helper script wraps the Blockscout API for common lookup tasks.

### Usage

```bash
./scripts/blockscout-lookup.sh <chain> <lookup-type> <identifier>
```

### Supported Chains

Common chains (use the chain identifier):
- `eth` — Ethereum mainnet
- `base` — Base
- `optimism` — OP Mainnet
- `arbitrum` — Arbitrum One
- `polygon` — Polygon PoS
- `gnosis` — Gnosis Chain
- `scroll` — Scroll
- `zksync` — zkSync Era
- `linea` — Linea
- `sepolia` — Ethereum Sepolia testnet
- `base-sepolia` — Base Sepolia testnet

Full list of supported chains: https://www.blockscout.com/chains-and-projects

### Lookup Types

#### 1. Address Info

Get basic info about any address (EOA or contract):

```bash
./scripts/blockscout-lookup.sh eth address 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
```

**Returns:**
- Address type (contract or EOA)
- ETH balance
- Transaction count
- For contracts: creation info, compiler version, whether verified

#### 2. Contract Source

Get verified contract source code:

```bash
./scripts/blockscout-lookup.sh eth contract 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
```

**Returns:**
- Full source code (if verified)
- Compiler version
- Contract name
- Constructor arguments
- ABI

**Note:** Only works for verified contracts. Returns error if unverified.

#### 3. Transaction

Get transaction details:

```bash
./scripts/blockscout-lookup.sh eth tx 0x<txhash>
```

**Returns:**
- From/to addresses
- Value transferred
- Gas used/price
- Block number and timestamp
- Status (success/failed)
- Input data
- Logs (events)

#### 4. Token Info

Get ERC-20 or ERC-721 token information:

```bash
./scripts/blockscout-lookup.sh eth token 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
```

**Returns:**
- Token name and symbol
- Decimals (ERC-20)
- Total supply
- Holder count
- Contract address
- Token type (ERC-20, ERC-721, ERC-1155)

#### 5. Token Balance

Get token balance for an address:

```bash
./scripts/blockscout-lookup.sh eth token-balance 0x<token-address> 0x<holder-address>
```

**Returns:**
- Raw balance
- Formatted balance (with decimals)
- Token info

#### 6. Token Holders

Get top token holders:

```bash
./scripts/blockscout-lookup.sh eth holders 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
```

**Returns:**
- Top 50 holders (default)
- Address and balance for each
- Percentage of total supply

## Common Workflows

### Verify a Contract Address

Before integrating with a contract, verify it exists and is the right one:

```bash
# 1. Check address info
./scripts/blockscout-lookup.sh eth address 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

# 2. Get contract source (if verified)
./scripts/blockscout-lookup.sh eth contract 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

# 3. Verify the contract name matches expectations
# Output will show: "name": "UniswapV2Router02"
```

### Check Transaction Status

```bash
./scripts/blockscout-lookup.sh eth tx 0x<txhash>

# Look for:
# - "status": "1" (success) or "0" (failed)
# - "gasUsed" vs "gas" (did it run out of gas?)
# - "logs" (what events were emitted?)
```

### Token Due Diligence (Quick Check)

```bash
# 1. Basic token info
./scripts/blockscout-lookup.sh eth token 0x<token-address>

# 2. Check if contract is verified
./scripts/blockscout-lookup.sh eth address 0x<token-address>

# 3. Get holder distribution
./scripts/blockscout-lookup.sh eth holders 0x<token-address>

# Red flags:
# - Unverified contract
# - One address holds >50% of supply
# - Very few holders
```

### Cross-Chain Address Verification

Check if an address exists on multiple chains:

```bash
# Same address, different chains
./scripts/blockscout-lookup.sh eth address 0x<address>
./scripts/blockscout-lookup.sh base address 0x<address>
./scripts/blockscout-lookup.sh optimism address 0x<address>

# Warning: Same address ≠ same contract
# Always verify contract code on each chain
```

## API Rate Limits

Blockscout's public API is rate-limited:
- **No API key:** Limited requests per minute
- **With API key:** Higher limits (set `BLOCKSCOUT_API_KEY` env var)

The script handles rate limits gracefully with retry logic.

### Get an API Key (Optional)

1. Visit: https://www.blockscout.com/auth/profile
2. Create account and generate API key
3. Set environment variable:

```bash
export BLOCKSCOUT_API_KEY="your-api-key-here"
```

The script will automatically use it if set.

## Error Handling

The script returns meaningful errors:

- **"Address not found"** — Address has no activity on this chain
- **"Contract not verified"** — Source code not available
- **"Transaction not found"** — Invalid tx hash or wrong chain
- **"Rate limit exceeded"** — Too many requests, wait and retry
- **"Invalid chain"** — Chain identifier not recognized

## Security Notes

- **Never trust addresses without verification:** Always check contract source
- **Wrong address = lost funds:** Double-check every address before sending transactions
- **Same address, different chains:** A contract at 0x123...abc on Ethereum is NOT the same as 0x123...abc on Base
- **Verified ≠ safe:** Verification only means "code matches bytecode", not "code is secure"

## Alternative: Blockscout MCP Server

Blockscout also offers an MCP server at `https://mcp.blockscout.com/mcp` (PRO key header, or rate-limited shared key).

**When to use MCP vs this script:**
- **Use this script** for simple lookups and testing
- **Use MCP** if user has it installed and for complex workflows

MCP server docs: https://mcp.blockscout.com/

## Examples

### Example 1: Verify Uniswap V2 Router on Ethereum

```bash
$ ./scripts/blockscout-lookup.sh eth address 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

{
  "is_contract": true,
  "is_verified": true,
  "name": "UniswapV2Router02",
  "balance": "0",
  "tx_count": 1
}
```

### Example 2: Check USDC Token Info

```bash
$ ./scripts/blockscout-lookup.sh eth token 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

{
  "name": "USD Coin",
  "symbol": "USDC",
  "decimals": "6",
  "total_supply": "...",
  "holders": "...",
  "type": "ERC-20"
}
```

### Example 3: Check Token Holder Distribution

```bash
$ ./scripts/blockscout-lookup.sh eth holders 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

Top holders:
1. 0x... : 1,234,567.89 USDC (12.34%)
2. 0x... : 987,654.32 USDC (9.87%)
...
```

## Troubleshooting

**"Chain not found":** Check the chain identifier. Use lowercase (e.g., `eth`, not `Eth` or `ETH`).

**"No data returned":** Address may not exist on this chain. Try a different chain or verify the address.

**Rate limited:** Add delays between requests or set `BLOCKSCOUT_API_KEY`.

**Contract source empty:** Contract is not verified. Try the contract author's GitHub or Etherscan.

## Best Practices

1. **Always verify contract code** before integrating with a contract
2. **Check multiple chains** if address exists on several
3. **Cross-reference with official sources** (protocol docs, GitHub)
4. **Never use unverified contracts** in production
5. **Check holder distribution** for tokens (concentration risk)
6. **Verify transaction success** before assuming it worked
7. **Use `cast code <address>`** to verify a contract exists locally

## Related Skills

- **token-diligence:** Full token security checklist (uses this skill internally)
- **ethskills-router:** Fetch `addresses` module for verified contract addresses
- **protocol-research:** Research workflow for DeFi protocols (uses lookups)

## Further Reading

- Blockscout docs: https://docs.blockscout.com/
- Blockscout API: https://docs.blockscout.com/api-endpoints
- Supported chains: https://www.blockscout.com/chains-and-projects
