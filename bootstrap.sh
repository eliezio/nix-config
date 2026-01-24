#!/usr/bin/env bash
set -euo pipefail

USER_NAME=$(whoami)
SYSTEM_ARCH=$(uname -m)-linux

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

# 2. Install Nix (Single-user)
if ! command -v nix &> /dev/null; then
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
else
    echo "✅ Nix already installed."
fi

# 3. Setup Flake support
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# 4. Prepare Home Manager directory
#mkdir -p ~/.config/home-manager
#cp flake.nix home.nix ~/.config/home-manager/

# 5. Inject User/System Info
sed -i "s/REPLACE_USER/$USER_NAME/g" ~/.config/home-manager/flake.nix
sed -i "s/REPLACE_USER/$USER_NAME/g" ~/.config/home-manager/home.nix
sed -i "s/REPLACE_ARCH/$SYSTEM_ARCH/g" ~/.config/home-manager/flake.nix

# 6. Apply configuration
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager"#ubuntu@aarch64-linux"

# 7. Change Shell to System Zsh
if [[ "$SHELL" != *"/zsh" ]]; then
    echo "🔧 Setting system Zsh as the default shell..."
    sudo chsh -s $(which zsh) "$USER_NAME"
fi

echo "✨ All done! Restart your terminal to enter your new Zsh environment."
