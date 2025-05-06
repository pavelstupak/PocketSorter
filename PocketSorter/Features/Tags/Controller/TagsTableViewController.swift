//
//  TagsTableViewController.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 16.03.2025.
//
//  A view controller that displays the list of tags using a diffable data source.
//  Handles tag creation, deletion, and empty-state display.
//

import UIKit
import CoreData

/// A table view controller that displays a list of tags and allows users to create or delete them.
final class TagsTableViewController: UITableViewController {

	// MARK: - Properties

	/// Provides Core Data contexts for this controller.
	private let persistentProvider: PersistentContainerProviding

	/// View context for Core Data operations.
	lazy var context: NSManagedObjectContext = persistentProvider.viewContext

	/// Diffable data source for the tag list.
	private var dataSource: TagsDiffableDataSource?

	/// Handles observing tag changes and updating the UI.
	private var tagListUpdater: TagListUpdater?

	// MARK: - Initializers

	/// Initializes the view controller with an injected persistent provider.
	/// Can be used for testing or programmatic initialization.
	init(persistentProvider: PersistentContainerProviding = PersistentContainerProvider.shared) {
		self.persistentProvider = persistentProvider
		super.init(style: .plain)
	}

	/// Initializes the view controller from storyboard.
	required init?(coder: NSCoder) {
		self.persistentProvider = PersistentContainerProvider.shared
		super.init(coder: coder)
	}

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		setupDataSource()
		setupUpdater()
		setEmptyStateIfNeeded()
	}

	// MARK: - IBActions

	/// Presents an alert to create a new tag.
	@IBAction func presentTagCreationAlert() {
		TagCreationAlert.present(in: self)
	}

	// MARK: - Private Methods

	/// Initializes and assigns the diffable data source.
	private func setupDataSource() {
		dataSource = TagsDiffableDataSource(
			tableView: tableView,
			cellIdentifier: Constants.CellIdentifier.tag,
			context: context
		)
		dataSource?.deletionDelegate = self
	}

	/// Sets up the tag list updater and assigns delegate.
	private func setupUpdater() {
		guard let dataSource = dataSource else { return }

		tagListUpdater = TagListUpdater(
			context: context,
			dataSource: dataSource,
			tableView: tableView
		)
		tagListUpdater?.delegate = self
	}

	/// Updates the empty state message if no tags are present.
	private func setEmptyStateIfNeeded() {
		let isEmpty = tagListUpdater?.isTagListEmpty() == true
		Task {
			await MainActor.run {
				NoDataViewManager.updateIfNeeded(
					tableView: tableView,
					objectsCount: isEmpty ? 0 : 1,
					message: Constants.Messages.TagsScreen.noTags
				)
			}
		}
	}
}

// MARK: - TagsDiffableDataSourceDelegate

extension TagsTableViewController: TagsDiffableDataSourceDelegate {

	/// Handles deletion of a tag at the specified index path.
	func didDeleteTag(at indexPath: IndexPath) {
		if let objectID = dataSource?.itemIdentifier(for: indexPath) {
			TagRepository.deleteTag(objectID: objectID, in: context)
		}
	}
}

// MARK: - TagListUpdaterDelegate

extension TagsTableViewController: TagListUpdaterDelegate {

	/// Updates the empty state message based on tag count.
	func tagListDidUpdate(itemCount: Int) async {
		await MainActor.run {
			NoDataViewManager.updateIfNeeded(
				tableView: tableView,
				objectsCount: itemCount,
				message: Constants.Messages.TagsScreen.noTags
			)
		}
	}
}
