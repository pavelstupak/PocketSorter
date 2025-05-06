//
//  TagSelectionManagerTests.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 26.04.2025.
//
// Tests logic for selecting and toggling tags.
//

import XCTest
@testable import PocketSorter

final class TagSelectionManagerTests: XCTestCase {
	
	// MARK: - Initialization

	func test_init_withNoInitialTags_selectedNamesIsEmpty() {
		// Given: a TagSelectionManager with no initial tags
		let manager = TagSelectionManager()
		
		// Then: selectedNames should be empty
		XCTAssertTrue(manager.selectedNames.isEmpty, "Expected selectedNames to be empty initially.")
	}

	func test_init_withInitialTags_selectedNamesContainsTags() {
		// Given: a TagSelectionManager with initial tags "swift" and "ios"
		let initialTags: Set<String> = ["swift", "ios"]
		let manager = TagSelectionManager(initial: initialTags)
		
		// Then: selectedNames should contain the initial tags
		XCTAssertEqual(manager.selectedNames, initialTags, "Expected selectedNames to match initial tags.")
	}
	
	// MARK: - Toggle

	func test_toggle_behavesCorrectly() {
		// Given: a TagSelectionManager with "swift" initially selected
		let manager = TagSelectionManager(initial: ["swift"])
		
		let testCases: [(inputTag: String, shouldBeSelectedAfterToggle: Bool)] = [
			("swift", false), // initially selected, should be unselected
			("ios", true)     // not selected, should be selected
		]
		
		for (tag, expectedState) in testCases {
			// When: toggling the tag
			manager.toggle(name: tag)
			
			// Then: selection state should match the expectation
			XCTAssertEqual(manager.isSelected(tag), expectedState, "Expected '\(tag)' selection state to be \(expectedState).")
			
			// Reset state for the next iteration
			manager.toggle(name: tag)
		}
	}
	
	// MARK: - isSelected

	func test_isSelected_returnsCorrectState() {
		// Given: a TagSelectionManager with "swift" and "ios" initially selected
		let manager = TagSelectionManager(initial: ["swift", "ios"])
		
		let testCases: [(inputTag: String, expectedIsSelected: Bool)] = [
			("swift", true),    // present initially
			("ios", true),      // present initially
			("android", false)  // not present
		]
		
		for (tag, expectedState) in testCases {
			// When: checking selection status for a tag
			let isSelected = manager.isSelected(tag)
			
			// Then: the selection status should match the expectation
			XCTAssertEqual(isSelected, expectedState, "Expected isSelected(\(tag)) to be \(expectedState).")
		}
	}
	
	// MARK: - isEmpty

	func test_isEmpty_returnsTrueWhenNoTagsSelected() {
		// Given: a TagSelectionManager with no selected tags
		let manager = TagSelectionManager()
		
		// Then: manager should be empty
		XCTAssertTrue(manager.isEmpty, "Expected manager to be empty initially.")
	}

	func test_isEmpty_returnsFalseWhenTagsSelected() {
		// Given: a TagSelectionManager with "swift" selected
		let manager = TagSelectionManager(initial: ["swift"])
		
		// Then: manager should not be empty
		XCTAssertFalse(manager.isEmpty, "Expected manager to not be empty when tags are selected.")
	}
}
