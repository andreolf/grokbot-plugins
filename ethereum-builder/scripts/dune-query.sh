#!/usr/bin/env bash
# dune-query.sh - Query Dune Analytics via API

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check for API key
if [ -z "${DUNE_API_KEY:-}" ]; then
    echo -e "${RED}Error: DUNE_API_KEY environment variable not set${NC}" >&2
    echo "Get your API key from: https://dune.com/settings/api" >&2
    echo "Then: export DUNE_API_KEY='your-api-key-here'" >&2
    exit 1
fi

API_KEY="$DUNE_API_KEY"
BASE_URL="https://api.dune.com/api/v1"

# Usage
usage() {
    cat << EOF
Usage: $0 <action> [args]

Actions:
  search <keyword>           - Search for queries by keyword
  execute <query-id>         - Execute a saved query by ID
  query "<sql>"              - Execute custom SQL
  info <query-id>            - Get query metadata
  status <execution-id>      - Check execution status
  results <execution-id>     - Get results for completed execution

Examples:
  $0 search "uniswap v3 volume"
  $0 execute 12345
  $0 query "SELECT * FROM ethereum.transactions LIMIT 10"
  $0 info 12345
  $0 status abc123-def456-ghi789
  $0 results abc123-def456-ghi789

Environment:
  DUNE_API_KEY - Required. Get from https://dune.com/settings/api
EOF
    exit 1
}

# Make API request
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"
    
    local url="$BASE_URL$endpoint"
    local curl_args=(-s -X "$method" -H "X-Dune-API-Key: $API_KEY" -H "Content-Type: application/json")
    
    if [ -n "$data" ]; then
        curl_args+=(-d "$data")
    fi
    
    local response
    response=$(curl "${curl_args[@]}" "$url" 2>&1) || {
        echo -e "${RED}Error: API request failed${NC}" >&2
        return 1
    }
    
    # Check for error in response
    if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
        local error_msg=$(echo "$response" | jq -r '.error')
        echo -e "${RED}Error: $error_msg${NC}" >&2
        return 1
    fi
    
    echo "$response"
}

# Wait for query execution to complete
wait_for_execution() {
    local execution_id="$1"
    local max_wait=300  # 5 minutes
    local waited=0
    local check_interval=2
    
    echo -e "${YELLOW}Waiting for execution to complete...${NC}" >&2
    
    while [ $waited -lt $max_wait ]; do
        local status_response
        status_response=$(api_request GET "/execution/$execution_id/status")
        
        local state=$(echo "$status_response" | jq -r '.state')
        
        case "$state" in
            QUERY_STATE_COMPLETED)
                echo -e "${GREEN}Execution completed${NC}" >&2
                return 0
                ;;
            QUERY_STATE_FAILED)
                local error=$(echo "$status_response" | jq -r '.error // "Unknown error"')
                echo -e "${RED}Query failed: $error${NC}" >&2
                return 1
                ;;
            QUERY_STATE_EXECUTING|QUERY_STATE_PENDING)
                echo -ne "${YELLOW}Status: $state (${waited}s elapsed)...\r${NC}" >&2
                sleep $check_interval
                waited=$((waited + check_interval))
                ;;
            *)
                echo -e "${RED}Unknown state: $state${NC}" >&2
                return 1
                ;;
        esac
    done
    
    echo -e "${RED}Timeout: Query execution exceeded ${max_wait}s${NC}" >&2
    return 1
}

# Main
if [ $# -lt 1 ]; then
    usage
fi

ACTION="$1"
shift

case "$ACTION" in
    search)
        if [ $# -lt 1 ]; then
            echo -e "${RED}Error: search requires a keyword${NC}"
            usage
        fi
        KEYWORD="$1"
        
        echo -e "${GREEN}Searching Dune queries for: $KEYWORD${NC}"
        # Note: Dune API doesn't have a direct search endpoint
        # This is a placeholder - in practice, users should search on dune.com
        echo -e "${YELLOW}Tip: Search for queries at https://dune.com/browse/queries?q=$(echo "$KEYWORD" | sed 's/ /+/g')${NC}"
        echo "The Dune API doesn't support text search. Please:"
        echo "1. Search on dune.com"
        echo "2. Copy the query ID from the URL"
        echo "3. Use: $0 execute <query-id>"
        ;;
        
    execute)
        if [ $# -lt 1 ]; then
            echo -e "${RED}Error: execute requires a query ID${NC}"
            usage
        fi
        QUERY_ID="$1"
        
        echo -e "${GREEN}Executing query $QUERY_ID...${NC}"
        
        # Execute query
        response=$(api_request POST "/query/$QUERY_ID/execute")
        execution_id=$(echo "$response" | jq -r '.execution_id')
        
        if [ -z "$execution_id" ] || [ "$execution_id" = "null" ]; then
            echo -e "${RED}Error: Failed to start execution${NC}"
            echo "$response"
            exit 1
        fi
        
        echo "Execution ID: $execution_id"
        
        # Wait for completion
        if wait_for_execution "$execution_id"; then
            # Get results
            results=$(api_request GET "/execution/$execution_id/results")
            echo "$results" | jq '.'
        else
            exit 1
        fi
        ;;
        
    query)
        if [ $# -lt 1 ]; then
            echo -e "${RED}Error: query requires SQL${NC}"
            usage
        fi
        SQL="$1"
        
        echo -e "${GREEN}Executing custom SQL...${NC}"
        
        # Create ad-hoc query
        data=$(jq -n --arg sql "$SQL" '{query_sql: $sql}')
        response=$(api_request POST "/query/execute" "$data")
        
        execution_id=$(echo "$response" | jq -r '.execution_id')
        
        if [ -z "$execution_id" ] || [ "$execution_id" = "null" ]; then
            echo -e "${RED}Error: Failed to start execution${NC}"
            echo "$response"
            exit 1
        fi
        
        echo "Execution ID: $execution_id"
        
        # Wait for completion
        if wait_for_execution "$execution_id"; then
            # Get results
            results=$(api_request GET "/execution/$execution_id/results")
            echo "$results" | jq '.'
        else
            exit 1
        fi
        ;;
        
    info)
        if [ $# -lt 1 ]; then
            echo -e "${RED}Error: info requires a query ID${NC}"
            usage
        fi
        QUERY_ID="$1"
        
        echo -e "${GREEN}Fetching query info for $QUERY_ID...${NC}"
        response=$(api_request GET "/query/$QUERY_ID")
        echo "$response" | jq '.'
        ;;
        
    status)
        if [ $# -lt 1 ]; then
            echo -e "${RED}Error: status requires an execution ID${NC}"
            usage
        fi
        EXECUTION_ID="$1"
        
        echo -e "${GREEN}Checking execution status...${NC}"
        response=$(api_request GET "/execution/$EXECUTION_ID/status")
        echo "$response" | jq '.'
        ;;
        
    results)
        if [ $# -lt 1 ]; then
            echo -e "${RED}Error: results requires an execution ID${NC}"
            usage
        fi
        EXECUTION_ID="$1"
        
        echo -e "${GREEN}Fetching execution results...${NC}"
        response=$(api_request GET "/execution/$EXECUTION_ID/results")
        echo "$response" | jq '.'
        ;;
        
    *)
        echo -e "${RED}Error: Unknown action '$ACTION'${NC}"
        usage
        ;;
esac
