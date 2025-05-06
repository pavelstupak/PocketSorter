//
//  NoDataViewManager.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
// Utility for managing placeholder messages in table views
//

import UIKit

/// Utility for managing placeholder messages in table views
@MainActor
struct NoDataViewManager {

	/// Shows a centered message as a background view of the table view
	static func showMessage(_ message: String, on tableView: UITableView) {
		tableView.backgroundView = makeMessageLabel(with: message)
	}

	/// Removes any background message from the table view
	static func removeMessage(from tableView: UITableView) {
		tableView.backgroundView = nil
	}

	/// Updates the table view background depending on the number of fetched objects
	/// - Parameters:
	///   - tableView: The table view to update
	///   - objectsCount: The number of objects fetched (nil or 0 means no data)
	///   - message: The message to display if no data is available
	static func updateIfNeeded(
		tableView: UITableView,
		objectsCount: Int?,
		message: String
	) {
		if let count = objectsCount, count > 0 {
			removeMessage(from: tableView)
		} else {
			showMessage(message, on: tableView)
		}
	}

	/// Creates a configured UILabel for the no data message
	private static func makeMessageLabel(with text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		label.textAlignment = .center
		label.font = .preferredFont(forTextStyle: .body)
		label.sizeToFit()
		return label
	}
}
