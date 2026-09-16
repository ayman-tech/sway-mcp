#!/usr/bin/env bash

set -euo pipefail

SERVER_NAME="sway"

command -v openclaw >/dev/null 2>&1 || {
  printf 'Error: OpenClaw is not installed or is not on PATH.\n' >&2
  exit 1
}

if ! openclaw mcp show "$SERVER_NAME" >/dev/null 2>&1; then
  printf 'Sway is not registered with OpenClaw. Nothing to remove.\n'
  exit 0
fi

if [[ "${1:-}" != "--yes" ]]; then
  printf 'Remove the Sway MCP registration and its stored API key from OpenClaw? [y/N] '
  IFS= read -r SWAY_UNINSTALL_CONFIRM
  case "$SWAY_UNINSTALL_CONFIRM" in
    y|Y|yes|YES|Yes) ;;
    *)
      printf 'Uninstall cancelled.\n'
      exit 0
      ;;
  esac
fi

openclaw mcp unset "$SERVER_NAME"
printf 'Sway was removed from OpenClaw. Your Sway account and tasks were not changed.\n'
