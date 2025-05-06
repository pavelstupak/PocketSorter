//
//  TagSelectionManager.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Manages the selected tag names and toggles their selection state.
//

import Foundation

/// Manages selection state of tags by name.
final class TagSelectionManager {

	private(set) var selectedNames: Set<String>

	init(initial: Set<String> = []) {
		self.selectedNames = initial
	}

	/// Toggles the selection state of a tag name.
	func toggle(name: String) {
		if selectedNames.contains(name) {
			selectedNames.remove(name)
		} else {
			selectedNames.insert(name)
		}
	}

	/// Returns true if the tag name is currently selected.
	func isSelected(_ name: String) -> Bool {
		selectedNames.contains(name)
	}
	
	/// Returns true if there are no selected tag names.
	var isEmpty: Bool {
		selectedNames.isEmpty
	}
}
