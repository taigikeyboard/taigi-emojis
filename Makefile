# Emoji data pipeline. `make build` regenerates dist/emoji.json from data/ + overrides.
# `make fetch` re-pulls pinned upstream sources (run only when bumping the version pin).

UNICODE_EMOJI_VERSION := 16.0
CLDR_TAG := release-46
UNICODE_BASE := https://unicode.org/Public/emoji/$(UNICODE_EMOJI_VERSION)
CLDR_BASE := https://raw.githubusercontent.com/unicode-org/cldr/$(CLDR_TAG)/common

.PHONY: build test lint fetch clean

build:
	python3 scripts/generate.py

test:
	python3 -m pytest -q

lint:
	ruff check scripts tests
	ruff format --check scripts tests

fetch:
	curl -fsS -o data/emoji-test.txt          "$(UNICODE_BASE)/emoji-test.txt"
	curl -fsS -o data/cldr-zh_Hant.xml         "$(CLDR_BASE)/annotations/zh_Hant.xml"
	curl -fsS -o data/cldr-zh_Hant-derived.xml "$(CLDR_BASE)/annotationsDerived/zh_Hant.xml"
	curl -fsS -o data/cldr-en.xml              "$(CLDR_BASE)/annotations/en.xml"
	curl -fsS -o data/cldr-en-derived.xml      "$(CLDR_BASE)/annotationsDerived/en.xml"
	@echo "fetched Unicode $(UNICODE_EMOJI_VERSION) + CLDR $(CLDR_TAG) — review git diff, then make build"

clean:
	rm -f dist/emoji.json
