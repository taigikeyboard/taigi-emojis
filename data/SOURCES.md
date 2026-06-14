# Upstream Sources

All files in `data/` are pinned upstream snapshots, committed for reproducible builds.
Re-pull with `make fetch` only when bumping the version pin (then `make build` + review diff).

| File | Origin | Version | License | Used for |
|---|---|---|---|---|
| `emoji-test.txt` | https://unicode.org/Public/emoji/16.0/emoji-test.txt | Emoji 16.0 | [Unicode](https://www.unicode.org/copyright.html) | Membership, order, groups/subgroups, names, emoji version, skin-tone variation source |
| `cldr-zh_Hant.xml` | cldr `release-46` `common/annotations/zh_Hant.xml` | CLDR 46 | [Unicode](https://www.unicode.org/copyright.html) | 華語 (zh-Hant) keywords |
| `cldr-zh_Hant-derived.xml` | cldr `release-46` `common/annotationsDerived/zh_Hant.xml` | CLDR 46 | [Unicode](https://www.unicode.org/copyright.html) | 華語 keywords (derived sequences) |
| `cldr-en.xml` | cldr `release-46` `common/annotations/en.xml` | CLDR 46 | [Unicode](https://www.unicode.org/copyright.html) | English keywords |
| `cldr-en-derived.xml` | cldr `release-46` `common/annotationsDerived/en.xml` | CLDR 46 | [Unicode](https://www.unicode.org/copyright.html) | English keywords (derived sequences) |

## Version pin

`MAX_EMOJI_VERSION = "E16.0"` in `scripts/generate.py` is intentional. Unicode 17.0 data
exists upstream; the cap is conservative so the dist never advertises glyphs broadly
unrendered by current OS fonts. Per-OS rendering gaps are handled by each platform's
glyph filter at load — not by shipping per-version files. Bump the pin + `CLDR_TAG` in
the `Makefile` together when raising it.
