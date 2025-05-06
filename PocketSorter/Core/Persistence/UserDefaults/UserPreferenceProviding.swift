//
//  UserPreferenceProviding.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 28.04.2025.
//
//  Protocol that defines methods for saving and loading user preferences as String values.
//

import Foundation

/// A protocol for saving and loading user preferences using string-based keys and values.
protocol UserPreferenceProviding {
	/// Saves a string value for a given preference key.
	func save(_ value: String, forKey key: String)

	/// Loads a string value for a given preference key.
	func load(forKey key: String) -> String?
}
