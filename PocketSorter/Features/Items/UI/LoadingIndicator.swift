//
//  LoadingIndicator.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Controls table view refresh indicator and navigation bar buttons during different loading states.
//

import UIKit

struct LoadingIndicator {
	/// Updates the loading state of the table view and navigation bar buttons.
	static func updateLoadingState(_ state: TableLoadingState, in controller: ItemsViewController) {
		switch state {
		case .idle:
			// Loading completed: stop refresh control and enable both buttons.
			if controller.tableView.refreshControl?.isRefreshing == true {
				controller.tableView.refreshControl?.endRefreshing()
			}

			controller.updateSortingButtonState()
			setEnabled(true, for: controller.navigationItem.rightBarButtonItem)

		case .initialLoading:
			// Initial loading: show refresh control and disable both buttons.
			controller.tableView.refreshControl?.isHidden = false
			controller.tableView.refreshControl?.beginRefreshing()
			setEnabled(false, for: controller.navigationItem.leftBarButtonItem)
			setEnabled(false, for: controller.navigationItem.rightBarButtonItem)

		case .pagingLoading:
			// Paging: hide refresh control, disable left button (sorting), enable right (settings).
			controller.tableView.refreshControl?.endRefreshing()
			setEnabled(false, for: controller.navigationItem.leftBarButtonItem)
			setEnabled(true, for: controller.navigationItem.rightBarButtonItem)
		}
	}

	/// Enables or disables a given bar button item.
	private static func setEnabled(_ isEnabled: Bool, for button: UIBarButtonItem?) {
		button?.isEnabled = isEnabled
	}
}
