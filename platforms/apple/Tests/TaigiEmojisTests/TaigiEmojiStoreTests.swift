import XCTest

@testable import TaigiEmojis

final class TaigiEmojiStoreTests: XCTestCase {
    func testLoadsBundledDocument() throws {
        let document = try TaigiEmojiStore.loadBundled()
        XCTAssertGreaterThan(document.meta.count, 1800)
        XCTAssertEqual(document.categories.count, 9)
        XCTAssertEqual(document.categories.first?.id, "smileys_emotion")
        XCTAssertEqual(document.categories.first?.emoji.first?.base, "😀")
    }

    func testSearchFindsByEnglishKeyword() throws {
        let document = try TaigiEmojiStore.loadBundled()
        let hits = TaigiEmojiStore.search("grin", in: document)
        XCTAssertTrue(hits.contains { $0.base == "😀" })
    }

    func testSearchFindsByTaigiHanji() throws {
        let document = try TaigiEmojiStore.loadBundled()
        let hits = TaigiEmojiStore.search("笑", in: document)
        XCTAssertTrue(hits.contains { $0.base == "😀" })
    }

    func testFilteringUnrenderableDropsEverythingWhenNothingRenders() throws {
        let document = try TaigiEmojiStore.loadBundled()
        let filtered = TaigiEmojiStore.filteringUnrenderable(document) { _ in false }
        XCTAssertTrue(filtered.categories.isEmpty)
    }
}
