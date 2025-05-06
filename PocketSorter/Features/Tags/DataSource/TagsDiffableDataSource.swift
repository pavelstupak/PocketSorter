//
//  TagsDiffableDataSource.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Diffable data source for displaying and managing tag rows in a table view.
//

import UIKit
import CoreData

/// Delegate protocol for handling tag deletion events from the diffable data source.
protocol TagsDiffableDataSourceDelegate: AnyObject {
	/// Called when the user swipes to delete a tag at the specified index path.
	func didDeleteTag(at indexPath: IndexPath)
}

/// Diffable data source for managing and displaying tags in a UITableView.
/// Used in TagsTableViewController to render tags and handle swipe-to-delete actions.
final class TagsDiffableDataSource: UITableViewDiffableDataSource<TagListViewSection, NSManagedObjectID> {

	// MARK: - Dependencies

	/// The reuse identifier used for dequeuing tag cells.
	private let cellIdentifier: String

	/// Core Data context used to fetch `Tag` objects by ID.
	private let context: NSManagedObjectContext

	/// Delegate responsible for handling deletions triggered by swipe gestures.
	weak var deletionDelegate: TagsDiffableDataSourceDelegate?

	// MARK: - Initialization

	/// Creates a diffable data source that manages tag rows in the given table view.
	/// - Parameters:
	///   - tableView: The table view that displays the tags.
	///   - cellIdentifier: The reuse identifier for the tag cells.
	///   - context: The Core Data context used to fetch `Tag` objects.
	init(tableView: UITableView, cellIdentifier: String, context: NSManagedObjectContext) {
		self.cellIdentifier = cellIdentifier
		self.context = context

		super.init(tableView: tableView) { tableView, indexPath, managedObjectID in
			// Dequeue reusable cell
			let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

			// Fetch the Tag object for this row
			if let tag = try? context.existingObject(with: managedObjectID) as? Tag {
				// Configure the cell with tag data
				TagCellConfigurator.configure(cell, with: tag)
			}

			return cell
		}
	}

	// MARK: - Editing (Swipe-to-delete)

	/// Allows all rows to be editable, enabling swipe-to-delete.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	/// Handles the swipe-to-delete action for a tag row.
	/// Forwards the deletion event to the delegate.
	override func tableView(
		_ tableView: UITableView,
		commit editingStyle: UITableViewCell.EditingStyle,
		forRowAt indexPath: IndexPath
	) {
		if editingStyle == .delete {
			deletionDelegate?.didDeleteTag(at: indexPath)
		}
	}
}
