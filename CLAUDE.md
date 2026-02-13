# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Vai Aletto — a PWA soundboard app. Vanilla HTML/CSS/JS, no build step, no dependencies.

## Running Locally

```bash
python3 -m http.server 8000
# or
npx http-server
```

No build, lint, or test commands exist.

## Deployment

Automatic to GitHub Pages via `.github/workflows/deploy.yml` on push to `main`.

## Architecture

Everything lives in a single `index.html` — markup, styles, and all JS. No framework, no bundling.

**Sound system:** `sounds.json` defines sound metadata (name, file path, emoji). On load, JS fetches this JSON and generates a button grid dynamically. Audio files are cached in a `audioCache` object for instant replay.

**Service Worker (`sw.js`):** Cache version `vaialetto-v2`. Network-first for `/sounds/` directory, cache-first for everything else. Precaches `index.html`, `manifest.json`, and `sounds.json`.

**PWA:** `manifest.json` enables install-to-homescreen. Includes iOS audio unlock workaround (plays silent audio on first touch to enable subsequent playback).

## Adding Sounds

Use the `record-sound.sh` script (requires `sox`, `jq`). It records audio, trims silence, converts to MP3, and can auto-append to `sounds.json`. Or manually: drop an MP3 in `sounds/` and add an entry to `sounds.json`.
