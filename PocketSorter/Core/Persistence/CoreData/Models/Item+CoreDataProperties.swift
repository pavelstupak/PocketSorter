//
//  Item+CoreDataProperties.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 29.04.2025.
//
// Declares properties and fetch request logic for the Item Core Data entity.
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var excerpt: String?
    @NSManaged public var firstImageData: Data?
    @NSManaged public var firstImageUrl: URL?
    @NSManaged public var firstVideoLength: Int64
    @NSManaged public var isFavorite: Bool
    @NSManaged public var itemId: Int64
    @NSManaged public var timeAdded: Int64
    @NSManaged public var timeToRead: Int64
	@NSManaged public var timeUpdated: Int64
    @NSManaged public var title: String?
    @NSManaged public var type: String
    @NSManaged public var url: URL?

}

extension Item : Identifiable {

}
