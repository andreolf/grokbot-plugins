#!/usr/bin/env bash
# blockscout-lookup.sh - Lookup addresses, transactions, contracts, and tokens via Blockscout API

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# API key (optional, from env)
API_KEY="${BLOCKSCOUT_API_KEY:-}"

# Usage
usage() {
    cat << EOF
Usage: $0 <chain> <lookup-type> <identifier> [additional-args]

Chains:
  eth, base, optimism, arbitrum, polygon, gnosis, scroll, zksync, linea
  sepolia, base-sepolia, etc.

Lookup Types:
  address <addr>              - Get address info
  contract <addr>             - Get contract source (if verified)
  tx <hash>                   - Get transaction details
  token <addr>                - Get token info
  token-balance <token> <holder>  - Get token balance for holder
  holders <token>             - Get top token holders

Examples:
  $0 eth address 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
  $0 eth tx 0x1234...
  $0 eth token 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
  $0 eth holders 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

Environment:
  BLOCKSCOUT_API_KEY - Optional API key for higher rate limits
EOF
    exit 1
}

# Chain ID to Blockscout instance mapping
get_blockscout_url() {
    local chain="$1"
    case "$chain" in
        eth|ethereum)
            echo "https://eth.blockscout.com/api"
            ;;
        base)
            echo "https://base.blockscout.com/api"
            ;;
        optimism|op)
            echo "https://optimism.blockscout.com/api"
            ;;
        arbitrum|arb)
            echo "https://arbitrum.blockscout.com/api"
            ;;
        polygon)
            echo "https://polygon.blockscout.com/api"
            ;;
        gnosis)
            echo "https://gnosis.blockscout.com/api"
            ;;
        scroll)
            echo "https://scroll.blockscout.com/api"
            ;;
        zksync)
            echo "https://zksync.blockscout.com/api"
            ;;
        linea)
            echo "https://explorer.linea.build/api"
            ;;
        sepolia)
            echo "https://eth-sepolia.blockscout.com/api"
            ;;
        base-sepolia)
            echo "https://base-sepolia.blockscout.com/api"
            ;;
        *)
            echo -e "${RED}Error: Unknown chain '$chain'${NC}" >&2
            echo "Supported: eth, base, optimism, arbitrum, polygon, gnosis, scroll, zksync, linea, sepolia, base-sepolia" >&2
            exit 1
            ;;
    esac
}

# Make API request with retry logic
api_request() {
    local url="$1"
    local max_retries=3
    local retry_delay=2
    
    for ((i=1; i<=max_retries; i++)); do
        local response
        local http_code
        
        # Add API key header if available
        if [ -n "$API_KEY" ]; then
            response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $API_KEY" "$url" 2>&1) || true
        else
            response=$(curl -s -w "\n%{http_code}" "$url" 2>&1) || true
        fi
        
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | sed '$d')
        
        if [ "$http_code" = "200" ]; then
            echo "$body"
            return 0
        elif [ "$http_code" = "429" ]; then
            if [ $i -lt $max_retries ]; then
                echo -e "${YELLOW}Rate limited, retrying in ${retry_delay}s...${NC}" >&2
                sleep $retry_delay
                retry_delay=$((retry_delay * 2))
            else
                echo -e "${RED}Error: Rate limit exceeded. Try again later or set BLOCKSCOUT_API_KEY.${NC}" >&2
                exit 1
            fi
        else
            echo -e "${RED}Error: HTTP $http_code${NC}" >&2
            echo "$body" >&2
            exit 1
        fi
    done
}

