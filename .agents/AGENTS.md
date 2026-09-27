# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Workshop materials for "Claude Code for All" at RSU (Wisawakorn Report / วิศวกรรีพอร์ต). The main deliverable is a single-page Thai food menu site at `thai-food/index.html`.

## Commands

There is no build tool, package manager, linter, or test framework in this repo. It is a plain static HTML/CSS/JS site.

- Preview: open `thai-food/index.html` directly in a browser, or serve the folder with any static file server (e.g. `npx serve thai-food`).
- No install, build, lint, or test commands exist — verify changes by opening the page in a browser and exercising the UI manually (see `task.md` for the acceptance checklist).

## Architecture

### `thai-food/index.html` — the app

Single self-contained file: inline `<style>` (responsive layout, light/dark theme via `prefers-color-scheme`, reduced-motion handling) followed by an inline `<script>` with everything else. No modules, no framework, no build-time dependencies — the one runtime dependency is `@supabase/supabase-js`, lazy-loaded from a CDN on first form submit (see Member signup below).

- **`REGIONS`** — the 4 fixed region keys (`north`, `isan`, `central`, `south`) mapped to Thai labels.
- **`MENUS`** — array of 20 dish objects, 5 per region. Each has `id` (unique key), `th`/`en` names, `region`, `spice` (0–3), colors (`soup`/`top`) used to generate placeholder art, an optional `photo` (path under `thai-food/images/`), `ingredients`, and `desc`. Add a new dish by adding an object here — `MENU_BY_ID` is derived automatically.
- **Dish art** — `dishSvg`/`dishArt` render a generated inline SVG from a dish's colors; dishes with a `photo` field use the PNG instead. Photos live in `thai-food/images/`.
- **Favorites** — persisted to `localStorage` under key `aroi-thai:favorites`. All reads/writes are wrapped in try/catch (`loadFavorites`/`saveFavorites`) so the page keeps working when storage is blocked (e.g. private browsing) — this fallback path is implemented but not yet manually tested (see `task.md`).
- **Filtering/search** — `applyFilter`/`matchesSearch`/`syncFavoritesUi` drive the region filter buttons, the favorites filter, and the visible-count display.
- **Random pick** — `randomPick` picks across all 20 menus regardless of the active filter, and avoids repeating the immediately previous result.
- **Detail modal** — `openDetail`/`closeDetail` show a per-dish ingredient modal; supports keyboard access and backdrop-click dismissal, and restores focus to the triggering element on close.
- **Member signup** — footer form (name + email, no login) inserts into the `members` table on Supabase project "thaifood" (ref `fdfqxluchdzxnsbiodqe`). RLS grants `anon` insert-only, so the publishable key embedded in the page cannot read the table back. Duplicate emails are rejected by a unique constraint and surfaced as a friendly message.

### Supporting docs

- **`CONTEXT.md`** — the domain glossary for this project: canonical Thai terms (เมนู, ภาค, เมนูโปรด, สุ่มเมนูวันนี้) with definitions and explicit synonyms to avoid. Kept up to date via the `domain-modeling` skill; check it before introducing new domain terminology in code or comments.
- **`task.md`** — the living feature/acceptance checklist for the site, cross-referenced to `CONTEXT.md`. `[x]` means implemented and manually browser-tested; `[ ]` means not done or not yet verified. Update this file when completing or adding checklist items.

### Skills (`.agents/skills/` and `.claude/skills/`)

Real skill files live under `.agents/skills/{domain-modeling,grilling,grill-with-docs}/`. The `.claude/skills/*` entries are junctions pointing at those real directories (not symlinks — see repo convention). `.gitignore` excludes the `.claude/skills/*` junction paths since the underlying files are tracked via `.agents/skills/`.

### `.claude/settings.json`

Configures `Stop` and `PermissionRequest` hooks that run `.claude/hooks/done.ps1` (PowerShell) to play a notification sound — Windows/PowerShell-specific, not portable.

### `.playwright-mcp/`

Gitignored scratch output (screenshots, console logs, page snapshots) from Playwright MCP browser-testing sessions against the site. Not part of the deliverable.
