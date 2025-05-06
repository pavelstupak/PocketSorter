//
//  UIApplication+UITesting.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
// Resets Core Data tags during UI tests when the "--reset-tags" argument is passed.
//

import UIKit
import CoreData

extension UIApplication {
	/// Resets all tags in Core Data if the launch argument "--reset-tags" is detected
	func resetIfNeeded() {
		if CommandLine.arguments.contains("--reset-tags") {
			let context = PersistentContainerProvider.shared.viewContext
			let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
			let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

			do {
				try context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
			} catch {
				Log.error("Failed to delete tags: \(error.localizedDescription)", logger: LoggerStore.tags)
			}
		}
	}
}
