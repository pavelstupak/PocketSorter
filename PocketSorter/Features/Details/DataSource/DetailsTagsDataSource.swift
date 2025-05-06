//
//  DetailsTagsDataSource.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Manages the data source and selection logic for the tags table view in DetailsViewController.
//

import UIKit
import CoreData

/// Manages the data source and selection logic for the tags table view in DetailsViewController.
final class DetailsTagsDataSource: NSObject {

	// MARK: - Dependencies

	/// The table view to manage.
	private unowned let tableView: UITableView

	/// Core Data context used for fetching Tag objects.
	private let context: NSManagedObjectContext

	/// Manager tracking which tags are selected.
	private let selectionManager: TagSelectionManager

	/// The diffable data source powering the table view.
	private var diffableDataSource: UITableViewDiffableDataSource<TagListViewSection, NSManagedObjectID>?

	// MARK: - Callback

	/// Callback invoked when the set of selected tag names changes.
	var onSelectionChanged: ((Set<String>) -> Void)?

	// MARK: - Initialization

	/// Initializes the data source with the given table view, Core Data context, and selection manager.
	/// - Parameters:
	///   - tableView: The UITableView to display tags.
	///   - context: NSManagedObjectContext for fetching Tag entities.
	///   - selectionManager: Manager to track tag selection state.
	init(
		tableView: UITableView,
		context: NSManagedObjectContext,
		selectionManager: TagSelectionManager
	) {
		self.tableView = tableView
		self.context = context
		self.selectionManager = selectionManager
		super.init()

		// Set self as the table view delegate to handle row selection.
		tableView.delegate = self
	}

	// MARK: - Public API

	/// Creates and configures the diffable data source for the table view.
	/// - Returns: A configured UITableViewDiffableDataSource instance.
	func makeDataSource() -> UITableViewDiffableDataSource<TagListViewSection, NSManagedObjectID> {
		let dataSource = UITableViewDiffableDataSource<TagListViewSection, NSManagedObjectID>(
			tableView: tableView
		) { [weak self] tableView, indexPath, objectID in
			guard let self = self else {
				return UITableViewCell()
			}

			do {
				// Fetch the Tag object for this row.
				let object = try self.context.existingObject(with: objectID)
				guard let tag = object as? Tag else {
					Log.warning("Object for ID \(objectID) is not a Tag", logger: LoggerStore.coreData)
					return UITableViewCell()
				}
				let name = tag.name

				// Dequeue and configure the cell.
				let cell = tableView.dequeueReusableCell(
					withIdentifier: Constants.CellIdentifier.tagsTableViewCell,
					for: indexPath
				)
				TagCellConfigurator.configure(cell, with: tag)

				// Set the accessory type based on selection state.
				cell.accessoryType = self.selectionManager.isSelected(name) ? .checkmark : .none
				return cell

			} catch {
				Log.error("Error fetching Tag for ID \(objectID): \(error)", logger: LoggerStore.coreData)
				return UITableViewCell()
			}
		}

		// Keep a reference for handling selections.
		self.diffableDataSource = dataSource
		return dataSource
	}

	/// Returns the set of currently selected tag names.
	/// - Returns: A Set of selected tag name strings.
	func selectedTagNames() -> Set<String> {
		selectionManager.selectedNames
	}

	// MARK: - Selection Handling

	/// Handles selection toggling and UI updates for a given index path.
	/// - Parameter indexPath: The IndexPath of the selected row.
	private func handleSelection(at indexPath: IndexPath) {
		guard
			let dataSource = diffableDataSource,
			let objectID = dataSource.itemIdentifier(for: indexPath)
		else {
			Log.warning("No objectID found for row at \(indexPath)", logger: LoggerStore.details)
			return
		}

		do {
			// Fetch the Tag to retrieve its name.
			let object = try context.existingObject(with: objectID)
			guard let tag = object as? Tag else {
				Log.warning("Object for ID \(objectID) is not a Tag", logger: LoggerStore.coreData)
				return
			}
			let name = tag.name

			// Toggle the selection state in the manager.
			selectionManager.toggle(name: name)

			// Update the accessory type on the visible cell only.
			if let cell = tableView.cellForRow(at: indexPath) {
				let isSelected = selectionManager.isSelected(name)
				cell.accessoryType = isSelected ? .checkmark : .none
			}

			// Notify external listener of the updated selection.
			onSelectionChanged?(selectionManager.selectedNames)

		} catch {
			Log.error("Error fetching Tag for ID \(objectID): \(error)", logger: LoggerStore.coreData)
		}
	}
}

// MARK: - UITableViewDelegate

extension DetailsTagsDataSource: UITableViewDelegate {
	/// Called when a row is selected; toggles tag selection.
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		handleSelection(at: indexPath)
	}
}
