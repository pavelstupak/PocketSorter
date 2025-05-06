//
//  ItemFRCBuilder.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 01.05.2025.
//
//  Provides configured NSFetchedResultsController<Item> instances
//  for use in UI components such as ItemsViewController.
//

import CoreData

/// Builds configured NSFetchedResultsController instances for displaying items.
enum ItemFRCBuilder {

	/// Creates and configures a fetched results controller for `Item` entities.
	/// - Parameters:
	///   - sorting: The sorting strategy to use for item listing.
	///   - context: The Core Data context to use.
	/// - Returns: A configured NSFetchedResultsController<Item> instance.
	static func make(
		sorting: ItemSortingType,
		context: NSManagedObjectContext
	) -> NSFetchedResultsController<Item> {
		let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

		let typeSort = NSSortDescriptor(key: #keyPath(Item.type), ascending: true)
		let timeAddedSort = NSSortDescriptor(key: #keyPath(Item.timeAdded), ascending: false)
		let idSort = NSSortDescriptor(key: #keyPath(Item.itemId), ascending: false)
		let timeToReadSort = NSSortDescriptor(key: #keyPath(Item.timeToRead), ascending: true)
		let timeToWatchSort = NSSortDescriptor(key: #keyPath(Item.firstVideoLength), ascending: true)

		let cacheName: String

		switch sorting {
		case .dateAdded:
			fetchRequest.sortDescriptors = [typeSort, timeAddedSort]
			cacheName = "itemsSortedByTimeAdded"

		case .timeToRead:
			fetchRequest.sortDescriptors = [typeSort, timeToReadSort, timeToWatchSort, idSort]
			cacheName = "itemsSortedByTimeToRead"
		}

		let frc = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: #keyPath(Item.type),
			cacheName: cacheName
		)

		return frc
	}
}
