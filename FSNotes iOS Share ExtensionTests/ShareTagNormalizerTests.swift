//
//  ShareTagNormalizerTests.swift
//  FSNotes iOS Share ExtensionTests
//
//  Unit tests for the "Choose Project & Tags When Sharing to FSNotes" feature.
//  Tests tag normalization logic used when saving shared content with tags.
//

import XCTest

final class ShareTagNormalizerTests: XCTestCase {

    // MARK: - normalizedTags(from:)

    func test_normalizedTags_emptyString_returnsEmptyArray() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: ""), [])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "   "), [])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "\n\t"), [])
    }

    func test_normalizedTags_singleTag_withoutHash() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work"), ["work"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "  work  "), ["work"])
    }

    func test_normalizedTags_singleTag_withHash() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "#work"), ["work"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "#urgent"), ["urgent"])
    }

    func test_normalizedTags_singleTag_withHashAndWhitespace() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "  #work  "), ["work"])
    }

    func test_normalizedTags_multipleTags_commaSeparated() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work, urgent"), ["work", "urgent"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work, urgent, personal"), ["work", "urgent", "personal"])
    }

    func test_normalizedTags_multipleTags_spaceSeparated() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work urgent"), ["work", "urgent"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work  urgent   personal"), ["work", "urgent", "personal"])
    }

    func test_normalizedTags_multipleTags_mixedSeparators() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work, urgent personal"), ["work", "urgent", "personal"])
    }

    func test_normalizedTags_multipleTags_withHashes() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "#work #urgent"), ["work", "urgent"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "#work, #urgent"), ["work", "urgent"])
    }

    func test_normalizedTags_acceptanceCriteria_workUrgent() {
        // From prompt: "e.g. work, urgent"
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work, urgent"), ["work", "urgent"])
    }

    func test_normalizedTags_acceptanceCriteria_workUrgentWithSpaces() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work , urgent "), ["work", "urgent"])
    }

    func test_normalizedTags_acceptanceCriteria_removesHashPrefix() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "#work #urgent"), ["work", "urgent"])
    }

    func test_normalizedTags_acceptanceCriteria_skipsEmptyParts() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work,,urgent"), ["work", "urgent"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work,  , urgent"), ["work", "urgent"])
    }

    func test_normalizedTags_acceptanceCriteria_handlesOnlyHashes() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "###"), [])
    }

    // MARK: - tagsLine(for:)

    func test_tagsLine_emptyArray_returnsEmptyString() {
        XCTAssertEqual(ShareTagNormalizer.tagsLine(for: []), "")
    }

    func test_tagsLine_singleTag() {
        XCTAssertEqual(ShareTagNormalizer.tagsLine(for: ["work"]), "#work")
    }

    func test_tagsLine_multipleTags() {
        XCTAssertEqual(ShareTagNormalizer.tagsLine(for: ["work", "urgent"]), "#work #urgent")
    }

    func test_tagsLine_matchesAppendFormat() {
        // Tags appended to note content use format: "#tag1 #tag2"
        let tags = ShareTagNormalizer.normalizedTags(from: "work, urgent")
        let line = ShareTagNormalizer.tagsLine(for: tags)
        XCTAssertEqual(line, "#work #urgent")
    }

    func test_tagsLine_roundtrip() {
        let input = "work, urgent, personal"
        let tags = ShareTagNormalizer.normalizedTags(from: input)
        let line = ShareTagNormalizer.tagsLine(for: tags)
        XCTAssertEqual(line, "#work #urgent #personal")
    }
}
