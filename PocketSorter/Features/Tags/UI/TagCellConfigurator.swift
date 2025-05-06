//
//  TagCellConfigurator.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
// Configures table view cells to display tag information.
//

import UIKit

/// Configures a UITableViewCell for displaying a Tag
struct TagCellConfigurator {
	static func configure(_ cell: UITableViewCell, with tag: Tag) {
		var content = cell.defaultContentConfiguration()
		content.text = tag.name
		cell.contentConfiguration = content
	}
}
