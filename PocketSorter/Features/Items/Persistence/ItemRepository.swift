//
//  ItemRepository.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Manages saving, updating, and deleting Item entities in Core Data.
//

import CoreData
import UIKit

/// A repository for managing Core Data operations related to "Item" entities.
final class ItemRepository {

	/// Maps an array of "SavedItem" models to Core Data "Item" entities and saves them.
	/// Updates existing items if newer by `timeUpdated`, inserts new ones otherwise.
	/// Notifies the view context about updated objects if needed.
	/// - Parameters:
	///   - savedItems: The array of network models to map.
	///   - backgroundContext: The Core Data context to save into (usually privateQueue).
	///   - viewContext: The UI context to notify about changes (usually main queue).
	static func saveItems(
		_ savedItems: [SavedItem],
		in backgroundContext: NSManagedObjectContext,
		notify viewContext: NSManagedObjectContext
	) {
		let ids = savedItems.compactMap { Int64($0.itemId) }

		let request: NSFetchRequest<Item> = Item.fetchRequest()
		request.predicate = NSPredicate(format: "itemId IN %@", ids)

		let existingItems: [Item]
		do {
			existingItems = try backgroundContext.fetch(request)
		} catch {
			Log.error("Failed to fetch existing items: \(error)", logger: LoggerStore.items)
			return
		}

		let existingMap = Dictionary(uniqueKeysWithValues: existingItems.map { ($0.itemId, $0) })
		var updatedObjectIDs: [NSManagedObjectID] = []

		for saved in savedItems {
			let itemId = Int64(saved.itemId) ?? 0
			let newUpdatedAt = Int64(saved.timeUpdated) ?? 0

			if let existing = existingMap[itemId] {
				if newUpdatedAt > existing.timeUpdated {
					ItemMapper.update(existing, with: saved)
					updatedObjectIDs.append(existing.objectID)
				}
			} else {
				ItemMapper.map(saved, in: backgroundContext)
			}
		}

		do {
			try backgroundContext.save()
		} catch {
			Log.error("Failed to save items: \(error)", logger: LoggerStore.items)
		}
	}

	/// Deletes all items from Core Data whose itemId is not in the given set,
	/// and notifies the provided view context about changes.
	/// - Parameters:
	///   - validIDs: The set of itemId values that should be kept.
	///   - backgroundContext: The background context to perform deletion in.
	///   - viewContext: The UI context to notify for updates.
	static func deleteItemsNotIn(
		_ validIDs: Set<Int64>,
		in backgroundContext: NSManagedObjectContext,
		notify viewContext: NSManagedObjectContext
	) {
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "NOT (itemId IN %@)", validIDs)

		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		deleteRequest.resultType = .resultTypeObjectIDs

		do {
			let result = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
			if let objectIDs = result?.result as? [NSManagedObjectID] {
				let changes = [NSDeletedObjectsKey: objectIDs]
				NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
			}
		} catch {
			Log.error("Failed to delete outdated items: \(error)", logger: LoggerStore.items)
		}
	}

	/// Deletes an item from the given fetched results controller and saves the context.
	/// - Parameters:
	///   - controller: The FRC managing the item.
	///   - indexPath: The index of the item to delete.
	///   - context: The context to delete from and save.
	static func deleteItem(
		from controller: NSFetchedResultsController<Item>,
		at indexPath: IndexPath,
		in context: NSManagedObjectContext
	) {
		let item = controller.object(at: indexPath)
		context.delete(item)

		do {
			try context.save()
		} catch {
			Log.error("Failed to delete item: \(error)", logger: LoggerStore.items)
		}
	}

	/// Saves image data into an item and persists the change.
	/// - Parameters:
	///   - data: The image data to store.
	///   - item: The item to update.
	///   - context: The Core Data context to save.
	static func saveImageData(_ data: Data, to item: inout Item, in context: NSManagedObjectContext) {
		item.firstImageData = data

		do {
			try context.save()
		} catch {
			Log.error("Failed to save image data: \(error)", logger: LoggerStore.items)
		}
	}
}
