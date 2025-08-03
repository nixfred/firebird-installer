#!/bin/bash
# Script to create the firebird-installer repo on GitHub

set -e

echo "This script will create the firebird-installer repo on GitHub"
echo ""
read -sp "Enter your GitHub token: " GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: No token provided"
    exit 1
fi

echo "Creating repository on GitHub..."

# Create the repo
RESPONSE=$(curl -s -w "\n%{http_code}" \
     -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     -X POST \
     -d '{"name":"firebird-installer","description":"Public installer for private firebird repository","public":true}' \
     https://api.github.com/user/repos)

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "201" ]; then
    echo "✓ Repository created successfully!"
elif [ "$HTTP_CODE" = "422" ]; then
    echo "Repository might already exist, continuing..."
else
    echo "Error creating repository. HTTP code: $HTTP_CODE"
    echo "Response: $BODY"
    exit 1
fi

# Add remote and push
echo "Pushing code to GitHub..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://${GITHUB_TOKEN}@github.com/nixfred/firebird-installer.git"
git branch -M main
git push -u origin main

# Switch to SSH for security
echo "Switching to SSH remote..."
git remote set-url origin git@github.com:nixfred/firebird-installer.git

echo ""
echo "✅ Success! The firebird-installer repo is now public on GitHub"
echo ""
echo "The magic one-liner is now ready:"
echo ""
echo "curl -fsSL https://raw.githubusercontent.com/nixfred/firebird-installer/main/install.sh | bash"
echo ""
echo "This will work on any fresh Ubuntu machine!"

# Clean up
rm -f create-repo.sh