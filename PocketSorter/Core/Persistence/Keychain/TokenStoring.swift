//
//  TokenStoring.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 27.04.2025.
//
//  Declares a protocol for saving, loading, and deleting tokens securely.
//

import Foundation

/// A protocol defining methods for securely saving, loading, and deleting tokens.
protocol TokenStoring {
	/// Saves a token string for a given key.
	func save(token: String, for key: String)

	/// Loads a token string associated with a given key.
	func loadToken(for key: String) -> String?

	/// Deletes a token string associated with a given key.
	func deleteToken(for key: String)
}
