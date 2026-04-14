./bootstrap.sh

zsh -l

nix shell nixpkgs#{ssh-to-age,age,sops,yq-go} --command zsh

SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

mkdir -p ${SOPS_AGE_KEY_FILE%/*}

read -s "?Enter passphrase: " SSH_TO_AGE_PASSPHRASE; export SSH_TO_AGE_PASSPHRASE

ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o $SOPS_AGE_KEY_FILE

chmod 600 $SOPS_AGE_KEY_FILE

yq ".keys[0] = \"$(age-keygen -y $SOPS_AGE_KEY_FILE)\"" -i .sops.yaml

yq "del(.sops) | .\"github-token\" = \"$GITHUB_TOKEN\"" -i user.yaml

sops encrypt --in-place user.yaml
