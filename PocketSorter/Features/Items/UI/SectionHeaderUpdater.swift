//
//  SectionHeaderUpdater.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
// Updates section headers of a UITableView after a diffable data source snapshot is applied
//

import UIKit

/// Updates section headers of a UITableView after a diffable data source snapshot is applied
struct SectionHeaderUpdater {
	/// Forces layout update for visible section headers
	static func updateHeaders(in tableView: UITableView, dataSource: UITableViewDataSource?) {
		guard let visibleSections = tableView.indexPathsForVisibleRows?.map({ $0.section }) else { return }
		let visibleSectionsSet = Set(visibleSections)

		for section in visibleSectionsSet {
			if let header = tableView.headerView(forSection: section) {
				UIView.performWithoutAnimation {
					header.textLabel?.text = dataSource?.tableView?(tableView, titleForHeaderInSection: section)
					header.setNeedsLayout()
					header.layoutIfNeeded()
				}
			}
		}
	}
}
