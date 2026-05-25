#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"   # demo/ → http-server/ → ext/ → root

# Search for compiled framehead: demo dir → repo root → ext/http-server/ → common names
if [[ -f "$SCRIPT_DIR/bash-framehead.sh" ]]; then
		FRAMEHEAD="$SCRIPT_DIR/bash-framehead.sh"
elif [[ -f "$ROOT_DIR/bash-framehead.sh" ]]; then
		FRAMEHEAD="$ROOT_DIR/bash-framehead.sh"
elif [[ -f "$ROOT_DIR/compiled.sh" ]]; then
		FRAMEHEAD="$ROOT_DIR/compiled.sh"
elif [[ -f "$SCRIPT_DIR/../bash-framehead.sh" ]]; then
		FRAMEHEAD="$SCRIPT_DIR/../bash-framehead.sh"
else
		echo "Error: no compiled bash-framehead.sh found"
		echo "Searched: $SCRIPT_DIR/  $ROOT_DIR/  $SCRIPT_DIR/../"
		echo "Run: ./main.sh compile bash-framehead.sh"
		exit 1
fi

export BASH_FRAMEHEAD_PATH="$FRAMEHEAD"
export HTTP_EXT_PATH="$SCRIPT_DIR/routes.sh"
export HTTP_DOCROOT="$SCRIPT_DIR/static"

source "$FRAMEHEAD"
source "$SCRIPT_DIR/../http-server.sh"

PORT="${1:-8080}"

echo "=========================================="
echo "  Bash::Framehead HTTP Server Demo"
echo "  http://localhost:$PORT"
echo "=========================================="
echo ""
echo "  Endpoints:"
echo "    /                Home page"
echo "    /hello/[name]    Dynamic routing"
echo "    /form            HTML form demo"
echo "    /sse             Server-Sent Events"
echo "    /upload          File upload demo"
echo "    /about           About page"
echo "    /redirect        Redirect demo"
echo "    /api/counter     Session counter"
echo "    /api/status      JSON status endpoint"
echo ""

http::server::start "$PORT"

echo "Server running. Press Ctrl+C to stop."
wait
