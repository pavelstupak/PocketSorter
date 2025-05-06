//
//  TagRepository.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Provides Core Data operations for the Tag entity: create, delete.
//

import CoreData

/// A repository responsible for managing Tag entities using Core Data.
final class TagRepository {

	/// Creates and saves a tag with the given name.
	static func createTag(named name: String, in context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "Tag", in: context)!
		let tag = Tag(entity: entity, insertInto: context)
		tag.name = name

		do {
			try context.obtainPermanentIDs(for: [tag])
			try context.save()
		} catch let error as NSError {
			Log.error(
				"Could not create tag: \(error.localizedDescription), \(error.userInfo.description)",
				logger: LoggerStore.tags
			)
		}
	}

	/// Deletes a tag by its managed object ID and saves the context.
	static func deleteTag(objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
		do {
			let object = try context.existingObject(with: objectID)
			context.delete(object)
			try context.save()
		} catch let error as NSError {
			Log.error(
				"Could not delete tag: \(error.localizedDescription), \(error.userInfo.description)",
				logger: LoggerStore.tags
			)
		}
	}
}
