#!/usr/bin/env bash
set -euo pipefail

USER_NAME=$(whoami)
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
FLAKE_DIR="$SCRIPT_DIR"
CERTS_SOURCE_DIR="${CERTS_SOURCE_DIR:-$SCRIPT_DIR/certs}"
CERTS_TARGET_DIR="/usr/local/share/ca-certificates"

ensure_nix_feature() {
  local nix_conf="$HOME/.config/nix/nix.conf"
  mkdir -p "$(dirname "$nix_conf")"
  touch "$nix_conf"

  if ! grep -Eq '^experimental-features\s*=.*\bnix-command\b.*\bflakes\b' "$nix_conf"; then
    echo "experimental-features = nix-command flakes" >> "$nix_conf"
  fi
}

install_system_certs() {
  local changed=0

  shopt -s nullglob
  local certs=("$CERTS_SOURCE_DIR"/*.crt "$CERTS_SOURCE_DIR"/*.pem)
  shopt -u nullglob

  if [ "${#certs[@]}" -eq 0 ]; then
    echo "ℹ️  No cert files found in $CERTS_SOURCE_DIR; skipping system CA install."
    return 0
  fi

  sudo mkdir -p "$CERTS_TARGET_DIR"

  for cert in "${certs[@]}"; do
    local base target
    base="$(basename "$cert")"
    target="$CERTS_TARGET_DIR/${base%.*}.crt"

    if sudo test -f "$target" && sudo cmp -s "$cert" "$target"; then
      continue
    fi

    sudo install -m 0644 "$cert" "$target"
    changed=1
  done

  if [ "$changed" -eq 1 ]; then
    echo "🔐 Updating system CA certificates..."
    sudo update-ca-certificates
  else
    echo "✅ System CA certificates already up to date."
  fi
}

echo "🚀 Starting WSL Bootstrap for $USER_NAME..."

# 1. Install System Requirements
echo "📦 Installing required packages via apt..."
sudo apt-get update
sudo apt-get install --yes --no-install-recommends \
    ca-certificates \
    curl \
    git \
    sudo \
    xz-utils \
    zsh

# 2. Install corporate/system certificates
install_system_certs

# 3. Install Nix (Single-user)
if ! command -v nix &> /dev/null; then
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
else
    echo "✅ Nix already installed."
fi

# 4. Setup Flake support
ensure_nix_feature

# 5. Apply configuration
if command -v home-manager &> /dev/null; then
    home-manager switch --flake "$FLAKE_DIR#$USER_NAME"
else
    nix run github:nix-community/home-manager -- switch --flake "$FLAKE_DIR#$USER_NAME"
fi

# 6. Change Shell to System Zsh
CURRENT_LOGIN_SHELL=$(getent passwd "$USER_NAME" | cut -d: -f7)
ZSH_PATH=$(command -v zsh)
if [ "$CURRENT_LOGIN_SHELL" != "$ZSH_PATH" ]; then
    echo "🔧 Setting system Zsh as the default shell..."
    sudo chsh -s "$ZSH_PATH" "$USER_NAME"
fi

echo "✨ All done! Restart your terminal to enter your new Zsh environment."
