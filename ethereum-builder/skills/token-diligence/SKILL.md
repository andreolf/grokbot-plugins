---
name: token-diligence
description: Perform due diligence on ERC-20 tokens - check contract verification, proxy/ownership, holder concentration, liquidity, and cross-check addresses. Produces a clear report card with risk assessment. Not financial advice.
---

# Token Due Diligence

**When to use:** Before integrating with a token, adding it to a dApp, or researching token security. This skill performs technical due diligence, NOT investment advice.

## ⚠️ Disclaimer

This skill provides **technical analysis only**. It is **NOT financial advice**. Always:
- Do your own research
- Verify findings independently
- Consult legal/financial professionals for investment decisions
- Understand that onchain verification ≠ safety guarantee

## What This Checks

Token due diligence examines technical risks and trust assumptions:

1. **Contract Verification** — Is source code public?
2. **Proxy Pattern** — Can the contract be upgraded?
3. **Ownership & Privileges** — Who controls the contract?
4. **Holder Concentration** — Is supply centralized?
5. **Liquidity** — Can you actually trade it?
6. **Address Verification** — Does it match official sources?
7. **Audit Status** — Has it been professionally audited?

## The Checklist

### 1. Contract Verification

**Why:** Unverified contracts hide their code. You can't audit what you can't read.

**How to check:**
```bash
# Use onchain-lookup skill
./scripts/blockscout-lookup.sh <chain> address <token-address>
```

**Red flags:**
- ❌ Contract not verified
- ❌ Verification failed or incomplete

**Green flags:**
- ✅ Contract verified on explorer
- ✅ Source matches bytecode

### 2. Proxy Pattern Detection

**Why:** Proxies allow contract owners to change code after deployment, including adding backdoors.

**How to check:**
```bash
# Check if contract implements proxy pattern
./scripts/blockscout-lookup.sh <chain> contract <token-address> | grep -i "proxy\|implementation"

# Common proxy patterns:
# - EIP-1967 (Transparent Proxy)
# - UUPS (Universal Upgradeable Proxy Standard)
# - Beacon Proxy
```

**Red flags:**
- ❌ Upgradeable proxy with no timelock
- ❌ Proxy owner is EOA (single key)
- ❌ No upgrade delay

**Acceptable patterns:**
- ✅ Non-upgradeable (immutable)
- ✅ Proxy behind multisig (3+ signers)
- ✅ Proxy with 24-72 hour timelock

### 3. Ownership & Privileges

**Why:** Owner privileges (mint, pause, blacklist) can rug users.

**What to look for in contract code:**
```solidity
// Red flags:
function mint(address to, uint256 amount) onlyOwner  // Unlimited minting
function pause() onlyOwner  // Can freeze all transfers
function blacklist(address user) onlyOwner  // Can block users
function setTaxes(uint256 rate) onlyOwner  // Can change fees to 100%

// Acceptable patterns:
address public owner = address(0);  // Ownership renounced
modifier onlyTimelock  // Actions require timelock
mapping(address => bool) public minters;  // Decentralized minting
```

**How to check:**
1. Get contract source via onchain-lookup
2. Search for: `onlyOwner`, `mint`, `pause`, `blacklist`, `transferOwnership`
3. Check who owns the contract: `cast call <address> "owner()(address)" --rpc-url <rpc>`

**Red flags:**
- ❌ Owner can mint unlimited supply
- ❌ Owner can pause/blacklist
- ❌ Owner is EOA (single private key)
- ❌ No multisig or timelock

**Green flags:**
- ✅ Ownership renounced (`owner = address(0)`)
- ✅ Owner is multisig (3+ signers)
- ✅ Critical functions have timelock (24-72h)
- ✅ Max supply is hardcoded

### 4. Holder Concentration

**Why:** If one address holds 50%+ supply, they can dump and crash the price.

**How to check:**
```bash
# Get top holders
./scripts/blockscout-lookup.sh <chain> holders <token-address>

# Calculate concentration
# Top 1 holder: Should be <10% (unless protocol treasury)
# Top 10 holders: Should be <50%
```

**Red flags:**
- ❌ Top holder owns >50% (excluding protocol/burn addresses)
- ❌ Top 10 own >80%
- ❌ Very few holders (<100 for a "launched" token)
- ❌ Team addresses hold large amounts unlocked

