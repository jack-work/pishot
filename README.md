# pishot

Minimal browser DevTools and desktop screenshot tools, designed as a [pi](https://github.com/badlogic/pi-mono) skill. Uses simple CLI scripts invoked via bash rather than MCP servers -- see [What if you don't need MCP at all?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) for the rationale.

**This is tailored to my personal Linux/Wayland/Hyprland setup.** It uses `grim`/`slurp` for desktop screenshots, `hyprctl`/`swaymsg` for window and monitor queries, and Firefox for browser tools via CDP. It may work on your system if you have a similar setup, but no guarantees.

## Prerequisites

- Linux with Wayland compositor (Hyprland or Sway)
- `grim` and `slurp` for desktop screenshots
- `jq` for monitor/window queries
- Firefox
- Node.js

## Install

```bash
git clone https://github.com/gluck/pishot.git
cd pishot
make install
```

This runs `npm install` for dependencies and symlinks all `pishot-*` scripts into `~/.local/bin/` (which should be on your PATH on most Linux distros).

To install as a pi skill:

```bash
pi install /path/to/pishot
```

Or add the directory to your `~/.pi/agent/settings.json`:

```json
{
  "packages": ["/path/to/pishot"]
}
```

## Uninstall

```bash
make uninstall
```

## Tools

### Desktop Screenshot

```bash
pishot-desktop.sh                  # All monitors stitched together
pishot-desktop.sh --focused        # Monitor containing the focused window
pishot-desktop.sh --output DP-2    # Specific monitor by name
pishot-desktop.sh --active         # Active window only
pishot-desktop.sh --region         # Select a region with mouse
pishot-desktop.sh --list           # List available monitors
```

### Browser Tools

Start Firefox with remote debugging, then interact with it:

```bash
pishot-start.js                    # Fresh profile
pishot-start.js --profile          # Copy your Firefox profile (cookies, logins)

pishot-nav.js https://example.com         # Navigate current tab
pishot-nav.js https://example.com --new   # Open in new tab

pishot-eval.js 'document.title'           # Execute JS in active tab

pishot-screenshot.js                      # Screenshot browser viewport

pishot-pick.js "Click the button"         # Interactive DOM element picker
```

## Usage with pi

Invoke the skill with `/skill:pishot` or tell the agent to read the SKILL.md. The agent calls the scripts via bash and uses the built-in `read` tool to view screenshot images.

## License

MIT
