//
//  ShareTagNormalizer.swift
//  FSNotes
//
//  Extracts tag normalization logic for the Share Extension "Choose Project & Tags" feature.
//  Enables unit testing of tag parsing without UI dependencies.
//

import Foundation

/// Normalizes user-entered tag strings into an array of clean tag identifiers.
/// Supports formats: "work, urgent", "work urgent", "#tag", "tag1, tag2, tag3"
public enum ShareTagNormalizer {

    /// Parses a tag input string and returns an array of normalized tag names.
    /// - Parameter input: Raw input (e.g. "work, urgent", "#work #urgent", "  tag  ")
    /// - Returns: Array of tag strings without leading "#" or extra whitespace
    public static func normalizedTags(from input: String) -> [String] {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let parts = trimmed.split { $0.isWhitespace || $0 == "," }
        var tags: [String] = []
        for raw in parts {
            let cleaned = raw.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            if cleaned.isEmpty { continue }
            tags.append(cleaned)
        }
        return tags
    }

    /// Formats an array of tags for appending to note content (FSNotes format: "#tag1 #tag2").
    public static func tagsLine(for tags: [String]) -> String {
        tags.map { "#\($0)" }.joined(separator: " ")
    }
}
