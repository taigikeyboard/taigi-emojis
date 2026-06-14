// Loads + searches the bundled emoji document. Foundation-only so it runs under
// `swift test` on macOS; glyph rendering (UIKit/CoreText) is injected by the host app.

import Foundation

public enum TaigiEmojiError: Error {
    case resourceMissing
}

public enum TaigiEmojiStore {
    /// Decode the emoji.json bundled with this package.
    public static func load() throws -> TaigiEmojiDocument {
        guard let url = Bundle.module.url(forResource: "emoji", withExtension: "json") else {
            throw TaigiEmojiError.resourceMissing
        }
        return try JSONDecoder().decode(TaigiEmojiDocument.self, from: Data(contentsOf: url))
    }

    /// Decode an emoji document from raw JSON (e.g. a custom bundle or remote payload).
    public static func decode(from data: Data) throws -> TaigiEmojiDocument {
        try JSONDecoder().decode(TaigiEmojiDocument.self, from: data)
    }

    /// Emoji whose merged keyword list contains `query` (case-insensitive substring).
    public static func search(_ query: String, in document: TaigiEmojiDocument) -> [TaigiEmoji] {
        let needle = query.lowercased()
        guard !needle.isEmpty else { return [] }
        return document.categories
            .flatMap(\.emoji)
            .filter { emoji in emoji.keywords.contains { $0.contains(needle) } }
    }

    /// Drop emoji the host OS font cannot render. The caller supplies the check because
    /// CoreText/UIKit live in the app, not this package. Test the WHOLE `base` string,
    /// not per-scalar — an unsupported ZWJ sequence can falsely pass a per-codepoint check.
    public static func filteringUnrenderable(
        _ document: TaigiEmojiDocument,
        isRenderable: (String) -> Bool
    ) -> TaigiEmojiDocument {
        let categories = document.categories
            .map { category in
                TaigiEmojiCategory(
                    id: category.id,
                    title: category.title,
                    order: category.order,
                    emoji: category.emoji.filter { isRenderable($0.base) }
                )
            }
            .filter { !$0.emoji.isEmpty }
        return TaigiEmojiDocument(meta: document.meta, categories: categories)
    }
}
