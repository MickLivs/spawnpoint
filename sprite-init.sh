#!/bin/bash
# Run this inside a Sprite to set up the full dev environment
set -e

SPRITE_NAME="${1:-my-dev}"

echo "Initializing Sprite: $SPRITE_NAME"

# Create the Sprite if it doesn't exist
sprite create "$SPRITE_NAME" 2>/dev/null || echo "Sprite already exists, continuing..."

# Install dev tooling inside the Sprite
sprite exec -s "$SPRITE_NAME" -- bash -c "
  set -e

  # Node.js via nvm
  if ! command -v node &>/dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR=\"\$HOME/.nvm\"
    source \"\$NVM_DIR/nvm.sh\"
    nvm install --lts
  fi

  # Vercel CLI
  npm install -g vercel 2>/dev/null || true

  # GitHub CLI
  if ! command -v gh &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo 'deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update && sudo apt install gh -y
  fi

  echo 'Sprite ready.'
"

# Expose port 3000 for live preview
sprite url -s "$SPRITE_NAME" update --auth public

echo ""
echo "Sprite '$SPRITE_NAME' is ready."
echo "Live preview: https://$SPRITE_NAME.sprites.app"
echo ""
echo "Connect with: sprite console -s $SPRITE_NAME"
