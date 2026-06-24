#!/usr/bin/env bash
# Production build -> ./public  (run this before deploying)
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
toolbox run --container nexa hugo --source "$DIR" --gc --minify --cleanDestinationDir
echo "Built to $DIR/public"
