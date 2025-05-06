//
//  ItemsUIConfigurator.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
// Sets up UI elements like navigation and refresh control in ItemsViewController.
//

import UIKit
import CoreData

/// Responsible for setting up basic UI elements for ItemsViewController
struct ItemsUIConfigurator {

	/// Applies only UI-related setup (buttons, refreshControl, etc.)
	static func configure(_ controller: ItemsViewController) {
		disableLeftNavigationButton(for: controller)
		setupRefreshControl(for: controller)
	}

	/// Disables only the left navigation button
	private static func disableLeftNavigationButton(for controller: ItemsViewController) {
		controller.navigationItem.leftBarButtonItem?.isEnabled = false
	}

	/// Configures pull-to-refresh control
	private static func setupRefreshControl(for controller: ItemsViewController) {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(
			controller,
			action: #selector(controller.refreshData),
			for: .valueChanged
		)
		controller.tableView.refreshControl = refreshControl
	}
}
