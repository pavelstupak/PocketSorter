//
//  TagFormatter.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Converts a set of tag names into a formatted, comma-separated string.
//

struct TagFormatter {
	/// Converts a Set of tag names into a comma-separated string
	static func joinedTagNames(from tagNames: Set<String>) -> String {
		tagNames.sorted().joined(separator: ",")
	}
}
