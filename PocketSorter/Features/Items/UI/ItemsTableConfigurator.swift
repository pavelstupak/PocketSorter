//
//  ItemsTableConfigurator.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 28.04.2025.
//
//  Provides a reusable configuration for the items table view,
//  including setting up the diffable data source and handling Core Data updates.
//  Used to keep ItemsViewController lighter and more focused on user interactions.
//

import UIKit
import CoreData

/// Configures the diffable data source and snapshot updater for the items table view.
final class ItemsTableConfigurator {

	// MARK: - Properties

	/// The diffable data source used to manage and display the items in the table view.
	let dataSource: ItemsDiffableDataSource

	/// The snapshot updater responsible for applying Core Data changes to the data source.
	let snapshotUpdater: FetchedResultsSnapshotUpdater

	// MARK: - Initialization

	/// Initializes the table configurator by setting up the data source and snapshot updater.
	///
	/// - Parameters:
	///   - tableView: The table view to configure with the diffable data source.
	///   - context: The Core Data context used by the data source to fetch items.
	///   - fetchedResultsController: The FRC used to track Core Data updates.
	///   - sortingButtonUpdater: An optional object that updates the sorting button state when data changes.
	init(
		tableView: UITableView,
		context: NSManagedObjectContext,
		fetchedResultsController: NSFetchedResultsController<Item>,
		sortingButtonUpdater: SortingButtonUpdating? = nil
	) {
		self.dataSource = ItemsDiffableDataSource.make(for: tableView, context: context)
		self.snapshotUpdater = FetchedResultsSnapshotUpdater(
			dataSource: dataSource,
			tableView: tableView,
			fetchedResultsController: fetchedResultsController,
			sortingButtonUpdater: sortingButtonUpdater
		)
	}
}
