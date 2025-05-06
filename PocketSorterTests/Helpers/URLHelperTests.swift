//
//  URLHelperTests.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 26.04.2025.
//
// Tests helper extension for URL instances.
//

import XCTest
@testable import PocketSorter

final class URLHelperTests: XCTestCase {

	func test_hostOrEmpty_returnsHostWhenPresent() {
		let url = URL(string: "https://getpocket.com/login")!
		
		XCTAssertEqual(url.hostOrEmpty(), "getpocket.com", "Expected correct host for URL.")
	}
	
	func test_hostOrEmpty_returnsEmptyWhenHostIsMissing() {
		let url = URL(string: "/local/path")!
		
		XCTAssertEqual(url.hostOrEmpty(), "", "Expected empty string when host is missing.")
	}
	
	func test_queryValue_returnsValueForExistingKey() {
		let url = URL(string: "myapp://auth?access_token=abc123&state=xyz")!
		
		let value = url.queryValue(for: "access_token")
		
		XCTAssertEqual(value, "abc123", "Expected to extract correct query value for 'access_token'.")
	}
	
	func test_queryValue_returnsNilForMissingKey() {
		let url = URL(string: "myapp://auth?access_token=abc123")!
		
		let value = url.queryValue(for: "state")
		
		XCTAssertNil(value, "Expected nil when query key is missing.")
	}
}
