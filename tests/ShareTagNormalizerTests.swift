//
//  ShareTagNormalizerTests.swift
//  FSNotes iOSTests
//
//  Unit tests for the Share Extension "Choose Project & Tags" feature.
//  Tests tag normalization and formatting logic.
//

import XCTest
@testable import FSNotes_iOS

final class ShareTagNormalizerTests: XCTestCase {

    // MARK: - normalizedTags(from:)

    func test_normalizedTags_emptyString_returnsEmptyArray() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: ""), [])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "   "), [])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "\n\t"), [])
    }

    func test_normalizedTags_singleTag() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "work"), ["work"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "#work"), ["work"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "  work  "), ["work"])
    }

    func test_normalizedTags_multipleTags_spaceSeparated() {
        XCTAssertEqual(
            ShareTagNormalizer.normalizedTags(from: "work urgent"),
            ["work", "urgent"]
        )
        XCTAssertEqual(
            ShareTagNormalizer.normalizedTags(from: "#work #urgent"),
            ["work", "urgent"]
        )
    }

    func test_normalizedTags_multipleTags_commaSeparated() {
        XCTAssertEqual(
            ShareTagNormalizer.normalizedTags(from: "work, urgent"),
            ["work", "urgent"]
        )
        XCTAssertEqual(
            ShareTagNormalizer.normalizedTags(from: "work,urgent"),
            ["work", "urgent"]
        )
    }

    func test_normalizedTags_mixedSeparators() {
        XCTAssertEqual(
            ShareTagNormalizer.normalizedTags(from: "work, urgent important"),
            ["work", "urgent", "important"]
        )
    }

    func test_normalizedTags_stripsHashPrefix() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "#tag1"), ["tag1"])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "##double"), ["double"])
    }

    func test_normalizedTags_ignoresEmptyParts() {
        XCTAssertEqual(
            ShareTagNormalizer.normalizedTags(from: "work,  , urgent"),
            ["work", "urgent"]
        )
        XCTAssertEqual(
            ShareTagNormalizer.normalizedTags(from: "  ,  work  ,  "),
            ["work"]
        )
    }

    func test_normalizedTags_handlesOnlyHashes() {
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "#"), [])
        XCTAssertEqual(ShareTagNormalizer.normalizedTags(from: "## , ##"), [])
    }

    // MARK: - formatTagsForContent(_:)

    func test_formatTagsForContent_emptyArray_returnsEmptyString() {
        XCTAssertEqual(ShareTagNormalizer.formatTagsForContent([]), "")
    }

    func test_formatTagsForContent_singleTag() {
        XCTAssertEqual(ShareTagNormalizer.formatTagsForContent(["work"]), "#work")
    }

    func test_formatTagsForContent_multipleTags() {
        XCTAssertEqual(
            ShareTagNormalizer.formatTagsForContent(["work", "urgent"]),
            "#work #urgent"
        )
    }

    func test_formatTagsForContent_roundTrip() {
        let input = "work, urgent, important"
        let tags = ShareTagNormalizer.normalizedTags(from: input)
        let formatted = ShareTagNormalizer.formatTagsForContent(tags)
        XCTAssertEqual(formatted, "#work #urgent #important")
    }
}
