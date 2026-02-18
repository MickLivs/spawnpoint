#!/bin/bash
# Provisions a Sprite with the tools needed to go from idea to deployed app.
#
# Pre-installed by every Sprite (no action needed):
#   node v22+, npm, gh, bun, deno, go, python3, ruby, rust, claude
#
# This script only adds what's missing: the Vercel CLI.
set -e

SPRITE_NAME="${1:-my-dev}"

echo "Initializing Sprite: $SPRITE_NAME"

# Create the Sprite if it doesn't exist.
# NOTE: `sprite create` requires browser-based Fly.io auth (sprite login).
# It does not accept manual API tokens.
sprite create "$SPRITE_NAME" 2>/dev/null || echo "Sprite already exists, continuing..."

# Install Vercel CLI via bun.
# IMPORTANT: do NOT use `npm install -g` — it corrupts the /etc overlay
# filesystem inside the Sprite, breaking node on the next exec.
# bun add -g is safe and takes ~3s.
sprite exec -s "$SPRITE_NAME" bash -c "
  set -e
  if ! command -v vercel &>/dev/null; then
    echo 'Installing Vercel CLI...'
    bun add -g vercel
    # bun installs to /.sprite/languages/bun/bin which is not on default PATH.
    # Symlink into ~/.local/bin (which is on PATH) so vercel works everywhere.
    ln -sf \$(bun pm bin -g)/vercel /home/sprite/.local/bin/vercel
    echo 'Vercel CLI installed.'
  else
    echo 'Vercel CLI already installed:' \$(vercel --version)
  fi
  echo 'Sprite ready.'
"

# Make the Sprite URL publicly accessible.
# Port routing: the public URL proxies to whatever service has http_port set.
# Register a service via the Sprites API to activate routing to port 3000:
#   PUT https://api.sprites.dev/v1/sprites/{name}/services/{service-name}
#   {"cmd":"...", "args":[...], "http_port":3000}
# For local access during dev, use: sprite proxy -s NAME 3000
sprite url -s "$SPRITE_NAME" update --auth public

SPRITE_URL=$(sprite url -s "$SPRITE_NAME" | grep '^URL:' | awk '{print $2}')

echo ""
echo "Sprite '$SPRITE_NAME' is ready."
echo ""
echo "  Shell:      sprite console -s \"$SPRITE_NAME\""
echo "  Public URL: $SPRITE_URL"
echo "  Local dev:  sprite proxy -s \"$SPRITE_NAME\" 3000"
