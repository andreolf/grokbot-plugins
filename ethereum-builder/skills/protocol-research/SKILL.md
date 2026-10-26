---
name: protocol-research
description: Structured workflow for researching DeFi protocols - architecture, trust model, metrics, integration patterns. Produces a research memo with technical analysis and integration recommendations.
---

# Protocol Research

**When to use:** When researching a DeFi protocol for integration, understanding its architecture, or evaluating trust assumptions for building on top of it.

## What This Produces

A **Protocol Research Memo** covering:
1. Protocol overview and architecture
2. Trust model and security
3. Key metrics and usage
4. Integration patterns and APIs
5. Risks and recommendations

## Research Workflow

### Phase 1: Discovery (15-30 minutes)

Gather basic information about the protocol.

#### 1.1 Official Resources

Find and bookmark:
- [ ] Official website
- [ ] Documentation
- [ ] GitHub organization
- [ ] Blog/Twitter for updates
- [ ] Discord/Telegram for support

**Questions:**
- What problem does the protocol solve?
- What's the core value proposition?
- Who's the target user?

#### 1.2 Protocol Architecture

High-level understanding:
- [ ] What type of protocol? (DEX, lending, yield, derivatives, etc.)
- [ ] Key components (contracts, oracles, keepers, etc.)
- [ ] Multi-chain? Which chains?
- [ ] Upgradeable? Governance model?

**Use ethskills:**
```bash
# For general DeFi patterns
curl https://ethskills.com/building-blocks/SKILL.md
```

### Phase 2: Technical Deep Dive (1-2 hours)

#### 2.1 Contract Addresses

Get official contract addresses for target chain.

```bash
# Use onchain-lookup skill
./scripts/blockscout-lookup.sh <chain> address <contract-address>
./scripts/blockscout-lookup.sh <chain> contract <contract-address>
```

**Checklist:**
- [ ] All contracts verified on explorer
- [ ] Addresses match official documentation
- [ ] Note down key contracts (factory, router, pools, etc.)

**Use ethskills addresses:**
```bash
curl https://ethskills.com/addresses/SKILL.md
```

#### 2.2 Trust Model

Understand who controls what.

**Questions to answer:**
- [ ] Who can upgrade contracts? (EOA, multisig, DAO, immutable)
- [ ] Timelock on upgrades? Duration?
- [ ] Admin functions (pause, emergency withdraw, parameter changes)
- [ ] Oracle dependencies? Which oracles? How often updated?
- [ ] Off-chain components? (Keepers, relayers, APIs)

**Contract analysis:**
```bash
# Get contract source
./scripts/blockscout-lookup.sh <chain> contract <contract-address>

# Look for:
# - onlyOwner / onlyAdmin / onlyGovernance
# - Pausable
# - Upgradeable (proxy pattern)
# - External dependencies (oracles, external calls)
```

**Use ethskills:**
```bash
# For security patterns
curl https://ethskills.com/security/SKILL.md

# For CROPS review (Censorship Resistance, Open Source, Privacy, Security)
curl https://ethskills.com/crops/SKILL.md
```

#### 2.3 Security & Audits

Review security posture.

**Checklist:**
- [ ] Audit reports (find on protocol website or GitHub)
- [ ] Audit firms (reputable?)
- [ ] Critical findings (were they fixed?)
- [ ] Bug bounty program (Immunefi, HackerOne?)
- [ ] Past incidents or hacks

**Audit search:**
```bash
# Google: "<protocol-name> audit report"
# Check: protocol docs, GitHub /audits folder, audit firm websites
```

**Known audit firms:**
- Trail of Bits, ConsenSys Diligence, OpenZeppelin, Certik, Quantstamp, Spearbit, Code4rena, Sherlock

### Phase 3: Metrics & Usage (30-60 minutes)

#### 3.1 Key Metrics

Get current protocol metrics.

**Use Dune Analysis:**
```bash
# Search for existing dashboards
./scripts/dune-query.sh search "<protocol-name>"

# Or write custom queries for:
# - Total Value Locked (TVL)
# - Daily/Weekly volume
# - Unique users
# - Fee revenue
# - Token distribution
```

