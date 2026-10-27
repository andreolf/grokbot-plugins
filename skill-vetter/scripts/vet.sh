#!/usr/bin/env bash
# vet.sh - Static security analysis for Cursor/Grok Bot skills and plugins
#
# Usage:
#   ./vet.sh /path/to/skill-folder              # Vet a single skill
#   ./vet.sh --plugin /path/to/plugin-folder    # Vet an entire plugin
#
# Exit codes:
#   0 = PASS (safe)
#   1 = WARN (review needed)
#   2 = FAIL (reject)

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Result tracking
EXIT_CODE=0
WARNINGS=0
FAILURES=0

# Functions
pass() {
    echo -e "${GREEN}✓ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
    WARNINGS=$((WARNINGS + 1))
    if [ $EXIT_CODE -lt 1 ]; then
        EXIT_CODE=1
    fi
}

fail() {
    echo -e "${RED}✗ $1${NC}"
    FAILURES=$((FAILURES + 1))
    EXIT_CODE=2
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check for data exfiltration patterns
check_exfiltration() {
    local target="$1"
    local found=0
    
    info "Checking for data exfiltration patterns..."
    
    # curl/wget to external domains (excluding common safe domains)
    if grep -rn "curl\|wget" "$target" \
        --include="*.md" --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -v "github.com\|githubusercontent.com\|npmjs.com\|pypi.org\|wttr.in\|ipinfo.io" | \
        grep -Ev "^[^:]*:(#|<!--)" | grep -v "grep -rn" | grep . ; then
        warn "Network calls to external domains found (review manually)"
        found=1
    fi
    
    # Webhook patterns
    if grep -rn "webhook\|pastebin\|requestbin\|ngrok" "$target" \
        --include="*.md" --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -Ev "^[^:]*:(#|<!--)" | grep -v "grep -rn" | grep . ; then
        fail "Webhook or data aggregator found"
        found=1
    fi
    
    # POST with data
    if grep -rn "curl.*-d\|curl.*--data\|wget.*--post-data" "$target" \
        --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -v "grep -rn" | grep . ; then
        warn "POST request with data found (verify destination)"
        found=1
    fi
    
    if [ $found -eq 0 ]; then
        pass "No data exfiltration patterns"
    fi
}

# Check for credential and secret reads
check_credentials() {
    local target="$1"
    local found=0
    
    info "Checking for credential reads..."
    
    # Sensitive directories
    if grep -rn "\~/\.ssh\|~/.aws\|~/.gnupg\|~/.config" "$target" \
        --include="*.md" --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -Ev "^[^:]*:(#|<!--)" | grep -v "grep -rn" | grep . ; then
        fail "Accesses sensitive directories (~/.ssh, ~/.aws, etc.)"
        found=1
    fi
    
    # Credential files
    if grep -rn "id_rsa\|id_ed25519\|credentials\.json\|\.pem\|\.key" "$target" \
        --include="*.md" --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -Ev "^[^:]*:(#|<!--)" | grep -v "grep -rn" | grep . ; then
        fail "Accesses credential files"
        found=1
    fi
    
    # Browser cookies
    if grep -rn "Cookies\|cookies\.sqlite\|Login Data" "$target" \
        --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -Ev "^[^:]*:(#|<!--)" | grep -v "grep -rn" | grep . ; then
        fail "Accesses browser cookies or login data"
        found=1
    fi
    
    # Keychain access
    if grep -rn "security find\|keychain\|Credential Manager" "$target" \
        --include="*.sh" --include="*.py" 2>/dev/null | \
        grep -v "grep -rn" | grep . ; then
        fail "Accesses system keychain or credential manager"
        found=1
    fi
    
    # Agent memory files
    if grep -rn "MEMORY\.md\|USER\.md\|SOUL\.md\|IDENTITY\.md" "$target" \
        --include="*.md" --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -Ev "^[^:]*:(#|<!--)" | grep -v "grep -rn" | grep . ; then
        warn "Accesses agent memory files (verify purpose)"
        found=1
    fi
    
    if [ $found -eq 0 ]; then
        pass "No credential reads"
    fi
}

# Check for remote code execution
check_remote_execution() {
    local target="$1"
    local found=0
    
    info "Checking for remote code execution..."
    
    # curl|sh and wget|bash patterns
    if grep -rn "curl.*|.*sh\|wget.*|.*bash\|curl.*|.*python\|wget.*|.*python" "$target" \
        --include="*.md" --include="*.sh" 2>/dev/null | \
        grep -Ev "^[^:]*:(#|<!--)" | grep -v "grep -rn" | grep . ; then
        fail "Remote code execution pattern (curl|sh or wget|bash)"
        found=1
    fi
    
    # eval with remote data
    if grep -rn "eval.*\$(\|eval.*\`" "$target" \
        --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -v "grep -rn" | grep . ; then
        warn "eval() with command substitution found (verify it's not remote data)"
        found=1
    fi
    
    # exec with remote data
    if grep -rn "exec.*curl\|exec.*wget" "$target" \
        --include="*.sh" --include="*.py" 2>/dev/null | \
        grep -v "grep -rn" | grep . ; then
        fail "exec() with remote data"
        found=1
    fi
    
    # Unpinned downloads
    if grep -rn "curl.*-o\|wget.*-O" "$target" \
        --include="*.sh" 2>/dev/null | \
        grep -v "sha256\|checksum\|verify" | grep -v "grep -rn" | grep . ; then
        warn "Unpinned download found (no checksum verification)"
        found=1
    fi
    
    if [ $found -eq 0 ]; then
        pass "No remote execution patterns"
    fi
}

# Check for hidden or encoded instructions
check_hidden_instructions() {
    local target="$1"
    local found=0
    
    info "Checking for hidden instructions..."
    
    # Base64 blobs (longer than 50 chars)
    if grep -rn "[A-Za-z0-9+/]\{50,\}=*" "$target" \
        --include="*.md" --include="*.sh" --include="*.py" --include="*.js" 2>/dev/null | \
        grep -v "grep -rn" | grep . ; then
        warn "Base64-like blob found (verify it's documented data, not hidden instructions)"
        found=1
    fi
    
    # Hex blobs (longer than 40 chars)
    if grep -rn "0x[0-9a-fA-F]\{40,\}" "$target" \
        --include="*.md" --include="*.sh" --include="*.py" 2>/dev/null | \
        grep -v "grep -rn" | grep . ; then
        warn "Hex blob found (verify purpose)"
        found=1
    fi
    
    # Zero-width unicode characters
    if grep -rn $'\u200B\|\u200C\|\u200D\|\uFEFF' "$target" \
        --include="*.md" 2>/dev/null | grep -v "grep -rn" | grep . ; then
        fail "Zero-width unicode characters found (possible hidden instructions)"
        found=1
    fi
    
    # Bidirectional unicode (used for text injection attacks)
    if grep -rn $'\u202E\|\u202D' "$target" \
        --include="*.md" 2>/dev/null | grep -v "grep -rn" | grep . ; then
        fail "Bidirectional unicode override found (possible hidden instructions)"
        found=1
    fi
    
    # Prompt injection phrases in HTML comments
    if grep -rn "<!--.*ignore.*previous\|<!--.*disregard\|<!--.*override" "$target" \
        --include="*.md" 2>/dev/null | grep -v "grep -rn" | grep . ; then
        fail "Prompt injection in HTML comments"
        found=1
    fi
    
    if [ $found -eq 0 ]; then
        pass "No hidden instructions"
    fi
}

# Check for over-broad permissions
check_permissions() {
    local target="$1"
    local found=0
    
    info "Checking for over-broad permissions..."
    
    # Sudo/root
    if grep -rn "sudo\|su -\|su root" "$target" \
        --include="*.md" --include="*.sh" 2>/dev/null | \
        grep -Ev "^[^:]*:(#|<!--)" | grep -v "grep -rn" | grep . ; then
        fail "Requests sudo or root access"
        found=1
    fi
    
    # Wildcard paths
    if grep -rn "/\*\|~/\*\|\.\./\*" "$target" \
        --include="*.md" --include="*.sh" 2>/dev/null | \
        grep -Ev "^[^:]*:(#|<!--|find|ls|rm)" | grep -v "grep -rn" | grep . ; then
        warn "Wildcard file paths found (verify scope is justified)"
        found=1
    fi
    
    if [ $found -eq 0 ]; then
        pass "Permissions are scoped"
    fi
}

# Check plugin manifest
check_manifest() {
    local plugin_dir="$1"
    local manifest="$plugin_dir/.cursor-plugin/plugin.json"
    
    info "Checking plugin manifest..."
    
    if [ ! -f "$manifest" ]; then
        fail "plugin.json not found"
        return
    fi
    
    # Validate JSON
    if ! jq empty "$manifest" 2>/dev/null; then
        fail "plugin.json is invalid JSON"
        return
    fi
    
    # Check required fields
    if ! jq -e '.name' "$manifest" >/dev/null 2>&1; then
        fail "Missing required field: name"
    fi
    
    if ! jq -e '.author.name' "$manifest" >/dev/null 2>&1; then
        fail "Missing required field: author.name"
    fi
    
    # Check for suspicious keywords
    local keywords=$(jq -r '.keywords[]? // empty' "$manifest" 2>/dev/null)
    if echo "$keywords" | grep -i "hack\|bypass\|exploit\|crack" >/dev/null; then
        warn "Suspicious keywords in manifest"
    fi
    
    if [ $FAILURES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        pass "Manifest valid"
    fi
}

# Vet a single skill
vet_skill() {
    local skill_dir="$1"
    
    echo "Vetting skill: $(basename "$skill_dir")"
    echo "─────────────────────────────────────────"
    
    if [ ! -d "$skill_dir" ]; then
        fail "Directory not found: $skill_dir"
        return $EXIT_CODE
    fi
    
    if [ ! -f "$skill_dir/SKILL.md" ]; then
        fail "SKILL.md not found in $skill_dir"
        return $EXIT_CODE
    fi
    
    check_exfiltration "$skill_dir"
    check_credentials "$skill_dir"
    check_remote_execution "$skill_dir"
    check_hidden_instructions "$skill_dir"
    check_permissions "$skill_dir"
    
    echo
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}RESULT: PASS${NC} (exit 0)"
    elif [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}RESULT: WARN${NC} (exit 1) - $WARNINGS warning(s)"
    else
        echo -e "${RED}RESULT: FAIL${NC} (exit 2) - $FAILURES failure(s)"
    fi
    
    return $EXIT_CODE
}

# Vet an entire plugin
vet_plugin() {
    local plugin_dir="$1"
    
    echo "Vetting plugin: $(basename "$plugin_dir")"
    echo "═════════════════════════════════════════"
    echo
    
    if [ ! -d "$plugin_dir" ]; then
        fail "Directory not found: $plugin_dir"
        return $EXIT_CODE
    fi
    
    check_manifest "$plugin_dir"
    echo
    
    # Check each skill
    local skills_dir="$plugin_dir/skills"
    if [ -d "$skills_dir" ]; then
        info "Checking skills..."
        local skill_count=0
        for skill_dir in "$skills_dir"/*/; do
            if [ ! -d "$skill_dir" ]; then
                continue
            fi
            skill_count=$((skill_count + 1))
            local skill_name=$(basename "$skill_dir")
            
            # Save current exit code
            local prev_exit=$EXIT_CODE
            local prev_warns=$WARNINGS
            local prev_fails=$FAILURES
            
            # Reset for this skill
            EXIT_CODE=0
            WARNINGS=0
            FAILURES=0
            
            # Vet skill silently
            local skill_result
            if check_exfiltration "$skill_dir" >/dev/null 2>&1 && \
               check_credentials "$skill_dir" >/dev/null 2>&1 && \
               check_remote_execution "$skill_dir" >/dev/null 2>&1 && \
               check_hidden_instructions "$skill_dir" >/dev/null 2>&1 && \
               check_permissions "$skill_dir" >/dev/null 2>&1; then
                skill_result="PASS"
            elif [ $EXIT_CODE -eq 1 ]; then
                skill_result="WARN"
            else
                skill_result="FAIL"
            fi
            
            # Restore aggregate exit code (take max)
            if [ $EXIT_CODE -gt $prev_exit ]; then
                prev_exit=$EXIT_CODE
            fi
            WARNINGS=$((prev_warns + WARNINGS))
            FAILURES=$((prev_fails + FAILURES))
            EXIT_CODE=$prev_exit
            
            if [ "$skill_result" = "PASS" ]; then
                pass "$skill_name: PASS"
            elif [ "$skill_result" = "WARN" ]; then
                warn "$skill_name: WARN"
            else
                fail "$skill_name: FAIL"
            fi
        done
        echo
    fi
    
    # Check scripts
    if [ -d "$plugin_dir/scripts" ]; then
        info "Checking scripts..."
        check_exfiltration "$plugin_dir/scripts"
        check_credentials "$plugin_dir/scripts"
        check_remote_execution "$plugin_dir/scripts"
        check_hidden_instructions "$plugin_dir/scripts"
        check_permissions "$plugin_dir/scripts"
        echo
    fi
    
    # Check hooks
    if [ -d "$plugin_dir/.cursor-plugin/hooks" ]; then
        info "Checking hooks..."
        check_exfiltration "$plugin_dir/.cursor-plugin/hooks"
        check_credentials "$plugin_dir/.cursor-plugin/hooks"
        check_remote_execution "$plugin_dir/.cursor-plugin/hooks"
        check_permissions "$plugin_dir/.cursor-plugin/hooks"
        echo
    fi
    
    echo
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}RESULT: PASS${NC} (exit 0)"
        echo "All skills and plugin components passed."
    elif [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}RESULT: WARN${NC} (exit 1)"
        echo "$WARNINGS warning(s) found. Manual review recommended."
    else
        echo -e "${RED}RESULT: FAIL${NC} (exit 2)"
        echo "$FAILURES failure(s) found. DO NOT INSTALL."
    fi
    
    return $EXIT_CODE
}

# Main
main() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 /path/to/skill-folder"
        echo "       $0 --plugin /path/to/plugin-folder"
        exit 1
    fi
    
    if [ "$1" = "--plugin" ]; then
        if [ $# -lt 2 ]; then
            echo "Error: --plugin requires a path argument"
            exit 1
        fi
        vet_plugin "$2"
    else
        vet_skill "$1"
    fi
}

main "$@"
