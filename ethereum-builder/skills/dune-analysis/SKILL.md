---
name: dune-analysis
description: Query and analyze onchain data with Dune Analytics. Find datasets, write DuneSQL queries, execute them, and fetch results. Requires user's DUNE_API_KEY environment variable.
---

# Dune Analysis

**When to use:** When you need to analyze onchain data, research protocols, track metrics, or answer data questions about Ethereum and other chains using Dune Analytics.

## What is Dune?

Dune Analytics is a blockchain data platform that lets you query decoded onchain data using SQL. It provides:
- Pre-decoded contract data (events, function calls)
- Curated datasets (prices, DEX trades, NFT sales, etc.)
- Community queries and dashboards
- DuneSQL (powered by TrinoSQL)

## Prerequisites

**Required:** User's Dune API key must be set as an environment variable:

```bash
export DUNE_API_KEY="your-api-key-here"
```

**Get a Dune API key:**
1. Sign up at https://dune.com
2. Go to Settings → API Keys
3. Generate a new API key
4. Set it in your environment (never commit it to git)

## Helper Script

The `scripts/dune-query.sh` helper script wraps the Dune API for common tasks.

### Usage

```bash
./scripts/dune-query.sh <action> [args]
```

### Actions

#### 1. Search Queries

Find existing Dune queries by keyword:

```bash
./scripts/dune-query.sh search "uniswap v3 volume"
```

**Returns:**
- Query IDs
- Query names and descriptions
- Authors
- Links to Dune app

**Use case:** Find existing queries before writing your own.

#### 2. Execute Query

Execute a query by ID and get results:

```bash
./scripts/dune-query.sh execute <query-id>
```

**Returns:**
- Execution ID (for polling)
- When complete: query results as JSON

**Use case:** Run an existing query to get fresh data.

#### 3. Execute Custom SQL

Execute custom DuneSQL and get results:

```bash
./scripts/dune-query.sh query "SELECT * FROM ethereum.transactions LIMIT 10"
```

**Returns:**
- Execution ID
- Query results when complete

**Use case:** Run ad-hoc analysis without creating a saved query.

#### 4. Get Query Details

Get metadata about a saved query:

```bash
./scripts/dune-query.sh info <query-id>
```

**Returns:**
- Query name and description
- SQL code
- Parameters
- Author

**Use case:** Understand what a query does before executing it.

#### 5. Check Execution Status

Check if a query execution is complete:

```bash
./scripts/dune-query.sh status <execution-id>
```

**Returns:**
- Execution state (PENDING, EXECUTING, COMPLETED, FAILED)
- Progress percentage
- Results when complete

## DuneSQL Basics

Dune uses DuneSQL (based on TrinoSQL) to query blockchain data.

### Key Tables

#### Raw Tables

- `ethereum.transactions` — All Ethereum transactions
- `ethereum.blocks` — Block metadata
- `ethereum.logs` — Raw event logs
- `ethereum.traces` — Internal transaction traces

**Other chains:** Replace `ethereum` with `base`, `optimism`, `arbitrum`, `polygon`, etc.

#### Decoded Tables

- `<project>_ethereum.<contract>_evt_<event>` — Decoded events
- `<project>_ethereum.<contract>_call_<function>` — Decoded function calls

**Example:** `uniswap_v3_ethereum.Factory_evt_PoolCreated`

#### Curated Tables

- `prices.usd` — Token prices over time
- `dex.trades` — All DEX trades across protocols
- `nft.trades` — NFT sales
- `tokens.erc20` — ERC-20 token metadata
- `labels.addresses` — Labeled addresses

### Common Query Patterns

#### Get Recent Transactions for a Contract

```sql
SELECT
    block_time,
    hash,
    "from",
    "to",
    value / 1e18 AS eth_value
FROM ethereum.transactions
WHERE "to" = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
  AND block_time > NOW() - INTERVAL '7' DAY
ORDER BY block_time DESC
LIMIT 100
```

#### Get Token Price

```sql
SELECT
    minute,
    price
FROM prices.usd
WHERE contract_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
  AND blockchain = 'ethereum'
  AND minute > NOW() - INTERVAL '24' HOUR
ORDER BY minute DESC
```

#### Analyze DEX Volume

```sql
SELECT
    DATE_TRUNC('day', block_time) AS day,
    project,
    SUM(amount_usd) AS volume_usd
FROM dex.trades
WHERE blockchain = 'ethereum'
  AND block_time > NOW() - INTERVAL '30' DAY
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC
```

#### Get Top Token Holders

```sql
SELECT
    address,
    SUM(amount) AS balance
FROM erc20_ethereum.evt_Transfer
WHERE contract_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
GROUP BY 1
ORDER BY 2 DESC
LIMIT 100
```

### DuneSQL Tips

1. **Quote reserved words:** Use double quotes for column names like `"from"`, `"to"`, `"value"`
2. **Decimals:** Divide by `1e18` for 18-decimal tokens (most ERC-20s), `1e6` for USDC/USDT
3. **Time filters:** Use `NOW() - INTERVAL '7' DAY` for recent data
4. **Addresses:** Use lowercase, with `0x` prefix
5. **Large queries:** Add `LIMIT` to avoid timeouts

## Common Workflows

### Research a Protocol