**Green flags:**
- ✅ Top holder <10% (or is a locked contract)
- ✅ Hundreds or thousands of holders
- ✅ Team tokens are vested/locked
- ✅ Burn address in top holders

**Special addresses to ignore:**
- `0x0000...0000` — Burn address
- Protocol treasury contracts (verify they're timelocked)
- DEX liquidity pools (verify locked)

### 5. Liquidity Check

**Why:** Token with no liquidity can't be traded. Removable liquidity = rug risk.

**How to check:**

**Option A: Via Dune (requires DUNE_API_KEY)**
```bash
# Use dune-analysis skill
./scripts/dune-query.sh query "
SELECT
    pool,
    token0,
    token1,
    tvl_usd
FROM dex.liquidity
WHERE blockchain = '<chain>'
  AND (token0 = <token-address> OR token1 = <token-address>)
ORDER BY tvl_usd DESC
LIMIT 10
"
```

**Option B: Check DEX directly**
- Uniswap: https://info.uniswap.org/#/tokens/<token-address>
- DEX aggregators: CoinGecko, DEXTools

**Red flags:**
- ❌ No DEX liquidity
- ❌ Liquidity <$10k
- ❌ LP tokens not locked
- ❌ Single liquidity provider (can rug)

**Green flags:**
- ✅ Liquidity >$100k
- ✅ LP tokens locked or burned
- ✅ Multiple liquidity providers
- ✅ Listed on major DEXes

### 6. Address Verification

**Why:** Wrong address = lost funds. Scammers create fake tokens with similar names.

**How to verify:**
1. Check official sources (protocol website, GitHub, docs)
2. Cross-reference with:
   - CoinGecko
   - CoinMarketCap
   - Etherscan token tracker
   - Protocol's verified contract list

**Use ethskills addresses module:**
```bash
# Fetch verified addresses from ethskills
curl https://ethskills.com/addresses/SKILL.md
```

**Red flags:**
- ❌ Address only found on random websites
- ❌ No official source lists this address
- ❌ Address differs from CoinGecko/CMC

**Green flags:**
- ✅ Address on protocol's official website
- ✅ Listed on CoinGecko with "verified" badge
- ✅ In ethskills addresses database
- ✅ Matches Etherscan token tracker

### 7. Audit Status

**Why:** Professional audits catch vulnerabilities your review might miss.

**How to check:**
1. Search protocol website for "audit" or "security"
2. Check: `<project-name> audit report` on Google
3. Look for audits from reputable firms:
   - Trail of Bits
   - ConsenSys Diligence
   - OpenZeppelin
   - Certik
   - Quantstamp
   - Spearbit

**Red flags:**
- ❌ No audit
- ❌ Audit is outdated (>1 year for active projects)
- ❌ Audit found critical issues that weren't fixed
- ❌ "Audit" is from unknown firm

**Green flags:**
- ✅ Audited by reputable firm
- ✅ Audit is recent (<6 months)
- ✅ Critical issues were fixed
- ✅ Multiple audits

## Report Card Template

Use this template to present findings:

```markdown
# Token Due Diligence Report

**Token:** <Name> (<SYMBOL>)
**Chain:** <chain-name>
**Address:** `<address>`
**Date:** <YYYY-MM-DD>

---

## Summary

**Overall Risk:** 🔴 HIGH / 🟡 MEDIUM / 🟢 LOW

**Key Findings:**
- [Brief 1-2 sentence summary of main risks]

---

## Detailed Findings

### ✅/❌ Contract Verification
- **Status:** Verified / Not Verified
- **Explorer:** [Link to verified contract]
- **Source:** [Brief description if relevant]

### ✅/❌ Proxy Pattern
- **Upgradeable:** Yes / No
- **Pattern:** [EIP-1967 / UUPS / None]
- **Control:** [EOA / Multisig / Timelock / Renounced]
- **Risk:** [Explanation if upgradeable]

### ✅/❌ Ownership & Privileges
- **Owner:** `<address>` or "Renounced"
- **Owner Type:** [EOA / Multisig (X of Y) / Timelock]
- **Privileged Functions:** [mint, pause, blacklist, etc.]
- **Risk:** [Explanation of what owner can do]

### ✅/❌ Holder Concentration
- **Total Holders:** X,XXX
- **Top Holder:** X.X% (`<address>`)
- **Top 10 Holders:** XX.X%
- **Risk:** [High/Medium/Low concentration]

**Top 5 Holders:**
1. X.X% - `<address>` [Label if known]
2. X.X% - `<address>`
...

### ✅/❌ Liquidity
- **Total Liquidity:** $X,XXX,XXX
- **Main Pool:** [DEX name] - $XXX,XXX
- **LP Locked:** Yes / No [Lock duration if known]
- **Risk:** [Explanation]

### ✅/❌ Address Verification
- **Official Source:** [Link to protocol docs/website]
- **CoinGecko:** [Link if listed]
- **Etherscan:** [Link]
- **Verified:** Yes / No

### ✅/❌ Audit Status
- **Audited:** Yes / No
- **Audit Firm:** [Firm name]
- **Audit Date:** [Date]
- **Link:** [Link to audit report]
- **Critical Issues:** [Number found / Number fixed]

---

## Risk Assessment

**🔴 Critical Risks:**
- [List any critical red flags]

**🟡 Medium Risks:**
- [List any medium concerns]

**🟢 Acceptable:**
- [List green flags]

---

## Recommendation

[Brief recommendation: Safe for integration / Use with caution / Avoid]

---

## Disclaimer

This is a technical analysis only and NOT financial advice. Always:
- Verify all findings independently
- Understand the risks
- Only integrate tokens you trust
- Never invest more than you can afford to lose

**Last Updated:** <YYYY-MM-DD HH:MM UTC>
```

## Common Patterns

### Safe Token (Example: USDC on Ethereum)

- ✅ Verified contract
- ✅ Upgradeable via timelock + multisig
- ✅ Widely distributed holders
- ✅ Deep liquidity on all major DEXes
- ✅ Multiple audits from top firms
- ✅ Official address confirmed

**Risk:** 🟢 Low

### Medium Risk Token (Example: New DeFi token)

- ✅ Verified contract
- ⚠️ Upgradeable (multisig, but no timelock)
- ⚠️ Top 10 holders own 40%
- ✅ Decent liquidity ($500k+)
- ✅ Audited by reputable firm
- ✅ Official address confirmed

**Risk:** 🟡 Medium

### High Risk Token (Example: Meme coin)

- ❌ Not verified / Minimal verification
- ❌ Owner can mint unlimited
- ❌ Top holder owns 60%
- ❌ Liquidity <$50k, not locked
- ❌ No audit
- ❌ Address only on Telegram

**Risk:** 🔴 High — Avoid

## Workflow

### Quick Check (5 minutes)

For a fast risk assessment:

```bash
# 1. Verify contract
./scripts/blockscout-lookup.sh <chain> address <token-address>

# 2. Check holders
./scripts/blockscout-lookup.sh <chain> holders <token-address>

# 3. Search for official address
# Google: "<token-name> official contract address"
# Check: CoinGecko, protocol website
```

**Decision points:**
- Unverified → STOP
- Top holder >50% → HIGH RISK
- Can't verify official address → STOP

### Full Due Diligence (30-60 minutes)

For production integration:

1. **Contract verification** (onchain-lookup)
2. **Get source code** (onchain-lookup)
3. **Review for proxy/ownership** (manual code review)
4. **Check holder distribution** (onchain-lookup + Dune)
5. **Verify liquidity** (Dune + DEX frontends)
6. **Cross-check address** (CoinGecko, ethskills, official docs)
7. **Search for audits** (Google, protocol website)
8. **Generate report** (use template above)

## Tools Summary

- **onchain-lookup skill:** Address, contract, holder data
- **dune-analysis skill:** Liquidity, trading volume, historical data
- **ethskills addresses module:** Verified contract addresses
- **Manual review:** Code audit, proxy pattern detection

## Related Skills

- **onchain-lookup:** Low-level blockchain data lookups
- **dune-analysis:** Historical data and liquidity analysis
- **ethskills-router:** Fetch `security`, `addresses`, `audit` modules
- **protocol-research:** Broader protocol due diligence workflow

## Further Reading

- Ethskills Security: https://ethskills.com/security/SKILL.md
- Ethskills Audit: https://ethskills.com/audit/SKILL.md
- Ethskills Addresses: https://ethskills.com/addresses/SKILL.md
- OpenZeppelin Contracts: https://docs.openzeppelin.com/contracts/
