#!/bin/bash
# Firebird Public Installer - Handles private repo access gracefully

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging setup
LOG_FILE="/tmp/firebird-installer-$(date +%Y%m%d-%H%M%S).log"
DEBUG=${DEBUG:-false}

# Log function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Write to log file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Also display based on level
    case $level in
        ERROR)
            echo -e "${RED}❌ $message${NC}" >&2
            ;;
        SUCCESS)
            echo -e "${GREEN}✓ $message${NC}"
            ;;
        INFO)
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
        DEBUG)
            if [ "$DEBUG" = "true" ]; then
                echo -e "${PURPLE}🔍 $message${NC}"
            fi
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Show log location at start
echo -e "${PURPLE}📝 Installation log: $LOG_FILE${NC}"

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       🔥 Firebird Installer          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# Check if we already have firebird
log DEBUG "Checking for existing firebird installation at $HOME/firebird"
if [ -d "$HOME/firebird" ]; then
    log INFO "Firebird already installed at $HOME/firebird"
    log INFO "Running existing installer..."
    if ! cd "$HOME/firebird"; then
        log ERROR "Failed to change directory to $HOME/firebird"
        exit 1
    fi
    if [ ! -x "./install.sh" ]; then
        log ERROR "install.sh not found or not executable"
        exit 1
    fi
    ./install.sh
    exit $?
fi

# Try SSH first (fastest if configured)
log INFO "Attempting to clone firebird via SSH..."
log DEBUG "Running: git clone git@github.com:nixfred/firebird.git $HOME/firebird"

if git clone git@github.com:nixfred/firebird.git "$HOME/firebird" 2>>"$LOG_FILE"; then
    log SUCCESS "Cloned successfully with SSH"
    if ! cd "$HOME/firebird"; then
        log ERROR "Failed to change directory to $HOME/firebird"
        exit 1
    fi
    if [ ! -x "./install.sh" ]; then
        log ERROR "install.sh not found or not executable"
        exit 1
    fi
    ./install.sh
    exit $?
else
    log DEBUG "SSH clone failed, will try token method"
    # Clean up any partial clone
    rm -rf "$HOME/firebird" 2>/dev/null || true
fi

# SSH failed, try with token
log INFO "SSH access not configured. Let's use a token instead."
echo ""
echo "You need a GitHub Personal Access Token to clone the private firebird repo."
echo ""
echo -e "${BLUE}To create one:${NC}"
echo "1. Open: https://github.com/settings/tokens/new"
echo "2. Name: 'firebird-access' (or anything)"
echo "3. Expiration: Your choice (90 days recommended)"
echo "4. Scopes: Select only 'repo' checkbox"
echo "5. Click 'Generate token' and copy it"
echo ""
echo -e "${YELLOW}The token looks like: ghp_xxxxxxxxxxxxxxxxxxxx${NC}"
echo ""

# Prompt for token
echo "Paste your GitHub token and press Enter:"
read -s GITHUB_TOKEN
echo  # New line after hidden input

if [ -z "$GITHUB_TOKEN" ]; then
    log ERROR "No token provided"
    log DEBUG "Token was empty or not entered"
    echo "Installation cancelled. Log file: $LOG_FILE"
    exit 1
fi

log DEBUG "Token received"

# Try to clone with token
log INFO "Cloning firebird with token..."
log DEBUG "Clone URL: https://[TOKEN]@github.com/nixfred/firebird.git"

# Clone with token and capture output
if git clone "https://${GITHUB_TOKEN}@github.com/nixfred/firebird.git" "$HOME/firebird" 2>>"$LOG_FILE"; then
    log SUCCESS "Cloned successfully!"
    
    # Remove token from git config for security
    cd "$HOME/firebird"
    log DEBUG "Removing token from git config for security"
    git remote set-url origin git@github.com:nixfred/firebird.git
    
    log INFO "Running firebird installer..."
    log DEBUG "Log file will be available at: $LOG_FILE"
    
    # Run the real installer
    if [ ! -x "./install.sh" ]; then
        log ERROR "install.sh not found or not executable"
        exit 1
    fi
    ./install.sh
    EXIT_CODE=$?
    
    # Clear sensitive token from memory
    GITHUB_TOKEN=""
    
    exit $EXIT_CODE
else
    log ERROR "Failed to clone firebird repository"
    echo "   - Token has 'repo' scope"
    echo "   - Token is valid"
    echo "   - You have access to nixfred/firebird"
    echo ""
    echo -e "${PURPLE}Check the log for details: $LOG_FILE${NC}"
    echo -e "${PURPLE}Debug mode: DEBUG=true bash get-firebird.sh${NC}"
    exit 1
fi