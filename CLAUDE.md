# CLAUDE.md

Guidelines for **Claude Code** in this repo. Same two-repo AI environment as the sibling
`taigikeyboard` repo:

- **Cross-project process rules** (workflow, planning, diagnosis, review, naming, docs
  authoring, Python) live in `~/.claude/rules/` — managed by the
  [`configurations`](https://github.com/siansiansu/configurations) dotfiles repo and
  symlinked into `~/.claude/` by that repo's `setup.sh`. They are **user-global** — they
  auto-load in every session on this machine, including this one. **Required external
  dependency**: clone `configurations` + run its `setup.sh` on a fresh machine.
- **Project-specific rules** live in `.claude/rules/` here and auto-load via `paths:` glob
  when Claude reads matching files; `output-contract.md` is always-on.
- **Personal defaults** (theme, response style, Codex usage, Opus tuning) live in
  `~/.claude/CLAUDE.md` (also from `configurations`).

So opening a session at this path gives the **same development experience** as the
`taigikeyboard` repo: identical global workflow/review/planning rules + personal defaults,
plus this repo's own project rules below.

## Project Overview

**taigi-emojis** — the single emoji source of truth for the **Taigi keyboard** (iOS +
Android). Replaces two divergent hand-maintained data paths: iOS's unmaintained
third-party `ISEmojiView` and Android's inline `root.txt`. A Python generator merges
pinned Unicode + CLDR data with a hand overlay of Taiwanese/華語 search keywords and emits
one `dist/emoji.json` both platforms consume (via git submodule).

## Project Structure

```
taigi-emojis/
├── data/             # pinned upstream snapshots (emoji-test.txt + CLDR xml) — make fetch
│   └── SOURCES.md    # origins, versions, licenses, version-pin rationale
├── src/overrides.tsv # THE hand-edited surface — add/curate emoji + Taigi keywords
├── scripts/generate.py
├── dist/emoji.json   # generated artifact both platforms read (committed)
├── tests/            # pytest golden specs + drift guard
├── platforms/        # shared modules — both consume dist/emoji.json (symlinked in)
│   ├── apple/        # Swift package sources (manifest = Package.swift at root)
│   └── android/      # Android library module (com.android.library)
├── Package.swift     # iOS SPM manifest (root, conventional)
├── .claude/
│   ├── rules/        # project rules (auto-load via paths: glob)
│   └── skills/       # fetch-emoji (bump/refresh the emoji version)
├── Makefile          # build / test / lint / fetch
└── pyproject.toml    # uv + ruff + pytest, py3.13+
```

## Core Principles (project-specific)

1. **One source, both platforms** — emoji data is authored once here; iOS and Android
   derive categories, ordering, variations, and search from `dist/emoji.json`. No
   platform-side hardcoded emoji lists. Schema contract in `.claude/rules/output-contract.md`.
2. **emoji-test.txt is the membership authority** — never reintroduce hand-coded base
   lists. Grouping edge cases get a `MIXED_TONE_PATTERNS` entry + a golden test.
3. **Taigi keywords = authoritative-source-only** — never invent TL/POJ. Verify against the
   sibling `taigikeyboard/knowledge/taigi-phonetics-reference.md` + `taigi-converter`; use
   漢字 when unsure. A word's identity is the **(漢字, 羅馬字) pair**. See
   `.claude/rules/emoji-data-authoring.md`.
4. **Deterministic build** — `dist/emoji.json` is byte-stable; the drift-guard test fails
   if committed output is stale. Always `make build` after editing data/generator.
5. **Release scope / timing / version-pin bumps = user-gated** — never raise
   `MAX_EMOJI_VERSION`, tag, or declare "ready to release" without the user's explicit word
   (mirrors `~/.claude/rules/diagnosis-discipline.md` § No unilateral release scope).

## Mandatory Rules

Cross-project process rules auto-load from `~/.claude/rules/` (user-global). Project rules:

| Before… | Read |
|---|---|
| editing `src/overrides.tsv` or `data/` | `.claude/rules/emoji-data-authoring.md` |
| editing `scripts/generate.py` or tests | `.claude/rules/generator.md` |
| changing the json schema or platform consumption | `.claude/rules/output-contract.md` (always-on) |

## Build & Test

Python repo — no Xcode/Gradle. Most changes are admin/data-tier.

| Task | Command |
|---|---|
| Regenerate `dist/emoji.json` | `make build` (`python3 scripts/generate.py`) |
| Run tests | `make test` (`python3 -m pytest -q`) |
| Lint + format check | `make lint` (`ruff check` + `ruff format --check`) |
| Re-pull upstream (version-pin bump only) | `make fetch` |

`uv` is available for isolated runs (`uv run --with pytest python -m pytest`).

## Shared modules + app integration

The shared platform modules live here under `platforms/` and expose `TaigiEmojiStore`
(load + `search` + `filteringUnrenderable(isRenderable:)`) over `dist/emoji.json`. Consumer
setup + API examples: `platforms/README.md`. Schema contract: `.claude/rules/output-contract.md`.

Wiring them into the apps is follow-on work in the sibling `taigikeyboard` repo, not here:

- **iOS**: add this repo as a submodule, depend on the `TaigiEmojis` Swift package, replace
  `ISEmojiView` with a native SwiftUI emoji view fed by `TaigiEmojiStore`. Remove the SPM dep.
- **Android**: include `platforms/android` as a Gradle module; replace
  `EmojiLayoutData.parseRawEmojiSpecsFile` (root.txt) with `TaigiEmojiStore.load(context)`.
- Both: pass the platform glyph check to `filteringUnrenderable` — test the **whole grapheme
  cluster**, not per-scalar (iOS CoreText, Android `PaintCompat.hasGlyph`).

## Communication

- Reply in **Taiwanese Mandarin (台灣華語)**; documentation and code comments stay in
  **English** (CJK allowed for verbatim user quotes + 台語/漢字/TL/POJ/TPS domain terms).
- Concise, bullet-point, key points only.
