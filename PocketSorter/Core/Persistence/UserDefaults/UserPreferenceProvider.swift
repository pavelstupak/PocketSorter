//
//  UserPreferenceProvider.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 28.04.2025.
//
//  Concrete implementation of UserPreferenceProviding that uses UserDefaults
//  to store and retrieve string-based user preferences.
//

import Foundation

/// A concrete implementation of `UserPreferenceProviding` using `UserDefaults` for persistence.
final class UserPreferenceProvider: UserPreferenceProviding {
	private let userDefaults: UserDefaults

	/// Initializes the provider with a given `UserDefaults` instance.
	/// - Parameter userDefaults: The `UserDefaults` instance to use. Defaults to `.standard`.
	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}

	/// Saves a string value for the specified key.
	/// - Parameters:
	///   - value: The string value to save.
	///   - key: The preference key under which to save the value.
	func save(_ value: String, forKey key: String) {
		userDefaults.set(value, forKey: key)
	}

	/// Loads a string value for the specified key.
	/// - Parameter key: The preference key for which to load the value.
	/// - Returns: The string value if it exists, or `nil` otherwise.
	func load(forKey key: String) -> String? {
		userDefaults.string(forKey: key)
	}
}