**Common metrics to track:**
- **TVL:** How much value is locked in the protocol?
- **Volume:** Daily/weekly trading or lending volume
- **Users:** Unique addresses interacting
- **Fees:** Protocol revenue and fee distribution
- **Growth:** 30-day, 90-day trends

#### 3.2 Token Analysis (if applicable)

If protocol has a governance/utility token:

```bash
# Use token-diligence skill
# Follow the full checklist:
# - Contract verification
# - Holder concentration
# - Liquidity
# - Ownership/privileges
```

**Questions:**
- [ ] Token utility? (Governance only, revenue share, utility?)
- [ ] Tokenomics (supply, emissions, vesting)
- [ ] Where to acquire? (DEXes, CEXes)

#### 3.3 Liquidity Analysis

For protocols involving tokens/pools:

```bash
# Use Dune to find pool liquidity
./scripts/dune-query.sh query "
SELECT
    pool,
    token0,
    token1,
    tvl_usd
FROM dex.liquidity
WHERE blockchain = '<chain>'
  AND (token0 = <protocol-token-address> OR token1 = <protocol-token-address>)
ORDER BY tvl_usd DESC
LIMIT 10
"
```

**Questions:**
- [ ] Where is deepest liquidity? (Which DEX, which pair)
- [ ] Enough liquidity for our use case?
- [ ] Price impact at expected trade size?

### Phase 4: Integration Patterns (1-2 hours)

#### 4.1 Developer Resources

Find integration guides.

**Checklist:**
- [ ] SDK/library (JavaScript, Python, etc.)
- [ ] Contract ABIs (official source)
- [ ] Integration examples (GitHub repos)
- [ ] API endpoints (REST, GraphQL, RPC)
- [ ] Quickstart guide

**Documentation review:**
- Read: "Developers", "Integration", "API Reference" sections
- Note: Supported languages, code examples, rate limits

#### 4.2 Common Integration Paths

Depending on use case:

**For smart contract integration:**
- [ ] Which contracts to call?
- [ ] Function signatures and parameters
- [ ] Required approvals? (ERC-20 approvals before deposit)
- [ ] Gas estimates
- [ ] Return values and error handling

**For frontend integration:**
- [ ] SDK installation (`npm install ...`)
- [ ] Authentication pattern (wallet connection)
- [ ] Read vs write functions
- [ ] Event subscriptions (for UI updates)

**For backend integration:**
- [ ] RPC calls vs subgraph queries
- [ ] Indexing events (The Graph, Ponder)
- [ ] Webhook support?

**Use ethskills:**
```bash
# For indexing and events
curl https://ethskills.com/indexing/SKILL.md

# For frontend patterns
curl https://ethskills.com/frontend-ux/SKILL.md
```

#### 4.3 Test Integration

Validate on testnet/fork.

```bash
# Fork mainnet locally
yarn fork --network <network>

# Or use testnet deployment
# Check docs for testnet addresses
```

**Testing checklist:**
- [ ] Connect to protocol contracts
- [ ] Read state (balances, reserves, rates)
- [ ] Execute test transaction (deposit/swap/borrow)
- [ ] Verify expected outcome
- [ ] Handle errors gracefully

### Phase 5: Risk Assessment (30 minutes)

#### 5.1 Technical Risks

**Smart contract risks:**
- [ ] Upgradeable contracts (owner can change logic)
- [ ] Unaudited or recent changes
- [ ] Complex logic (higher bug surface)
- [ ] External dependencies (oracles, other protocols)

**Integration risks:**
- [ ] API rate limits
- [ ] Off-chain dependencies (subgraph, relayer)
- [ ] Gas cost volatility
- [ ] Slippage on trades

#### 5.2 Economic Risks

**Market risks:**
- [ ] Low liquidity (slippage, manipulation)
- [ ] Incentive misalignment (can users game the system?)
- [ ] Bank run scenario (what if everyone withdraws?)

**Use CROPS analysis:**
```bash
# Evaluate trust assumptions
curl https://ethskills.com/crops/SKILL.md
```

#### 5.3 Operational Risks

**Ongoing maintenance:**
- [ ] Protocol upgrades (breaking changes?)
- [ ] Contract migrations (users need to move funds?)
- [ ] Oracle updates (what if oracle fails?)
- [ ] Governance decisions (parameters can change)

### Phase 6: Recommendations (15 minutes)

Summarize findings and provide clear recommendations.

