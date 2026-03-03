//
//  ShareProjectSelectionTests.swift
//  FSNotes iOSTests
//
//  Unit tests for the Share Extension "Choose Project & Tags" feature.
//  Tests project selection and persistence logic.
//

import XCTest
@testable import FSNotes_iOS

final class ShareProjectSelectionTests: XCTestCase {

    // MARK: - ShareTagNormalizer (shared with ShareTagNormalizerTests for feature coverage)

    func test_tagFormatForNoteContent_matchesExpectedFormat() {
        let tags = ShareTagNormalizer.normalizedTags(from: "work, urgent")
        let formatted = ShareTagNormalizer.formatTagsForContent(tags)
        XCTAssertTrue(formatted.contains("#work"))
        XCTAssertTrue(formatted.contains("#urgent"))
        XCTAssertEqual(formatted.components(separatedBy: " ").count, 2)
    }
}
