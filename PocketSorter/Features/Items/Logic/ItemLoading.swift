//
//  ItemLoading.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 27.04.2025.
//
//  Protocol that defines methods for loading and syncing paginated items from a remote source.
//

import Foundation

/// Defines an interface for loading and syncing items, typically from a remote network source.
protocol ItemLoading {

	/// Loads the first page of items and returns true if the result is empty.
	func loadFirstPageAndCheckIfEmpty() async -> Bool

	/// Loads the next page of items and appends them to the existing data set.
	func loadNextPage() async
}
