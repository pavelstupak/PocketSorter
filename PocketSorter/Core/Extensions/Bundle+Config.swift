//
//  Bundle+Config.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 27.04.2025.
//
// Provides access to Pocket API credentials stored in Info.plist (via .xcconfig).
//

import Foundation

extension Bundle {
	/// Returns a string from Info.plist for the given key, or an empty string if missing.
	/// Logs an error if the key is missing or empty.
	private func string(for key: String) -> String {
		if let value = object(forInfoDictionaryKey: key) as? String, !value.isEmpty {
			return value
		} else {
			Log.error("\(key) is missing or empty in Info.plist. Check your .xcconfig and Build Settings.", logger: LoggerStore.auth)
			return ""
		}
	}

	/// The Pocket API consumer key loaded from Info.plist via xcconfig.
	var pocketConsumerKey: String {
		return string(for: "POCKET_CONSUMER_KEY")
	}

	/// The Pocket API access token loaded from Info.plist via xcconfig for initial setup.
	var pocketAccessTokenFromConfig: String {
		return string(for: "POCKET_ACCESS_TOKEN")
	}
}
