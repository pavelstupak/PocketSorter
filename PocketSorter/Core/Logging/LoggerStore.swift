//
//  LoggerStore.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 25.04.2025.
//
//  Defines categorized logger instances for different functional areas of the app.
//

import OSLog

/// Centralized store for all application loggers, categorized by feature.
enum LoggerStore {
	
	/// Logs related to tag operations (creating, deleting, listing tags).
	static let tags = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "Tags"
	)

	/// Logs related to item operations (fetching, deleting, displaying saved items).
	static let items = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "Items"
	)

	/// Logs related to item details screen (viewing, updating, saving details).
	static let details = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "Details"
	)

	/// Logs related to Core Data operations (saving, fetching, deleting from the local database).
	static let coreData = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "CoreData"
	)

	/// Logs related to general networking operations (fetching articles, sending actions, API calls).
	static let networking = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "Networking"
	)

	/// Logs related to user interface (UI) events and UI-related logic.
	static let ui = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "UI"
	)

	/// Logs related specifically to authentication and authorization (OAuth process).
	static let auth = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "Auth"
	)

	/// Logs for JSON decoding and parsing errors.
	static let parsing = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "Parsing"
	)

	/// Logs related to core app functionality, non-specific to any single feature.
	static let core = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "PocketSorter",
		category: "Core"
	)
}

