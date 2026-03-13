#!/usr/bin/env bash
set -euo pipefail

timestamp=$(date +%Y-%m-%dT%H-%M-%S)
filepath="/tmp/pishot-desktop-${timestamp}.png"

case "${1:-}" in
  --region)
    region=$(slurp)
    grim -g "$region" "$filepath"
    ;;
  --active)
    # Get the focused window geometry via swaymsg or hyprctl
    if command -v swaymsg &>/dev/null; then
      geometry=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
      grim -g "$geometry" "$filepath"
    elif command -v hyprctl &>/dev/null; then
      geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
      grim -g "$geometry" "$filepath"
    else
      echo "Error: --active requires swaymsg or hyprctl" >&2
      exit 1
    fi
    ;;
  ""|--help)
    if [ "${1:-}" = "--help" ]; then
      echo "Usage: pishot-desktop.sh [--region|--active]"
      echo ""
      echo "  (no args)   Full screen screenshot"
      echo "  --region    Select a region with mouse"
      echo "  --active    Active window only (sway/hyprland)"
      exit 0
    fi
    grim "$filepath"
    ;;
  *)
    echo "Unknown option: $1" >&2
    echo "Usage: pishot-desktop.sh [--region|--active]" >&2
    exit 1
    ;;
esac

echo "$filepath"
