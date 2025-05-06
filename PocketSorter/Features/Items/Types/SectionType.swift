//
//  SectionType.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 28.04.2025.
//
//  Defines logical section types used for grouping saved items in the list.
//

/// Represents the types of sections in the saved items list.
enum SectionType: String, CaseIterable {
	case article = "Article"
	case video = "Video"
	case other = "Other"

	/// Returns the header title for the section, including the number of items.
	func headerTitle(count: Int) -> String {
		let itemWord = count == 1 ? "item" : "items"
		switch self {
		case .article:
			return "\(Constants.SectionHeader.articles) (\(count) \(itemWord))"
		case .video:
			return "\(Constants.SectionHeader.videos) (\(count) \(itemWord))"
		case .other:
			return "\(Constants.SectionHeader.other) (\(count) \(itemWord))"
		}
	}
}
