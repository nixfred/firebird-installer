# Firebird Installer

Public installer for the private firebird repository.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/nixfred/firebird-installer/main/install.sh | bash
```

## What This Does

1. Checks if you have SSH access to GitHub
2. If not, prompts for a GitHub Personal Access Token
3. Clones the private firebird repository
4. Runs the firebird installer
5. Removes the token from local config for security

## Creating a GitHub Token

1. Go to: https://github.com/settings/tokens/new
2. Name: `firebird-access`
3. Expiration: 90 days (or your preference)
4. Scopes: ✅ `repo` (that's all!)
5. Generate and copy the token

## Security Note

The token is only used once to clone the repository. After cloning, the remote URL is switched to SSH to avoid storing the token.

---

For more information, see the main [firebird](https://github.com/nixfred/firebird) repository.