```bash
# 1. Search for existing queries
./scripts/dune-query.sh search "aave"

# 2. Execute a relevant query
./scripts/dune-query.sh execute 12345

# 3. Write custom analysis
./scripts/dune-query.sh query "
SELECT
    DATE_TRUNC('day', block_time) AS day,
    COUNT(*) AS tx_count,
    SUM(amount_usd) AS volume_usd
FROM aave_v3_ethereum.Pool_evt_Supply
WHERE block_time > NOW() - INTERVAL '30' DAY
GROUP BY 1
ORDER BY 1 DESC
"
```

### Track Token Metrics

```bash
# Get token holders over time
./scripts/dune-query.sh query "
SELECT
    DATE_TRUNC('day', evt_block_time) AS day,
    COUNT(DISTINCT to) AS unique_holders
FROM erc20_ethereum.evt_Transfer
WHERE contract_address = 0x<token-address>
  AND evt_block_time > NOW() - INTERVAL '90' DAY
GROUP BY 1
ORDER BY 1 DESC
"
```

### Analyze DEX Liquidity

```bash
# Get pool liquidity for a token pair
./scripts/dune-query.sh query "
SELECT
    pool,
    token0,
    token1,
    tvl_usd
FROM dex.liquidity
WHERE blockchain = 'ethereum'
  AND (token0 = 0x<token-address> OR token1 = 0x<token-address>)
ORDER BY tvl_usd DESC
LIMIT 20
"
```

## API Rate Limits

Dune API has rate limits based on your plan:
- **Free tier:** Limited executions per month
- **Paid plans:** Higher limits

The script handles rate limits and returns clear errors when exceeded.

## Error Handling

The script handles common errors:

- **"DUNE_API_KEY not set"** — Set the environment variable
- **"Query not found"** — Invalid query ID
- **"Query failed"** — SQL error (check syntax)
- **"Rate limit exceeded"** — Upgrade plan or wait
- **"Execution timeout"** — Query took too long (simplify or add filters)

## Security Notes

- **Never commit DUNE_API_KEY** to git or share publicly
- **Keep keys in environment variables** only
- **Rotate keys if leaked:** Generate a new key in Dune settings
- **Use .env.local** for local development (add to .gitignore)

## Alternative: Dune MCP Server

Dune also offers an official MCP server at `https://api.dune.com/mcp/v1` (requires OAuth or `x-dune-api-key` header).

**When to use MCP vs this script:**
- **Use this script** for simple queries and testing
- **Use MCP** if user has it configured and for complex workflows

MCP server docs: https://docs.dune.com/docs/agents/mcp

## Examples

### Example 1: Find Uniswap V3 Volume Queries

```bash
$ ./scripts/dune-query.sh search "uniswap v3 volume"

Found 5 queries:
1. Query 12345: "Uniswap V3 Daily Volume" by @duneuser
   https://dune.com/queries/12345

2. Query 67890: "Uniswap V3 Pool Volume Breakdown" by @analyst
   https://dune.com/queries/67890
...
```

### Example 2: Get Token Price History

```bash
$ ./scripts/dune-query.sh query "
SELECT
    minute,
    price
FROM prices.usd
WHERE contract_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
  AND blockchain = 'ethereum'
  AND minute > NOW() - INTERVAL '24' HOUR
ORDER BY minute DESC
LIMIT 10
"

Executing query...
Results:
{
  "minute": "2026-10-25 08:00:00",
  "price": 1.0001
},
...
```

### Example 3: Analyze Contract Activity

```bash
$ ./scripts/dune-query.sh query "
SELECT
    DATE_TRUNC('day', block_time) AS day,
    COUNT(*) AS tx_count
FROM ethereum.transactions
WHERE \"to\" = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
  AND block_time > NOW() - INTERVAL '7' DAY
GROUP BY 1
ORDER BY 1 DESC
"

Results show daily transaction counts for Uniswap V2 Router...
```

## Resources

- Dune Docs: https://docs.dune.com/
- DuneSQL Reference: https://docs.dune.com/query-engine/dunesql-reference
- Data Tables: https://docs.dune.com/data-tables/
- Community Queries: https://dune.com/browse/queries
- Dune Discord: https://discord.gg/dunecom

## Troubleshooting

**Query execution hangs:** Add time filters (`WHERE block_time > NOW() - INTERVAL '7' DAY`) and LIMIT to reduce data scanned.

**"Column not found":** Check table schema in Dune docs. Column names are case-sensitive.

**Timeouts:** Break large queries into smaller chunks or use pre-aggregated tables (like `dex.trades` instead of raw logs).

**Wrong results:** Verify address format (lowercase, with `0x`) and decimals (divide by 1e18 or 1e6).

## Related Skills

- **onchain-lookup:** Use Blockscout for address verification before querying Dune
- **token-diligence:** Combines Dune analysis with onchain lookups
- **protocol-research:** Uses Dune for protocol metrics
- **ethskills-router:** Fetch `indexing` module for event-driven data patterns

## Best Practices

1. **Start with search** — Existing queries save time
2. **Use time filters** — `WHERE block_time > NOW() - INTERVAL '7' DAY` makes queries fast
3. **Add LIMIT** — Start with `LIMIT 100` for testing
4. **Check decimals** — Divide by 1e18 (ETH/most tokens) or 1e6 (USDC/USDT)
5. **Verify addresses** — Use lowercase, with `0x` prefix
6. **Quote reserved words** — `"from"`, `"to"`, `"value"` need quotes
7. **Test locally** — Use the script's `query` action for rapid iteration
8. **Cache results** — Query execution costs credits; save results locally
