#!/usr/bin/env bash

set -euo pipefail

SERVER_NAME="sway"
SWAY_INSTALL_API_URL="${SWAY_API_URL:-https://api.sway.aymanai.com}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v uv >/dev/null 2>&1 || fail "uv is required: https://docs.astral.sh/uv/getting-started/installation/"
command -v openclaw >/dev/null 2>&1 || fail "OpenClaw is required before installing the Sway MCP server."
command -v curl >/dev/null 2>&1 || fail "curl is required to validate the Sway API key."

[[ -f "$SCRIPT_DIR/pyproject.toml" ]] || fail "pyproject.toml was not found beside this installer."
[[ -f "$SCRIPT_DIR/sway_mcp/server.py" ]] || fail "The sway_mcp package was not found beside this installer."

printf 'Paste the Sway API key generated in Settings: '
IFS= read -r -s SWAY_INSTALL_API_KEY
printf '\n'
trap 'unset SWAY_INSTALL_API_KEY' EXIT

[[ "$SWAY_INSTALL_API_KEY" == sway_* ]] || fail "The API key must start with sway_."

printf 'Validating the API key...\n'
curl --fail --silent --show-error --max-time 15 \
  --output /dev/null \
  --header "Authorization: Bearer $SWAY_INSTALL_API_KEY" \
  "$SWAY_INSTALL_API_URL/auth/me" \
  || fail "Sway rejected the key or the API could not be reached at $SWAY_INSTALL_API_URL."

if openclaw mcp show "$SERVER_NAME" >/dev/null 2>&1; then
  printf 'An OpenClaw MCP server named "%s" already exists. Replace it? [y/N] ' "$SERVER_NAME"
  IFS= read -r SWAY_INSTALL_REPLACE
  case "$SWAY_INSTALL_REPLACE" in
    y|Y|yes|YES|Yes)
      openclaw mcp unset "$SERVER_NAME"
      ;;
    *)
      fail "Installation cancelled without changing the existing registration."
      ;;
  esac
fi

UV_EXECUTABLE="$(command -v uv)"

openclaw mcp add "$SERVER_NAME" \
  --command "$UV_EXECUTABLE" \
  --arg run \
  --arg --project \
  --arg "$SCRIPT_DIR" \
  --arg sway-mcp \
  --cwd "$SCRIPT_DIR" \
  --env "SWAY_API_URL=$SWAY_INSTALL_API_URL" \
  --env "SWAY_API_KEY=$SWAY_INSTALL_API_KEY"

printf 'Checking the MCP server...\n'
openclaw mcp doctor "$SERVER_NAME" --probe

printf '\nSway was added to OpenClaw successfully.\n'
printf 'Start a new agent session, then ask it to add or list a Sway task.\n'
