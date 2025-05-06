//
//  TagFormatterTests.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 26.04.2025.
//
// Tests tag formatting functionality.
//

import XCTest
@testable import PocketSorter

final class TagFormatterTests: XCTestCase {

	func test_joinedTagNames_withMultipleTags_returnsSortedCommaSeparatedString() {
		let tags: Set<String> = ["banana", "apple", "cherry"]
		let result = TagFormatter.joinedTagNames(from: tags)
		
		XCTAssertEqual(result, "apple,banana,cherry", "Expected tags to be sorted and comma-separated.")
	}
	
	func test_joinedTagNames_withSingleTag_returnsTagWithoutComma() {
		let tags: Set<String> = ["swift"]
		let result = TagFormatter.joinedTagNames(from: tags)
		
		XCTAssertEqual(result, "swift", "Expected single tag without any commas.")
	}
	
	func test_joinedTagNames_withEmptySet_returnsEmptyString() {
		let tags: Set<String> = []
		let result = TagFormatter.joinedTagNames(from: tags)
		
		XCTAssertEqual(result, "", "Expected empty string for empty set of tags.")
	}
}
