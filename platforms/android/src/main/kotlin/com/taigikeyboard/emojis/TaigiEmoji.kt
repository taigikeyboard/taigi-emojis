// region Shared-Core Candidate
// Pure value types, Kotlin stdlib only. Mirror of dist/emoji.json.
// Schema contract: .claude/rules/output-contract.md.
// endregion

package com.taigikeyboard.emojis

data class TaigiEmojiDocument(
    val meta: Meta,
    val categories: List<TaigiEmojiCategory>,
) {
    data class Meta(
        val emojiVersion: String,
        val cldrVersion: String,
        val count: Int,
    )
}

data class TaigiEmojiCategory(
    val id: String,
    val title: String,
    val order: Int,
    val emoji: List<TaigiEmoji>,
)

data class TaigiEmoji(
    // The emoji string to insert (fully-qualified). Never carries a skin-tone modifier —
    // tone forms live in [variations].
    val base: String,
    val cp: List<Int>,
    val name: String,
    val subgroup: String,
    val version: String,
    val variations: List<String>,
    // Flat search index — lowercased, deduped, order-stable (en + zh-Hant + Taigi).
    val keywords: List<String>,
    val keywordsByLocale: KeywordsByLocale,
) {
    data class KeywordsByLocale(
        val en: List<String>,
        val zhHant: List<String>,
        val taigi: List<String>,
    )
}