# Parse and format address info
format_address_info() {
    local json="$1"
    
    # Check if response is valid JSON
    if ! echo "$json" | jq empty 2>/dev/null; then
        echo -e "${RED}Error: Invalid response from API${NC}"
        return 1
    fi
    
    local is_contract=$(echo "$json" | jq -r '.is_contract // false')
    local balance=$(echo "$json" | jq -r '.coin_balance // "0"')
    local tx_count=$(echo "$json" | jq -r '.transactions_count // 0')
    
    echo "{"
    echo "  \"is_contract\": $is_contract,"
    echo "  \"balance\": \"$balance\","
    echo "  \"tx_count\": $tx_count"
    
    if [ "$is_contract" = "true" ]; then
        local is_verified=$(echo "$json" | jq -r '.is_verified // false')
        local contract_name=$(echo "$json" | jq -r '.name // "Unknown"')
        echo "  ,\"is_verified\": $is_verified,"
        echo "  \"name\": \"$contract_name\""
    fi
    
    echo "}"
}

# Main
if [ $# -lt 3 ]; then
    usage
fi

CHAIN="$1"
LOOKUP_TYPE="$2"
IDENTIFIER="$3"

BASE_URL=$(get_blockscout_url "$CHAIN")

case "$LOOKUP_TYPE" in
    address)
        echo -e "${GREEN}Looking up address on $CHAIN...${NC}"
        url="$BASE_URL?module=account&action=balance&address=$IDENTIFIER"
        response=$(api_request "$url")
        
        # Also get contract info if it's a contract
        url2="$BASE_URL?module=contract&action=getsourcecode&address=$IDENTIFIER"
        contract_info=$(api_request "$url2")
        
        # Combine and format
        echo "$response" | jq -r "." 2>/dev/null || echo "$response"
        ;;
        
    contract)
        echo -e "${GREEN}Fetching contract source on $CHAIN...${NC}"
        url="$BASE_URL?module=contract&action=getsourcecode&address=$IDENTIFIER"
        response=$(api_request "$url")
        
        # Check if verified
        is_verified=$(echo "$response" | jq -r '.result[0].SourceCode' | grep -q "^$" && echo "false" || echo "true")
        
        if [ "$is_verified" = "false" ]; then
            echo -e "${YELLOW}Warning: Contract is not verified${NC}"
            echo "{\"error\": \"Contract not verified\", \"address\": \"$IDENTIFIER\"}"
            exit 1
        fi
        
        echo "$response" | jq -r ".result[0]" 2>/dev/null || echo "$response"
        ;;
        
    tx)
        echo -e "${GREEN}Fetching transaction on $CHAIN...${NC}"
        url="$BASE_URL?module=transaction&action=gettxinfo&txhash=$IDENTIFIER"
        response=$(api_request "$url")
        echo "$response" | jq -r "." 2>/dev/null || echo "$response"
        ;;
        
    token)
        echo -e "${GREEN}Fetching token info on $CHAIN...${NC}"
        url="$BASE_URL?module=token&action=getToken&contractaddress=$IDENTIFIER"
        response=$(api_request "$url")
        echo "$response" | jq -r ".result" 2>/dev/null || echo "$response"
        ;;
        
    token-balance)
        if [ $# -lt 4 ]; then
            echo -e "${RED}Error: token-balance requires <token-address> <holder-address>${NC}"
            usage
        fi
        HOLDER="$4"
        echo -e "${GREEN}Fetching token balance on $CHAIN...${NC}"
        url="$BASE_URL?module=account&action=tokenbalance&contractaddress=$IDENTIFIER&address=$HOLDER"
        response=$(api_request "$url")
        echo "$response" | jq -r "." 2>/dev/null || echo "$response"
        ;;
        
    holders)
        echo -e "${GREEN}Fetching top token holders on $CHAIN...${NC}"
        url="$BASE_URL?module=token&action=getTokenHolders&contractaddress=$IDENTIFIER"
        response=$(api_request "$url")
        echo "$response" | jq -r ".result" 2>/dev/null || echo "$response"
        ;;
        
    *)
        echo -e "${RED}Error: Unknown lookup type '$LOOKUP_TYPE'${NC}"
        usage
        ;;
esac
