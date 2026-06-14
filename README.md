# taigi-emojis

Single emoji source of truth for the [Taigi keyboard](https://github.com/taigikeyboard)
(iOS + Android). A Python generator merges pinned Unicode + CLDR data with a hand overlay
of Taiwanese (台語) / 華語 search keywords and emits one `dist/emoji.json` both apps consume.

## Add or curate emoji

Edit **`src/overrides.tsv`** (the only hand-edited file), then rebuild:

```bash
make build   # regenerate dist/emoji.json
make test    # golden specs + drift guard
```

`overrides.tsv` columns (tab-separated):

```
emoji  action  category  order  taigi_keywords  zh_Hant_keywords  en_keywords  name  notes
```

- `patch` — add keywords to an existing emoji (e.g. add 台語 search terms).
- `add` — add a brand-new emoji not in upstream.
- `exclude` — drop an upstream emoji.

Keywords are `|`-separated. For Taigi terms, use 漢字 and only verified 羅馬字 — never invent
romanization (see `.claude/rules/emoji-data-authoring.md`).

## Update to a new Unicode version

```bash
make fetch   # re-pull pinned upstream (bump versions in Makefile + generate.py first)
make build
```

See `data/SOURCES.md` for origins, versions, and the version-pin rationale.

## Output

`dist/emoji.json` — categories → emoji (base, codepoints, name, skin-tone variations,
merged + per-locale keywords). Schema in `.claude/rules/output-contract.md`. Consumed via
git submodule; each app glyph-filters unsupported emoji at load.
