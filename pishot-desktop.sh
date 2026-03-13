#!/usr/bin/env bash
set -euo pipefail

timestamp=$(date +%Y-%m-%dT%H-%M-%S)
filepath="/tmp/pishot-desktop-${timestamp}.png"

show_help() {
  echo "Usage: pishot-desktop.sh [--region|--active|--output <name>|--list|--focused]"
  echo ""
  echo "  (no args)        All monitors stitched together"
  echo "  --output <name>  Specific monitor (e.g. DP-2, DP-3)"
  echo "  --focused        Monitor containing the focused window"
  echo "  --active         Active window only"
  echo "  --region         Select a region with mouse"
  echo "  --list           List available monitors"
}

case "${1:-}" in
  --list)
    if command -v hyprctl &>/dev/null; then
      hyprctl monitors -j | jq -r '.[] | "\(.name): \(.width)x\(.height) at \(.x),\(.y) - \(.description)"'
    elif command -v swaymsg &>/dev/null; then
      swaymsg -t get_outputs | jq -r '.[] | "\(.name): \(.rect.width)x\(.rect.height) at \(.rect.x),\(.rect.y) - \(.make) \(.model)"'
    else
      echo "Error: requires swaymsg or hyprctl" >&2
      exit 1
    fi
    exit 0
    ;;
  --output)
    if [ -z "${2:-}" ]; then
      echo "Error: --output requires a monitor name (use --list to see them)" >&2
      exit 1
    fi
    grim -o "$2" "$filepath"
    ;;
  --focused)
    if command -v hyprctl &>/dev/null; then
      monitor=$(hyprctl activeworkspace -j | jq -r '.monitor')
      grim -o "$monitor" "$filepath"
    elif command -v swaymsg &>/dev/null; then
      monitor=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
      grim -o "$monitor" "$filepath"
    else
      echo "Error: --focused requires swaymsg or hyprctl" >&2
      exit 1
    fi
    ;;
  --active)
    if command -v hyprctl &>/dev/null; then
      geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
      grim -g "$geometry" "$filepath"
    elif command -v swaymsg &>/dev/null; then
      geometry=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
      grim -g "$geometry" "$filepath"
    else
      echo "Error: --active requires swaymsg or hyprctl" >&2
      exit 1
    fi
    ;;
  --region)
    region=$(slurp)
    grim -g "$region" "$filepath"
    ;;
  --help|-h)
    show_help
    exit 0
    ;;
  "")
    grim "$filepath"
    ;;
  *)
    echo "Unknown option: $1" >&2
    show_help >&2
    exit 1
    ;;
esac

echo "$filepath"
