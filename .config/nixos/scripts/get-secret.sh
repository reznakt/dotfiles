SECRETS_DIR="$HOME/.config/nixos/secrets"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <secret-name>" 1>&2
  exit 1
fi

if ! cat "$SECRETS_DIR/$1"; then
    echo "Failed to read secret '$1'" 1>&2
    exit 1
fi