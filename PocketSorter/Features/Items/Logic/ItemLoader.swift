//
//  ItemLoader.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  A concrete class that implements item loading and synchronization using Core Data and a network source.
//

import CoreData

/// Handles loading and syncing items from the network into Core Data
final class ItemLoader: ItemLoading {

	/// Context for performing background inserts
	private let backgroundContext: NSManagedObjectContext

	/// Context for notifying the UI layer
	private let viewContext: NSManagedObjectContext

	/// Fetches data from the network
	private let networkManager: NetworkManagerProtocol

	/// Stores itemIds fetched during this session
	private var fetchedItemIDs = Set<Int64>()

	/// Initializes the loader with Core Data contexts and a network manager.
	init(
		backgroundContext: NSManagedObjectContext,
		viewContext: NSManagedObjectContext,
		networkManager: NetworkManagerProtocol
	) {
		self.backgroundContext = backgroundContext
		self.viewContext = viewContext
		self.networkManager = networkManager
	}

	/// Loads the first page of items and returns a flag indicating if the result is empty.
	func loadFirstPageAndCheckIfEmpty() async -> Bool {
		try? Task.checkCancellation()

		fetchedItemIDs = []

		let savedItems = await networkManager.getSavedItems()
		try? Task.checkCancellation()

		if savedItems.isEmpty {
			return true
		}

		await saveItems(savedItems)
		return false
	}

	/// Loads the next page of items and appends them to Core Data.
	func loadNextPage() async {
		try? Task.checkCancellation()

		let savedItems = await networkManager.getSavedItems()
		try? Task.checkCancellation()

		guard !savedItems.isEmpty else { return }

		await saveItems(savedItems)
	}

	/// Removes items from Core Data that were not returned during the full data load.
	func removeOutdatedItems() async {
		await backgroundContext.perform {
			ItemRepository.deleteItemsNotIn(
				self.fetchedItemIDs,
				in: self.backgroundContext,
				notify: self.viewContext
			)
		}
	}

	/// Saves an array of "SavedItem" models and accumulates their itemIds.
	private func saveItems(_ savedItems: [SavedItem]) async {
		await backgroundContext.perform {
			ItemRepository.saveItems(savedItems, in: self.backgroundContext, notify: self.viewContext)
		}

		let ids = savedItems.compactMap { Int64($0.itemId) }
		fetchedItemIDs.formUnion(ids)
	}
}
