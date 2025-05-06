//
//  TableLoadingState.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 28.04.2025.
//
//  Represents different loading states for a table view.
//

import Foundation

/// Represents different loading states for a table view.
enum TableLoadingState {
	/// No active loading is happening.
	case idle

	/// Initial loading of the table view data.
	case initialLoading

	/// Loading additional pages (pagination).
	case pagingLoading
}
