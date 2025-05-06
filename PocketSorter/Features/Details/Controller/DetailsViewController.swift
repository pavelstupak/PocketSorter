//
//  DetailsViewController.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 15.03.2025.
//
// A view controller that displays detailed information about an item, including its tags, image, and available actions.
//

import UIKit
import CoreData

/// Displays detailed information about an item, including its tags, image, and available actions.
final class DetailsViewController: UIViewController {

	// MARK: - IBOutlets

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var excerptLabel: UILabel!
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet weak var archiveButton: UIButton!
	@IBOutlet weak var linkButton: UIButton!
	@IBOutlet private weak var progressView: UIProgressView!

	// MARK: - Public Properties (assigned externally)

	/// Delegate handling item-related callbacks (e.g., marking item non-downloadable).
	weak var sendingRequestsDelegate: DetailsViewControllerDelegate?

	/// The item being displayed in this view controller.
	var currentItem: Item?

	/// IndexPath of the current item for delegate callbacks.
	var currentItemIndexPath: IndexPath?

	// MARK: - Dependencies

	private let persistentProvider: PersistentContainerProviding
	private let networkManager: NetworkManagerProtocol

	private lazy var context: NSManagedObjectContext = persistentProvider.viewContext

	// MARK: - Internal Components

	private var imageDisplayConfigurator: ImageDisplayConfigurator?
	private var itemActions: DetailsItemActions?
	private var tagListUpdater: TagListUpdater?
	private lazy var selectionManager = TagSelectionManager()
	private var tagsDataSource: DetailsTagsDataSource?

	// MARK: - Image state for updating UI
	private var imageState: ImageState = .idle {
		didSet {
			ImageViewStateApplier.apply(imageState, to: imageView, progressView: progressView)
		}
	}

	// MARK: - Loading overlay

	private let activityIndicator = UIActivityIndicatorView(style: .large)
	private let overlayView = UIView()
	lazy var activityOverlay: ActivityOverlay = setupActivityOverlay()

	// MARK: - Initializers

	init(
		persistentProvider: PersistentContainerProviding = PersistentContainerProvider.shared,
		networkManager: NetworkManagerProtocol = NetworkManager()
	) {
		self.persistentProvider = persistentProvider
		self.networkManager = networkManager
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		self.persistentProvider = PersistentContainerProvider.shared
		self.networkManager = NetworkManager()
		super.init(coder: coder)
	}

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		configureUI()
		configureDataSource()
		configureImageDisplay()
		configureItemActions()
	}

	// MARK: - Configuration

	/// Configures static UI elements and labels.
	private func configureUI() {
		guard let item = currentItem else {
			Log.error("Missing currentItem during configureUI", logger: LoggerStore.details)
			return
		}
		DetailsUIConfigurator.configure(self, with: item)
	}

	/// Sets up the table view data source and Core Data updates for tags.
	private func configureDataSource() {
		let dataSource = DetailsTagsDataSource(
			tableView: tableView,
			context: context,
			selectionManager: selectionManager
		)

		dataSource.onSelectionChanged = { [weak self] selected in
			self?.navigationItem.rightBarButtonItem?.isEnabled = !selected.isEmpty
		}

		tagsDataSource = dataSource
		let diffableDataSource = dataSource.makeDataSource()
		tableView.dataSource = diffableDataSource
		tableView.delegate = dataSource

		tagListUpdater = TagListUpdater(
			context: context,
			dataSource: diffableDataSource,
			tableView: tableView
		)

		if tagListUpdater?.isTagListEmpty() == true {
			NoDataViewManager.showMessage(
				Constants.Messages.DetailsScreen.noTags,
				on: tableView
			)
		}
	}

	/// Sets up the configurator responsible for displaying the image and reporting progress.
	private func configureImageDisplay() {
		guard let item = currentItem else {
			Log.error("Missing currentItem during configureImageDisplay", logger: LoggerStore.details)
			return
		}

		let configurator = ImageDisplayConfigurator(currentItem: item, context: context)
		configurator.delegate = self
		configurator.loadImageWithState()
		self.imageDisplayConfigurator = configurator
	}

	/// Sets up the actions handler for saving tags and archiving the item.
	private func configureItemActions() {
		guard let item = currentItem, let indexPath = currentItemIndexPath else {
			Log.error("Missing currentItem or indexPath during configureItemActions", logger: LoggerStore.details)
			return
		}

		let service = PocketActionsService(networkManager: networkManager)
		itemActions = DetailsItemActions(
			itemService: service,
			currentItem: item,
			indexPath: indexPath,
			delegate: self
		)
	}

	/// Creates and configures the loading overlay view.
	private func setupActivityOverlay() -> ActivityOverlay {
		let overlay = ActivityOverlay(
			overlayView: overlayView,
			indicator: activityIndicator,
			containerView: view,
			navigationItem: navigationItem,
			navigationBar: navigationController?.navigationBar
		)
		overlay.setup()
		return overlay
	}

	// MARK: - IBActions

	@IBAction private func openItemLink(_ sender: UIBarButtonItem) {
		guard let url = currentItem?.url, UIApplication.shared.canOpenURL(url) else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

	@IBAction private func archiveItem(_ sender: UIButton) {
		itemActions?.archiveItem()
	}

	@IBAction private func saveTags(_ sender: UIBarButtonItem) {
		let selected = tagsDataSource?.selectedTagNames() ?? []
		itemActions?.saveTags(selectedTagNames: selected)
	}
}

// MARK: - ImageDisplayConfiguratorDelegate

extension DetailsViewController: ImageDisplayConfiguratorDelegate {
	func imageDisplayConfiguratorDidUpdateImageState(_ state: ImageState) {
		imageState = state
	}

	func imageDisplayConfiguratorDidUpdateProgress(_ value: Float) {
		ImageViewStateApplier.updateProgress(value, in: progressView)
	}
}

// MARK: - ItemActionSendingDelegate

extension DetailsViewController: ItemActionSendingDelegate {

	/// Called when the archive or tag-saving action starts.
	func didStartItemActionSending() {
		activityOverlay.start()
	}

	/// Called when the action finishes successfully.
	func didFinishItemActionSending() {
		activityOverlay.stop()
		sendingRequestsDelegate?.didMakeItemNonDownloadable(at: currentItemIndexPath!)
		navigationController?.popViewController(animated: true)
	}

	/// Called when the action fails.
	/// Displays an alert and logs the error.
	func didFailItemActionSending(userMessage: String) {
		activityOverlay.stop()

		AlertHelper.showAlertWithOkButton(
			on: self,
			title: Constants.Messages.DetailsScreen.errorTitle,
			message: userMessage
		)
	}
}

// MARK: - DetailsViewControllerDelegate

/// Delegate protocol for item-related callbacks from DetailsViewController.
protocol DetailsViewControllerDelegate: AnyObject {
	func didMakeItemNonDownloadable(at indexPath: IndexPath)
}