**Decision framework:**
- **🟢 Safe to integrate:** Audited, immutable/multisig, deep liquidity, active development
- **🟡 Integrate with caution:** Some risks, but acceptable with monitoring
- **🔴 High risk:** Upgradeable by EOA, unaudited, low liquidity, or other red flags

**Mitigation strategies:**
- Set spending limits (max approve amounts)
- Monitor for contract upgrades
- Diversify across multiple protocols
- Add circuit breakers (pause if anomaly detected)

## Research Memo Template

```markdown
# Protocol Research Memo: <Protocol Name>

**Date:** <YYYY-MM-DD>
**Researcher:** <Your Name>
**Chain(s):** <Ethereum, Base, etc.>
**Protocol Type:** <DEX, Lending, Yield Aggregator, etc.>

---

## Executive Summary

**TL;DR:** [2-3 sentence summary of what the protocol does and key findings]

**Risk Rating:** 🟢 Low / 🟡 Medium / 🔴 High

**Integration Recommendation:** [Recommend / Recommend with monitoring / Do not recommend]

---

## 1. Protocol Overview

### 1.1 What It Does

[Describe the protocol's core functionality in plain language]

### 1.2 Architecture

[High-level diagram or description of key components]

**Key Contracts:**
- **<Contract Name>** (`0x...`) — [Purpose]
- **<Contract Name>** (`0x...`) — [Purpose]
- ...

**Multi-chain:** [List supported chains, or "Ethereum only"]

### 1.3 Official Links

- Website: [URL]
- Docs: [URL]
- GitHub: [URL]
- Twitter: [@handle]
- Discord: [Invite link]

---

## 2. Trust Model & Security

### 2.1 Governance & Upgrades

- **Governance:** [DAO, Multisig, Immutable]
- **Upgrade Mechanism:** [None, Proxy, etc.]
- **Timelock:** [Duration, or N/A]
- **Admin Functions:** [List privileged functions: pause, emergency withdraw, etc.]

### 2.2 Audits

| Audit Firm | Date | Report Link | Critical Issues | Fixed? |
|------------|------|-------------|-----------------|--------|
| [Firm] | [Date] | [Link] | [Count] | [Yes/No] |
| ... | ... | ... | ... | ... |

**Bug Bounty:** [Yes/No] — [Link if available]

**Past Incidents:** [None, or describe any past hacks/exploits]

### 2.3 External Dependencies

- **Oracles:** [Chainlink, Uniswap TWAP, etc.]
- **Other Protocols:** [List if it builds on Uniswap, Aave, etc.]
- **Off-chain:** [Keepers, relayers, APIs]

**Single Points of Failure:** [Describe critical dependencies]

---

## 3. Key Metrics

*(As of <Date>)*

- **Total Value Locked (TVL):** $X,XXX,XXX
- **24h Volume:** $X,XXX,XXX
- **Unique Users (30d):** X,XXX
- **Fee Revenue (30d):** $X,XXX

**Growth Trend:** [Growing / Stable / Declining]

**Dune Dashboard:** [Link if available]

---

## 4. Token Analysis (if applicable)

**Token:** <NAME> (<SYMBOL>)
**Address:** `0x...`

**Utility:** [Governance, revenue share, utility, etc.]

**Distribution:**
- Top holder: X.X%
- Top 10: XX.X%
- Total holders: X,XXX

**Liquidity:**
- Main pool: [DEX] — $X,XXX,XXX TVL
- LP locked: [Yes/No]

**Risk:** 🟢/🟡/🔴 [Brief risk assessment]

*(See full token-diligence report: [link])*

---

## 5. Integration Guide

### 5.1 Developer Resources

- **SDK:** [npm package or GitHub link]
- **Docs:** [Link to integration docs]
- **Examples:** [Link to code examples]
- **Subgraph:** [Link if available]

### 5.2 Smart Contract Integration

**To deposit/interact:**

```solidity
// Example
IProtocol protocol = IProtocol(0x...);

// Approve token
IERC20(token).approve(address(protocol), amount);

