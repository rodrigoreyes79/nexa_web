#!/usr/bin/env bash
# Build locally and push ./public to the Hetzner VPS over rsync+ssh.
#
# Usage:  ./deploy/deploy.sh [user@host] [remote_path]
# Example: ./deploy/deploy.sh root@203.0.113.10 /var/www/nexa
#
# Prereqs on the server: the remote_path exists and is served by Caddy/Nginx,
# and your SSH key can log in.
set -euo pipefail

HOST="${1:-${NEXA_SSH:-}}"
REMOTE_PATH="${2:-/var/www/nexa}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "$HOST" ]]; then
  echo "Usage: $0 user@host [remote_path]   (or set NEXA_SSH env var)" >&2
  exit 1
fi

echo "==> Building production site..."
"$DIR/build.sh"

echo "==> Syncing to $HOST:$REMOTE_PATH ..."
rsync -avz --delete \
  --exclude='.well-known' \
  "$DIR/public/" "$HOST:$REMOTE_PATH/"

echo "==> Done. Live at https://nexa.uno"
