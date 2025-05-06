//
//  ItemsViewController.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 14.03.2025.
//
// A view controller that displays and manages a list of saved items with Core Data and pagination support.
//

import UIKit
import CoreData

/// Displays a list of saved items and manages their loading, sorting, and navigation.
final class ItemsViewController: UITableViewController {

	// MARK: - Properties

	/// Provides Core Data contexts (view and background) for the controller.
	private let persistentProvider: PersistentContainerProviding

	/// View context used for UI updates and fetch requests.
	private lazy var context: NSManagedObjectContext = persistentProvider.viewContext

	/// Background context used for network operations and inserts.
	private lazy var backgroundContext: NSManagedObjectContext = persistentProvider.backgroundContext

	/// Manages network requests and pagination logic.
	private let networkManager: NetworkManagerProtocol

	/// Provides access to user preferences like sorting and username.
	private let userPreferenceProvider: UserPreferenceProviding

	/// Configures the table view's data source and handles updates from the fetched results controller.
	private var tableConfigurator: ItemsTableConfigurator!

	/// Handles loading and saving of paginated items.
	private lazy var itemLoader = ItemLoader(
		backgroundContext: backgroundContext,
		viewContext: context,
		networkManager: networkManager
	)

	/// Fetched results controller for managing and monitoring the list of saved items.
	var fetchedResultsController: NSFetchedResultsController<Item>!

	/// Coordinates the loading of items and manages paging and loading indicator updates.
	private var loaderController: ItemsLoaderController!

	/// Coordinates navigation and setup between ItemsViewController and DetailsViewController.
	private lazy var coordinator = ItemsCoordinator(viewController: self)

	/// Current sorting type for item list.
	private var currentSorting: ItemSortingType = .dateAdded

	// MARK: - Initializers

	/// Initializes the view controller with injected dependencies.
	init(
		persistentProvider: PersistentContainerProviding = PersistentContainerProvider.shared,
		networkManager: NetworkManagerProtocol = NetworkManager(),
		userPreferenceProvider: UserPreferenceProviding = UserPreferenceProvider()
	) {
		self.persistentProvider = persistentProvider
		self.networkManager = networkManager
		self.userPreferenceProvider = userPreferenceProvider
		super.init(style: .plain)
	}

	required init?(coder: NSCoder) {
		self.persistentProvider = PersistentContainerProvider.shared
		self.networkManager = NetworkManager()
		self.userPreferenceProvider = UserPreferenceProvider()
		super.init(coder: coder)
	}

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		configureSortingPreference()
		configureView()
		setupTable()
		performFetch()
		setupLoaderController()
		loaderController.loadAllPages()
	}

	// MARK: - Setup

	/// Configures the current sorting preference based on saved user defaults.
	private func configureSortingPreference() {
		if let rawValue = userPreferenceProvider.load(forKey: Constants.UserDefaultsKeys.itemSortingType),
		   let sortingType = ItemSortingType(rawValue: rawValue) {
			currentSorting = sortingType
		}
	}

	/// Configures the overall view appearance and data source.
	private func configureView() {
		ItemsUIConfigurator.configure(self)
	}

	/// Creates the fetched results controller and table configurator, and connects them via delegate.
	private func setupTable() {
		fetchedResultsController = ItemFRCBuilder.make(
			sorting: currentSorting,
			context: context
		)

		tableConfigurator = ItemsTableConfigurator(
			tableView: tableView,
			context: context,
			fetchedResultsController: fetchedResultsController,
			sortingButtonUpdater: self
		)

		fetchedResultsController.delegate = tableConfigurator.snapshotUpdater
	}

	/// Sets up the items loader controller and starts loading data.
	private func setupLoaderController() {
		loaderController = ItemsLoaderController(
			itemLoader: itemLoader,
			networkManager: networkManager,
		)

		loaderController.delegate = self

		loaderController.onInitialLoadCompleted = { [weak self] in
			self?.performFetch()
		}
	}

	// MARK: - Data Fetching

	/// Performs the initial fetch using the fetched results controller.
	private func performFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch {
			Log.error("Error performing fetch: \(error.localizedDescription)", logger: LoggerStore.items)
		}

		Task {
			await MainActor.run {
				NoDataViewManager.updateIfNeeded(
					tableView: tableView,
					objectsCount: fetchedResultsController.fetchedObjects?.count,
					message: Constants.Messages.ItemsScreen.noData
				)
			}
		}
	}

	// MARK: - IBActions

	/// Changes the sorting type and reloads the fetched results controller.
	@IBAction func changeSorting(_ sender: UIBarButtonItem) {
		if currentSorting == .dateAdded {
			currentSorting = .timeToRead
			userPreferenceProvider.save(ItemSortingType.timeToRead.rawValue, forKey: Constants.UserDefaultsKeys.itemSortingType)
		} else {
			currentSorting = .dateAdded
			userPreferenceProvider.save(ItemSortingType.dateAdded.rawValue, forKey: Constants.UserDefaultsKeys.itemSortingType)
		}

		// Recreate FRC and tableConfigurator together
		setupTable()

		// Reload data from Core Data
		performFetch()
	}

	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let detailsVC = segue.destination as? DetailsViewController,
			  let indexPath = tableView.indexPathForSelectedRow else { return }

		coordinator.prepareDetailsViewController(detailsVC, for: indexPath)
	}

	// MARK: - Refresh Control

	/// Reloads all items by resetting pagination and starting a full data load.
	@objc func refreshData() {
		loaderController.loadAllPages()
	}
}

