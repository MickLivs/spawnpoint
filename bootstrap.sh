#!/bin/bash
set -e

echo "spawnpoint bootstrap — setting up your machine..."

# 1. Xcode Command Line Tools (required for brew)
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Xcode tools installation started. Re-run this script after it completes."
  exit 0
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  fi
fi

# 3. Node.js
if ! command -v node &>/dev/null; then
  echo "Installing Node.js..."
  brew install node
fi

# 4. Claude Code
if ! command -v claude &>/dev/null; then
  echo "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
fi

# 5. Sprites CLI
if ! command -v sprite &>/dev/null; then
  echo "Installing Sprites CLI..."
  curl https://sprites.dev/install.sh | bash
fi

echo ""
echo "Bootstrap complete. Run the following to get started:"
echo ""
echo "  sprite login"
echo "  claude"
echo ""
