// NOTE: Not shared-core — Android platform loader (uses android Context + org.json).
// The value types in TaigiEmoji.kt are the shared-core-clean half.

package com.siansiansu.taigikeyboard.emojis

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.InputStream

object TaigiEmojiStore {
    private const val ASSET_PATH = "emoji.json"

    /** Load the emoji document bundled in this library's assets. */
    fun load(context: Context): TaigiEmojiDocument =
        context.assets.open(ASSET_PATH).use(::decode)

    fun decode(input: InputStream): TaigiEmojiDocument {
        val root = JSONObject(input.readBytes().decodeToString())
        val metaObject = root.getJSONObject("meta")
        val meta = TaigiEmojiDocument.Meta(
            emojiVersion = metaObject.getString("emojiVersion"),
            cldrVersion = metaObject.getString("cldrVersion"),
            count = metaObject.getInt("count"),
        )
        val categories = root.getJSONArray("categories").objects().map { categoryObject ->
            TaigiEmojiCategory(
                id = categoryObject.getString("id"),
                title = categoryObject.getString("title"),
                order = categoryObject.getInt("order"),
                emoji = categoryObject.getJSONArray("emoji").objects().map(::decodeEmoji),
            )
        }
        return TaigiEmojiDocument(meta, categories)
    }

    /** Emoji whose merged keyword list contains [query] (case-insensitive substring). */
    fun search(query: String, document: TaigiEmojiDocument): List<TaigiEmoji> {
        val needle = query.lowercase()
        if (needle.isEmpty()) return emptyList()
        return document.categories
            .asSequence()
            .flatMap { it.emoji.asSequence() }
            .filter { emoji -> emoji.keywords.any { it.contains(needle) } }
            .toList()
    }

    /**
     * Drop emoji the host OS font cannot render. The caller supplies the check (e.g.
     * `PaintCompat.hasGlyph`). Test the WHOLE [TaigiEmoji.base] string, not per-scalar —
     * an unsupported ZWJ sequence can falsely pass a per-codepoint check.
     */
    fun filteringUnrenderable(
        document: TaigiEmojiDocument,
        isRenderable: (String) -> Boolean,
    ): TaigiEmojiDocument {
        val categories = document.categories
            .map { category -> category.copy(emoji = category.emoji.filter { isRenderable(it.base) }) }
            .filter { it.emoji.isNotEmpty() }
        return document.copy(categories = categories)
    }

    private fun decodeEmoji(json: JSONObject): TaigiEmoji {
        val locale = json.getJSONObject("keywordsByLocale")
        return TaigiEmoji(
            base = json.getString("base"),
            cp = json.getJSONArray("cp").ints(),
            name = json.getString("name"),
            subgroup = json.getString("subgroup"),
            version = json.getString("version"),
            variations = json.getJSONArray("variations").strings(),
            keywords = json.getJSONArray("keywords").strings(),
            keywordsByLocale = TaigiEmoji.KeywordsByLocale(
                en = locale.getJSONArray("en").strings(),
                zhHant = locale.getJSONArray("zh_Hant").strings(),
                taigi = locale.getJSONArray("taigi").strings(),
            ),
        )
    }

    private fun JSONArray.objects(): List<JSONObject> = (0 until length()).map { getJSONObject(it) }

    private fun JSONArray.strings(): List<String> = (0 until length()).map { getString(it) }

    private fun JSONArray.ints(): List<Int> = (0 until length()).map { getInt(it) }
}