// MARK: - DetailsViewControllerDelegate

extension ItemsViewController: DetailsViewControllerDelegate {
	func didMakeItemNonDownloadable(at indexPath: IndexPath) {
		ItemRepository.deleteItem(from: fetchedResultsController, at: indexPath, in: context)

		Task {
			await MainActor.run {
				NoDataViewManager.updateIfNeeded(
					tableView: tableView,
					objectsCount: fetchedResultsController.fetchedObjects?.count,
					message: Constants.Messages.ItemsScreen.zeroInbox
				)
			}
		}
	}
}

// MARK: - ItemsLoaderControllerDelegate

extension ItemsViewController: ItemsDownloadingDelegate {
	func didStartItemListDownloading() {
		// Show initial loading: refresh control visible, both buttons disabled
		LoadingIndicator.updateLoadingState(.initialLoading, in: self)
	}

	func didStartPagingDownloading() {
		// Show paging state: refresh control hidden, left button enabled (sorting), right disabled (settings)
		LoadingIndicator.updateLoadingState(.pagingLoading, in: self)
	}

	func didFinishItemListDownloading() {
		// End loading: hide refresh control, enable both buttons
		LoadingIndicator.updateLoadingState(.idle, in: self)
	}

	func didFinishItemListDownloadingWithEmptyResult() {
		// Update UI to reflect no data
		Task {
			await MainActor.run {
				NoDataViewManager.updateIfNeeded(
					tableView: tableView,
					objectsCount: fetchedResultsController.fetchedObjects?.count,
					message: Constants.Messages.ItemsScreen.zeroInbox
				)
			}
		}

		// Also end loading state
		LoadingIndicator.updateLoadingState(.idle, in: self)
	}

	func didFailItemListDownloading(with error: Error) {
		// Ensure UI returns to idle state
		LoadingIndicator.updateLoadingState(.idle, in: self)

		AlertHelper.showAlertWithOkButton(
			on: self,
			title: Constants.Messages.ItemsScreen.downloadingFailedTitle,
			message: error.localizedDescription
		)
	}
}

// MARK: - SortingButtonUpdating

extension ItemsViewController: SortingButtonUpdating {
	/// Enables the sorting button if at least one section contains more than one item.
	func updateSortingButtonState() {
		guard let sections = fetchedResultsController.sections else {
			navigationItem.leftBarButtonItem?.isEnabled = false
			return
		}

		let shouldEnableSorting = sections.contains { $0.numberOfObjects > 1 }
		navigationItem.leftBarButtonItem?.isEnabled = shouldEnableSorting
	}
}
