//
//  TagListViewTypes.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 01.05.2025.
//
//  Shared section and snapshot types for tag list-based data sources.
//

import UIKit
import CoreData

/// Represents a single section in a tag list table view.
enum TagListViewSection: Int, Hashable {
	case main
}

/// Shared snapshot type for tag list diffable data sources.
typealias TagListSnapshot = NSDiffableDataSourceSnapshot<TagListViewSection, NSManagedObjectID>
