# CLAUDE.md

Guidelines for Claude Code in this repo (Python emoji-data pipeline for the Taigi keyboard).

Cross-project process rules (workflow, planning, review, naming, docs, Python) auto-load from
`~/.claude/rules/` (user-global, from the `configurations` dotfiles repo). Project rules live in
`.claude/rules/`; personal defaults in `~/.claude/CLAUDE.md`.

## Project Overview

**taigi-emojis** — the single emoji source of truth for the Taigi keyboard (iOS + Android).
Replaces iOS's unmaintained `ISEmojiView` and Android's inline `root.txt`. A Python generator
merges pinned Unicode + CLDR data with a hand overlay of 台語/華語 search keywords and emits one
`dist/emoji.json` both platforms consume (via git submodule).

## Structure

- `src/overrides.tsv` — the only hand-edited file (add/curate emoji + Taigi keywords)
- `scripts/generate.py` — generator (stdlib-only); `tests/` — golden specs + drift guard
- `data/` — pinned upstream snapshots (+ `SOURCES.md`)
- `dist/emoji.json` — generated artifact both platforms read (committed)
- `platforms/{apple,android}` — shared Swift/Kotlin `TaigiEmojiStore` modules
- `Package.swift` — iOS SPM manifest (repo root, conventional)

## Core Principles

1. **One source, both platforms** — emoji authored once here; no platform-side hardcoded lists.
2. **emoji-test.txt is membership authority** — never hand-code base lists. Grouping edge cases
   get a `MIXED_TONE_PATTERNS` entry + a golden test.
3. **Taigi keywords = authoritative-source-only** — never invent TL/POJ. Verify against sibling
   `taigikeyboard/knowledge/taigi-phonetics-reference.md` + `taigi-converter`; use 漢字 when unsure.
4. **Deterministic build** — `dist/emoji.json` byte-stable; drift-guard test fails on stale output.
   Always `make build` after editing data/generator.
5. **Release scope / version-pin bumps = user-gated** — never raise `MAX_EMOJI_VERSION`, tag, or
   declare "ready to release" without the user's explicit word.

## Mandatory Rules

| Before… | Read |
|---|---|
| editing `src/overrides.tsv` or `data/` | `.claude/rules/emoji-data-authoring.md` |
| editing `scripts/generate.py` or tests | `.claude/rules/generator.md` |
| changing the json schema / platform consumption | `.claude/rules/output-contract.md` (always-on) |

## Build & Test

| Task | Command |
|---|---|
| Regenerate `dist/emoji.json` | `make build` |
| Run tests | `make test` |
| Lint + format check | `make lint` |
| Re-pull upstream (version bump only) | `make fetch` |

## App integration (follow-on in sibling `taigikeyboard`, not here)

Shared modules expose `TaigiEmojiStore` (`load` + `search` + `filteringUnrenderable`) over
`dist/emoji.json`. API + setup: `platforms/README.md`. Schema: `.claude/rules/output-contract.md`.

- **iOS**: SPM dep on `TaigiEmojis`; native SwiftUI view replaces `ISEmojiView`.
- **Android**: Gradle module; `TaigiEmojiStore.load(context)` replaces `EmojiLayoutData` (root.txt).
- **Both**: pass the platform glyph check to `filteringUnrenderable` — test the whole grapheme
  cluster (iOS CoreText, Android `PaintCompat.hasGlyph`), not per-scalar.

## Communication

- Reply in 台灣華語; docs + code comments in English (CJK OK for verbatim quotes + 台語/漢字/TL/POJ terms).
- Concise, bullet-point, key points only.
