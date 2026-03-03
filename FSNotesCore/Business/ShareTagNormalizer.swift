//
//  ShareTagNormalizer.swift
//  FSNotesCore
//
//  Normalizes user-entered tag input for the Share Extension "Choose Project & Tags" feature.
//

import Foundation

/// Normalizes user-entered tag input into a list of clean tag strings.
/// Used by the Share Extension when saving notes with tags.
public enum ShareTagNormalizer {

    /// Parses tag input (e.g. "work, urgent", "#tag1 tag2", "  a  ,  b  ") into normalized tags.
    /// - Parameter input: Raw string from the user (may include #, commas, spaces).
    /// - Returns: Array of trimmed tag strings without # prefix. Empty array if input is empty/whitespace.
    public static func normalizedTags(from input: String) -> [String] {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let parts = trimmed.split { $0.isWhitespace || $0 == "," }
        var tags: [String] = []
        for raw in parts {
            let cleaned = raw.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            if cleaned.isEmpty { continue }
            tags.append(String(cleaned))
        }
        return tags
    }

    /// Formats normalized tags for appending to note content (e.g. ["work", "urgent"] → "#work #urgent").
    public static func formatTagsForContent(_ tags: [String]) -> String {
        guard !tags.isEmpty else { return "" }
        return tags.map { "#\($0)" }.joined(separator: " ")
    }
}
