//
//  FetchedResultsSnapshotUpdater.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 28.04.2025.
//
//  Updates the diffable data source and section headers based on NSFetchedResultsController content changes.
//

import UIKit
import CoreData

/// Updates the table view diffable data source and section headers when NSFetchedResultsController content changes.
final class FetchedResultsSnapshotUpdater: NSObject, NSFetchedResultsControllerDelegate {

	// MARK: - Properties

	private let dataSource: ItemsDiffableDataSource
	private let tableView: UITableView
	private let fetchedResultsController: NSFetchedResultsController<Item>
	private weak var sortingButtonUpdater: SortingButtonUpdating?

	// MARK: - Initialization

	/// Creates an updater that listens to FRC changes and rebuilds the snapshot.
	init(
		dataSource: ItemsDiffableDataSource,
		tableView: UITableView,
		fetchedResultsController: NSFetchedResultsController<Item>,
		sortingButtonUpdater: SortingButtonUpdating? = nil
	) {
		self.dataSource = dataSource
		self.tableView = tableView
		self.fetchedResultsController = fetchedResultsController
		self.sortingButtonUpdater = sortingButtonUpdater
	}

	// MARK: - NSFetchedResultsControllerDelegate

	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChangeContentWith snapshotReference: NSDiffableDataSourceSnapshotReference
	) {
		// Use FRC section info to ensure snapshot section order matches FRC
		let sections = fetchedResultsController.sections ?? []

		// Create a new diffable snapshot
		var tmpSnapshot = NSDiffableDataSourceSnapshot<SectionType, ItemIdentifierType>()

		for sectionInfo in sections {
			// Convert section name (String) into SectionType enum
			guard let section = SectionType(rawValue: sectionInfo.name) else { continue }

			// Get all items in the current section
			let items = sectionInfo.objects as? [Item] ?? []

			// Register section in snapshot before adding its items
			tmpSnapshot.appendSections([section])

			// Create identifiers for items including their updated timestamp
			let identifiers = items.map {
				ItemIdentifierType(objectID: $0.objectID, timeUpdated: $0.timeUpdated)
			}

			// Add item identifiers to the section
			tmpSnapshot.appendItems(identifiers, toSection: section)

			// Update section metadata (e.g. for header titles)
			dataSource.sectionMetadata[section] = identifiers.count
		}

		let newSnapshot = tmpSnapshot

		// Apply snapshot and update headers on the main thread
		DispatchQueue.main.async {
			self.dataSource.apply(newSnapshot, animatingDifferences: true)
			SectionHeaderUpdater.updateHeaders(in: self.tableView, dataSource: self.tableView.dataSource)
			self.sortingButtonUpdater?.updateSortingButtonState()
		}
	}
}
