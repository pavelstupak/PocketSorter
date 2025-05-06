//
//  SortingButtonUpdating.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 05.05.2025.
//
//  Defines an interface for updating the enabled state of a sorting button based on data conditions.
//

/// A protocol for updating the enabled state of a sorting button based on the current state of table data.
protocol SortingButtonUpdating: AnyObject {
	func updateSortingButtonState()
}
