//
//  DetailsUIConfigurator.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
// Applies static UI configuration to DetailsViewController based on the item.
//

import UIKit

/// Configures static UI elements in the DetailsViewController based on the given item
struct DetailsUIConfigurator {
	static func configure(_ controller: DetailsViewController, with item: Item) {
		// Text setup
		controller.titleLabel.text = item.title
		controller.excerptLabel.text = item.excerpt

		// Button styling
		controller.archiveButton.showBorders()
		controller.linkButton.showBorders()

		// Navigation setup
		controller.navigationItem.rightBarButtonItem?.isEnabled = false
	}
}
