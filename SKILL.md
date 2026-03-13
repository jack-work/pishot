---
name: pishot
description: Browser DevTools and desktop screenshot tools. Use when the user needs to interact with a browser, take screenshots, navigate pages, execute JavaScript in a page, or capture the desktop.
---

# Browser & Desktop Tools

Minimal CDP tools for browser interaction and desktop screenshots on Linux/Wayland.

## Desktop Screenshot

```bash
pishot-desktop.sh                  # Full screen
pishot-desktop.sh --region         # Select a region interactively
pishot-desktop.sh --active         # Active window only
```

Captures the screen via `grim`/`slurp` (Wayland). Returns a temp file path. Use `read` to view the image.

## Start Browser

```bash
pishot-start.js                    # Fresh profile
pishot-start.js --profile          # Copy user's Firefox profile (cookies, logins)
```

Starts Firefox on `:9222` with remote debugging enabled.

## Navigate

```bash
pishot-nav.js https://example.com         # Navigate current tab
pishot-nav.js https://example.com --new   # Open in new tab
```

## Evaluate JavaScript

```bash
pishot-eval.js 'document.title'
pishot-eval.js 'document.querySelectorAll("a").length'
```

Execute JavaScript in the active tab's page context (async supported).

## Browser Screenshot

```bash
pishot-screenshot.js
```

Screenshot the current browser viewport. Returns a temp file path. Use `read` to view the image.

## Pick Elements

```bash
pishot-pick.js "Click the submit button"
```

Interactive element picker. Click to select, Ctrl+Click for multi-select, Enter to finish, ESC to cancel. Returns DOM info for selected elements.

## All scripts are globally available when the skill directory is on PATH.
