//
//  TagListUpdater.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
//  Updates the tag list table view using a diffable data source and
//  notifies the delegate about changes in tag count.
//

import CoreData
import UIKit

/// Observes Core Data tag list changes and applies snapshots to the diffable data source.
final class TagListUpdater: NSObject {

	// MARK: - Dependencies

	/// Fetched results controller used to observe Tag entities.
	private let fetchedResultsController: NSFetchedResultsController<Tag>

	/// The diffable data source to which snapshots will be applied.
	private weak var dataSource: UITableViewDiffableDataSource<TagListViewSection, NSManagedObjectID>?

	/// Table view used for displaying tags and showing empty-state background.
	private weak var tableView: UITableView?

	/// Notifies the view controller about changes in the number of visible tags.
	weak var delegate: TagListUpdaterDelegate?

	// MARK: - Initialization

	/// Initializes the updater with the Core Data context, diffable data source, and table view.
	/// - Parameters:
	///   - context: The NSManagedObjectContext for fetching Tag entities.
	///   - dataSource: The diffable data source that will receive snapshot updates.
	///   - tableView: The UITableView for displaying tags and empty-state messages.
	init(
		context: NSManagedObjectContext,
		dataSource: UITableViewDiffableDataSource<TagListViewSection, NSManagedObjectID>,
		tableView: UITableView
	) {
		self.fetchedResultsController = Self.makeFetchedResultsController(context: context)
		self.dataSource = dataSource
		self.tableView = tableView
		super.init()

		fetchedResultsController.delegate = self
		performFetch()
	}

	// MARK: - Fetching

	/// Performs the initial fetch of tags to populate the data source.
	private func performFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch {
			Log.error("TagListUpdater initial fetch failed: \(error)", logger: LoggerStore.coreData)
		}
	}

	/// Returns true if the fetched tag list is empty.
	func isTagListEmpty() -> Bool {
		return (fetchedResultsController.fetchedObjects?.isEmpty ?? true)
	}

	/// Creates a fetched results controller for monitoring tag changes.
	private static func makeFetchedResultsController(
		context: NSManagedObjectContext
	) -> NSFetchedResultsController<Tag> {
		let request: NSFetchRequest<Tag> = Tag.fetchRequest()
		let sort = NSSortDescriptor(
			key: #keyPath(Tag.name),
			ascending: true,
			selector: #selector(NSString.localizedStandardCompare(_:))
		)
		request.sortDescriptors = [sort]

		return NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
	}
}

// MARK: - NSFetchedResultsControllerDelegate

extension TagListUpdater: NSFetchedResultsControllerDelegate {

	/// Called when the fetched results controller detects content changes.
	/// Applies the provided snapshot and updates the table view's background.
	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChangeContentWith snapshotRef: NSDiffableDataSourceSnapshotReference
	) {
		guard let dataSource = dataSource else {
			Log.error("TagListUpdater: dataSource is nil", logger: LoggerStore.coreData)
			return
		}

		// Cast the generic snapshot reference to our typed snapshot.
		let snapshot = snapshotRef as TagListSnapshot

		// Apply the snapshot to update the table view contents.
		dataSource.apply(snapshot, animatingDifferences: true)

		/// Passes the updated tag count to the delegate after applying the snapshot.
		Task {
			await delegate?.tagListDidUpdate(itemCount: snapshot.numberOfItems)
		}
	}
}
