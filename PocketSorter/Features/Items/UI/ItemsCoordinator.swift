//
//  ItemsCoordinator.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 28.04.2025.
//
// Handles navigation and setup between ItemsViewController and DetailsViewController
//

import UIKit

/// Handles navigation and setup between ItemsViewController and DetailsViewController.
final class ItemsCoordinator {

	private weak var viewController: ItemsViewController?

	init(viewController: ItemsViewController) {
		self.viewController = viewController
	}

	/// Prepares the DetailsViewController with the selected item.
	///
	/// - Parameters:
	///   - detailsViewController: The destination view controller to configure.
	///   - indexPath: The index path of the selected item in the table view.
	func prepareDetailsViewController(_ detailsViewController: DetailsViewController, for indexPath: IndexPath) {
		guard let viewController else { return }

		let item = viewController.fetchedResultsController.object(at: indexPath)
		detailsViewController.currentItem = item
		detailsViewController.currentItemIndexPath = indexPath
		detailsViewController.sendingRequestsDelegate = viewController
	}
}
