//
//  DateTimeHelperTests.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 26.04.2025.
//
// Tests date and time helper utilities.
//

import XCTest
@testable import PocketSorter

final class DateTimeHelperTests: XCTestCase {

	func test_getUnixTimeOfMonday_usingUnixTimestamps() {
		let testCases: [(inputUnix: TimeInterval, expectedMondayUnix: Int)] = [
			(1736304000, 1736121600), // Wed, Jan 8 2025 -> Mon, Jan 6 2025
			(1736659200, 1736121600), // Sun, Jan 12 2025 -> Mon, Jan 6 2025
			(1735746497, 1735516800), // Wed, Jan 1 2025 -> Mon, Dec 30 2024
			(1737362897, 1737331200)  // Mon, Jan 20 2025 06:00 -> Mon, Jan 20 2025 00:00
		]

		for (inputUnix, expectedUnix) in testCases {
			let inputDate = Date(timeIntervalSince1970: inputUnix)

			guard let resultUnix = DateTimeHelper.getUnixTimeOfMonday(for: inputDate) else {
				XCTFail("Function returned nil for input UNIX time: \(Int(inputUnix))")
				continue
			}

			XCTAssertEqual(resultUnix, expectedUnix, "Failed for input UNIX time: \(Int(inputUnix))")
		}
	}

	func test_getTimeDifference_returnsAgoForPastDate() {
		// Given
		let fiveMinutesAgo = Int(Date().addingTimeInterval(-300).timeIntervalSince1970) // 5 minutes ago

		// When
		let result = DateTimeHelper.getTimeDifference(from: fiveMinutesAgo)

		// Then
		XCTAssertFalse(result.isEmpty, "Time difference string should not be empty.")
		XCTAssertTrue(result.contains("ago"), "Result should contain 'ago'. Got: \(result)")
	}

	func test_getVideoDurationInMins_roundingUp() {
		XCTAssertEqual(DateTimeHelper.getVideoDurationInMins(0), 0, "0 seconds should be 0 minutes.")
		XCTAssertEqual(DateTimeHelper.getVideoDurationInMins(59), 1, "59 seconds should round up to 1 minute.")
		XCTAssertEqual(DateTimeHelper.getVideoDurationInMins(60), 1, "60 seconds should be exactly 1 minute.")
		XCTAssertEqual(DateTimeHelper.getVideoDurationInMins(61), 2, "61 seconds should round up to 2 minutes.")
	}
}
