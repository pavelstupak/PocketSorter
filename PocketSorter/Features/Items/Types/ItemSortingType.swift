//
//  ItemSortingType.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Defines the available sorting types for organizing saved items.
//

/// Represents the available sorting options for items.
enum ItemSortingType: String {
	/// Sort items by the date they were added.
	case dateAdded
	
	/// Sort items by the estimated time required to read them.
	case timeToRead
}
