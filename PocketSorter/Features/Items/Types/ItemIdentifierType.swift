//
//  ItemIdentifierType.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 03.05.2025.
//
//  Represents a unique diffable data source identifier for Item,
//  combining objectID and timeUpdated to track UI-relevant updates.
//

import CoreData

/// A unique identifier for diffable data source snapshots.
/// Combines the NSManagedObjectID and timeUpdated to detect changes.
struct ItemIdentifierType: Hashable {
	let objectID: NSManagedObjectID
	let timeUpdated: Int64
}
