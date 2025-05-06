//
//  DateTimeHelper.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 25.04.2025.
//
//  Provides helper methods for relative time formatting and date calculations.
//

import Foundation

/// Utility functions for working with dates and time.
struct DateTimeHelper {

	/// Shared instance of RelativeDateTimeFormatter
	private static let relativeDateFormatter: RelativeDateTimeFormatter = {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		formatter.locale = Locale(identifier: "en_US")
		return formatter
	}()

	// MARK: Unix Time

	/// Returns the Unix timestamp for the start of the ISO 8601 week (Monday at 00:00 UTC) of the given date.
	static func getUnixTimeOfMonday(for date: Date) -> Int? {
		var calendar = Calendar(identifier: .iso8601)
		calendar.timeZone = TimeZone(secondsFromGMT: 0)!

		let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
		guard let monday = calendar.date(from: components) else {
			Log.error("Failed to calculate Monday date from components: \(components)", logger: LoggerStore.core)
			return nil
		}

		return Int(monday.timeIntervalSince1970)
	}

	// MARK: Relative Time

	/// Returns a human-readable relative time difference between the given Unix timestamp and now.
	static func getTimeDifference(from unixTime: Int) -> String {
		let date = Date(timeIntervalSince1970: Double(unixTime))
		return relativeDateFormatter.localizedString(for: date, relativeTo: Date())
	}

	// MARK: Durations

	/// Converts a duration in seconds to rounded-up whole minutes.
	static func getVideoDurationInMins(_ seconds: Int) -> Int {
		Int(ceil(Double(seconds) / 60.0))
	}
}