// Deposit
protocol.deposit(amount);
```

**Key Functions:**
- `deposit(uint256 amount)` — [Description]
- `withdraw(uint256 amount)` — [Description]
- ...

**Events:**
- `Deposit(address user, uint256 amount)` — [When emitted]
- ...

### 5.3 Frontend Integration

**Install SDK:**
```bash
npm install <package-name>
```

**Example usage:**
```javascript
import { Protocol } from '<package-name>';

const protocol = new Protocol(provider);
const balance = await protocol.getBalance(address);
```

### 5.4 Gas Estimates

| Action | Gas Cost | Cost @ 1 gwei |
|--------|----------|---------------|
| Deposit | ~XXX,XXX | ~$X.XX |
| Withdraw | ~XXX,XXX | ~$X.XX |
| ... | ... | ... |

---

## 6. Risk Assessment

### 🔴 Critical Risks

[List any critical red flags, or "None identified"]

### 🟡 Medium Risks

[List medium concerns]

### 🟢 Acceptable Risks

[List acceptable tradeoffs]

---

## 7. Recommendations

### 7.1 Integration Decision

**Recommendation:** [Integrate / Integrate with caution / Do not integrate]

**Reasoning:** [1-2 paragraph explanation]

### 7.2 Mitigation Strategies

If integrating:
- [ ] [Mitigation 1: e.g., "Set max approval to limit exposure"]
- [ ] [Mitigation 2: e.g., "Monitor for governance proposals"]
- [ ] [Mitigation 3: e.g., "Add circuit breaker for anomalies"]

### 7.3 Monitoring Plan

Ongoing checks:
- [ ] TVL changes (alert if drops >20%)
- [ ] Contract upgrade events
- [ ] Oracle price deviations
- [ ] Protocol Twitter for announcements

---

## 8. Next Steps

- [ ] [Action item 1]
- [ ] [Action item 2]
- [ ] [Action item 3]

---

## Appendix

### A. Verified Contract Addresses

| Contract | Chain | Address | Verified |
|----------|-------|---------|----------|
| [Name] | [Chain] | `0x...` | ✅/❌ |
| ... | ... | ... | ... |

### B. References

- [Link 1: Protocol docs]
- [Link 2: Audit report]
- [Link 3: Dune dashboard]
- ...

---

**Disclaimer:** This memo is for informational purposes only and does not constitute financial advice. Always verify findings independently and consult with security/legal professionals before integration.

**Last Updated:** <YYYY-MM-DD HH:MM UTC>
```

## Research Tools Summary

| Task | Tool/Skill |
|------|------------|
| Contract verification | `onchain-lookup` |
| Token due diligence | `token-diligence` |
| Metrics & analytics | `dune-analysis` |
| Security patterns | `ethskills-router` → security |
| Architecture review | `ethskills-router` → crops |
| Address verification | `ethskills-router` → addresses |
| Integration patterns | `ethskills-router` → building-blocks, indexing |

## Common Protocol Types

### DEX (Decentralized Exchange)

**Focus areas:**
- Liquidity depth and distribution
- Fee structure
- Slippage at expected trade sizes
- LP token mechanics

**Key metrics:** Volume, TVL, unique traders, fees

### Lending Protocol

**Focus areas:**
- Collateralization ratios
- Liquidation mechanisms
- Interest rate models
- Oracle dependencies (price feeds)

**Key metrics:** TVL, borrow/supply rates, liquidations, bad debt

### Yield Aggregator

**Focus areas:**
- Underlying strategies (where does yield come from?)
- Auto-compounding logic
- Deposit/withdraw fees
- Strategy risk (can it lose funds?)

**Key metrics:** APY, TVL, deposits/withdrawals, strategy allocations

### Derivatives / Options

**Focus areas:**
- Settlement mechanism (cash vs physical)
- Oracle for price feeds
- Liquidation engine
- Funding rate calculations

**Key metrics:** Open interest, volume, funding rates, liquidations

## Related Skills

- **onchain-lookup:** For contract and address verification
- **token-diligence:** For token-specific analysis
- **dune-analysis:** For metrics and historical data
- **ethskills-router:** For security, audit, and integration patterns

## Further Reading

- Ethskills Building Blocks: https://ethskills.com/building-blocks/SKILL.md
- Ethskills CROPS: https://ethskills.com/crops/SKILL.md
- Ethskills Security: https://ethskills.com/security/SKILL.md
- Ethskills Audit: https://ethskills.com/audit/SKILL.md
