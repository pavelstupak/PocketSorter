//
//  ItemCellConfigurator.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
// Configures table view cells to display item title, duration, and metadata.
//

import UIKit

/// Configures a UITableViewCell for a given Item
struct ItemCellConfigurator {
	/// Applies text and metadata to the cell based on the Item's properties
	static func configure(_ cell: UITableViewCell, with item: Item) {
		var content = cell.defaultContentConfiguration()

		content.text = buildPrimaryText(for: item)
		content.secondaryText = buildSecondaryText(for: item)
		content.secondaryTextProperties.color = .gray

		cell.contentConfiguration = content
	}

	/// Builds the primary text based on the item's favorite status, type, and title
	private static func buildPrimaryText(for item: Item) -> String {
		var text = item.isFavorite ? "★ " : ""

		if let durationText = formattedDuration(for: item) {
			text += durationText
		}

		text += item.title ?? ""
		return text
	}

	/// Returns a formatted reading or video duration if available
	private static func formattedDuration(for item: Item) -> String? {
		guard let sectionType = SectionType(rawValue: item.type) else {
			return nil
		}

		switch sectionType {
		case .article where item.timeToRead > 0:
			return "[\(item.timeToRead) min] "
		case .video where item.firstVideoLength > 0:
			return "[\(item.firstVideoLength) min] "
		default:
			return nil
		}
	}

	/// Builds the secondary text showing time difference and URL host
	private static func buildSecondaryText(for item: Item) -> String {
		let timeDifference = DateTimeHelper.getTimeDifference(from: Int(item.timeAdded))
		let host = item.url?.host() ?? ""
		return "\(timeDifference) • \(host)"
	}
}
