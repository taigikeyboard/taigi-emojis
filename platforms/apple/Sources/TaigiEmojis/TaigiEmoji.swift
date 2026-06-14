// Decodable mirror of dist/emoji.json. Schema contract: .claude/rules/output-contract.md.

import Foundation

public struct TaigiEmojiDocument: Codable, Sendable {
    public let meta: Meta
    public let categories: [TaigiEmojiCategory]

    public init(meta: Meta, categories: [TaigiEmojiCategory]) {
        self.meta = meta
        self.categories = categories
    }

    public struct Meta: Codable, Sendable {
        public let emojiVersion: String
        public let cldrVersion: String
        public let count: Int
    }
}

public struct TaigiEmojiCategory: Codable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let order: Int
    public let emoji: [TaigiEmoji]

    public init(id: String, title: String, order: Int, emoji: [TaigiEmoji]) {
        self.id = id
        self.title = title
        self.order = order
        self.emoji = emoji
    }
}

public struct TaigiEmoji: Codable, Sendable, Identifiable {
    /// The emoji string to insert (fully-qualified). Never carries a skin-tone modifier —
    /// tone forms live in `variations`.
    public let base: String
    public let cp: [Int]
    public let name: String
    public let subgroup: String
    public let version: String
    public let variations: [String]
    /// Flat search index — lowercased, deduped, order-stable (en + zh-Hant + Taigi).
    public let keywords: [String]
    public let keywordsByLocale: KeywordsByLocale

    public var id: String { base }

    public struct KeywordsByLocale: Codable, Sendable {
        public let en: [String]
        public let zhHant: [String]
        public let taigi: [String]

        enum CodingKeys: String, CodingKey {
            case en
            case zhHant = "zh_Hant"
            case taigi
        }
    }
}
