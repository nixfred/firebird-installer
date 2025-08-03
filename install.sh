#!/bin/bash
# Firebird Public Installer - Handles private repo access gracefully

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       🔥 Firebird Installer          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# Check if we already have firebird
if [ -d "$HOME/firebird" ]; then
    echo -e "${YELLOW}Firebird already installed at $HOME/firebird${NC}"
    echo "Running existing installer..."
    cd "$HOME/firebird" && ./install.sh
    exit 0
fi

# Try SSH first (fastest if configured)
echo -e "${YELLOW}Attempting to clone firebird...${NC}"
if git clone git@github.com:nixfred/firebird.git "$HOME/firebird" 2>/dev/null; then
    echo -e "${GREEN}✓ Cloned successfully with SSH${NC}"
    cd "$HOME/firebird" && ./install.sh
    exit 0
fi

# SSH failed, try with token
echo -e "${YELLOW}SSH access not configured. Let's use a token instead.${NC}"
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

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ No token provided${NC}"
    exit 1
fi

# Try to clone with token
echo -e "${YELLOW}Cloning firebird...${NC}"
# Use token as username with 'x-oauth-basic' as password
if git clone "https://${GITHUB_TOKEN}:x-oauth-basic@github.com/nixfred/firebird.git" "$HOME/firebird" 2>&1 | grep -v "Cloning into"; then
    echo -e "${GREEN}✓ Cloned successfully!${NC}"
    
    # Remove token from git config for security
    cd "$HOME/firebird"
    git remote set-url origin git@github.com:nixfred/firebird.git
    
    # Run the real installer
    ./install.sh
else
    echo -e "${RED}❌ Failed to clone. Please check:${NC}"
    echo "   - Token has 'repo' scope"
    echo "   - Token is valid"
    echo "   - You have access to nixfred/firebird"
    exit 1
fi