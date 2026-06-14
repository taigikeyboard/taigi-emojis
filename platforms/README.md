# Platform Modules

Shared iOS + Android modules wrapping the generated `dist/emoji.json`. Both bundle the same
JSON via a symlink (`Resources/emoji.json` / `assets/emoji.json` → `../../../../../dist/emoji.json`)
— one source, no copy, no drift.

```
platforms/
├── apple/      Swift package sources (root Package.swift)
└── android/    Android library module (com.android.library)
```

## iOS (Swift Package)

The package manifest is `Package.swift` at the repo root. Consume from the app:

- **Local path** (recommended — taigi-emojis is a git submodule of the app): Xcode →
  *Add Package Dependencies…* → *Add Local…* → pick the `taigi-emojis` submodule root.
- **Remote**: `.package(url: "git@github.com:taigikeyboard/taigi-emojis.git", ...)`.

```swift
import TaigiEmojis

let document = try TaigiEmojiStore.loadBundled()
let renderable = TaigiEmojiStore.filteringUnrenderable(document) { isEmojiRenderable($0) }
let hits = TaigiEmojiStore.search("笑", in: renderable)
```

`filteringUnrenderable` takes the app's glyph check (CoreText/UIKit live in the app, not the
package). Check the **whole** base string, not per-scalar.

## Android (Gradle library)

Include the module in the app's `settings.gradle(.kts)`:

```kotlin
include(":taigi-emojis")
project(":taigi-emojis").projectDir = file("path/to/taigi-emojis/platforms/android")
```

```kotlin
import com.taigikeyboard.emojis.TaigiEmojiStore

val document = TaigiEmojiStore.load(context)
val renderable = TaigiEmojiStore.filteringUnrenderable(document) { PaintCompat.hasGlyph(paint, it) }
val hits = TaigiEmojiStore.search("笑", document)
```

org.json (Android platform built-in) is the only parser — no extra runtime dependency.

## Moving the modules later

The modules only read `emoji.json` — zero coupling to the generator. To move the iOS
package into the app, copy `platforms/apple/Sources/TaigiEmojis` + `Package.swift` and fix
the resource path. To split a platform into its own repo, `git subtree split platforms/<p>`.
