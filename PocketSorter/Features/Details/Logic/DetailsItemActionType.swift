//
//  DetailsItemActionType.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 30.04.2025.
//
//  Represents the type of user-initiated action in the details screen,
//  such as archiving an item or saving tags.
//

import Foundation

/// The type of user action triggered in the Details screen.
enum DetailsItemActionType {
	/// Archiving the current item.
	case archive

	/// Saving the selected tags to the item.
	case saveTags
}
