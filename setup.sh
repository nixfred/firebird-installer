#!/bin/bash
# One-command setup for firebird-installer

set -e

# Check if gh CLI is installed
if command -v gh &> /dev/null; then
    echo "Using GitHub CLI to create repository..."
    
    # Create public repo with gh CLI
    if gh repo create nixfred/firebird-installer --public --description "Public installer for private firebird repository" --source=. --remote=origin --push; then
        echo "✅ Success! Repository created and pushed."
        echo ""
        echo "🎉 Your magic one-liner is ready:"
        echo ""
        echo "curl -fsSL https://raw.githubusercontent.com/nixfred/firebird-installer/main/install.sh | bash"
        echo ""
        exit 0
    else
        echo "Failed to create repo with gh CLI, falling back to token method..."
    fi
fi

# Fallback to token method
echo "Please paste your GitHub token and press Enter:"
read -s TOKEN

if [ -z "$TOKEN" ]; then
    echo "No token provided!"
    exit 1
fi

# Create repo with API
echo "Creating repository..."
curl -s -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     -X POST \
     -d '{"name":"firebird-installer","description":"Public installer for private firebird repository","public":true}' \
     https://api.github.com/user/repos > /dev/null

# Push with token
git remote add origin https://$TOKEN@github.com/nixfred/firebird-installer.git 2>/dev/null || true
git branch -M main
git push -u origin main

# Switch to SSH
git remote set-url origin git@github.com:nixfred/firebird-installer.git

echo ""
echo "✅ Success! Repository created and pushed."
echo ""
echo "🎉 Your magic one-liner is ready:"
echo ""
echo "curl -fsSL https://raw.githubusercontent.com/nixfred/firebird-installer/main/install.sh | bash"
echo ""