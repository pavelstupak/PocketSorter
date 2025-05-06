//
//  PersistentContainerProvider.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 27.04.2025.
//
// Provides main and background Core Data contexts with merge policy configuration.
//

import UIKit
import CoreData

/// Default implementation of `PersistentContainerProviding` that retrieves and configures
/// Core Data contexts.
final class PersistentContainerProvider: PersistentContainerProviding {

	/// Shared singleton instance used throughout the app.
	static let shared = PersistentContainerProvider()

	private init() {}

	/// Core Data container used to manage the persistent store.
	private lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "PocketSorter")
		container.loadPersistentStores { description, error in
			if let error = error as NSError? {
				Log.error("Failed to load persistent store: \(error), \(error.userInfo)", logger: LoggerStore.coreData)
			}
		}
		return container
	}()

	/// Provides the main view context for UI operations, automatically merging changes from the parent.
	var viewContext: NSManagedObjectContext {
		let context = persistentContainer.viewContext
		configure(context: context, automaticallyMergesChanges: true)

		return context
	}

	/// Provides a background context for performing background operations on a private queue.
	var backgroundContext: NSManagedObjectContext {
		let context = persistentContainer.newBackgroundContext()
		configure(context: context, automaticallyMergesChanges: false)
		return context
	}

	/// Configures the given managed object context with a default merge policy and optional automatic merging.
	/// - Parameters:
	///   - context: The context to configure.
	///   - automaticallyMergesChanges: Whether the context should automatically merge changes from its parent.
	private func configure(context: NSManagedObjectContext, automaticallyMergesChanges: Bool) {
		context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
		context.automaticallyMergesChangesFromParent = automaticallyMergesChanges
	}

	/// Attempts to save the main view context if there are any changes.
	func saveViewContextIfNeeded() {
		let context = viewContext
		guard context.hasChanges else { return }
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			Log.error("Failed to save Core Data context: \(nserror), \(nserror.userInfo)", logger: LoggerStore.coreData)
		}
	}
}
