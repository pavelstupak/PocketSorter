//
//  PersistentContainerProviding.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 27.04.2025.
//
// Defines the interface for providing Core Data contexts used across the application.
//

import CoreData

/// Defines the interface for providing Core Data contexts used across the application.
protocol PersistentContainerProviding {

	/// The view context used for UI-related operations on the main thread.
	var viewContext: NSManagedObjectContext { get }

	/// The background context used for performing background operations like saving and syncing.
	var backgroundContext: NSManagedObjectContext { get }

	/// Saves changes in the view context if any exist.
	func saveViewContextIfNeeded()
}
