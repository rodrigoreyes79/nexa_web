#!/usr/bin/env bash
# Local preview with live reload. Runs Hugo inside the 'nexa' toolbox.
# Open http://localhost:1313  (and http://localhost:1313/es/ for Spanish)
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec toolbox run --container nexa hugo server --source "$DIR" --bind 127.0.0.1 --port 1313 --buildDrafts
