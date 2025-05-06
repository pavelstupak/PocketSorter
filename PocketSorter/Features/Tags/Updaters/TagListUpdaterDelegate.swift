//
//  TagListUpdaterDelegate.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 30.04.2025.
//
//  Notifies about changes in the tag list displayed by the table view.
//

import Foundation

/// A delegate protocol for receiving updates from TagListUpdater.
protocol TagListUpdaterDelegate: AnyObject {
	/// Called when the list of tags changes.
	/// - Parameter itemCount: The number of visible tag items.
	func tagListDidUpdate(itemCount: Int) async
}
