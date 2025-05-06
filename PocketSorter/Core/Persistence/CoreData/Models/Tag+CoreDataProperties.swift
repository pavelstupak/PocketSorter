//
//  Tag+CoreDataProperties.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 29.04.2025.
//
// Declares properties and fetch request for the Tag Core Data entity.
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var name: String

}

extension Tag : Identifiable {

}
