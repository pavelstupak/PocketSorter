//
//  TokenStorage.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 27.04.2025.
//
//  Implements secure token management using the Keychain API.
//

import Foundation
import Security

/// A service responsible for securely saving, loading, and deleting tokens using the Keychain.
final class TokenStorage: TokenStoring {

	// MARK: - Singleton

	static let shared = TokenStorage()

	private init() {}

	// MARK: - Public Methods

	/// Saves a token string securely in the Keychain for a given key.
	func save(token: String, for key: String) {
		// Convert the token string into Data for Keychain storage
		guard let data = token.data(using: .utf8) else {
			Log.error("Failed to convert token to data for key: \(key)", logger: LoggerStore.auth)
			return
		}

		// Delete any existing token for the same key to avoid duplicates
		deleteToken(for: key)

		// Prepare the Keychain query to add the new token
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecValueData as String: data
		]

		// Attempt to save the token into Keychain
		let status = SecItemAdd(query as CFDictionary, nil)
		if status != errSecSuccess {
			Log.error("Failed to save token for key: \(key), status: \(status)", logger: LoggerStore.auth)
		}
	}

	/// Loads a token string from the Keychain for a given key.
	func loadToken(for key: String) -> String? {
		// Prepare the Keychain query to find the token by key
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]

		// Attempt to fetch the token data from Keychain
		var dataTypeRef: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

		switch status {
		case errSecSuccess:
			break
		case errSecItemNotFound:
			return nil
		default:
			Log.error("Failed to load token for key: \(key), status: \(status)", logger: LoggerStore.auth)
			return nil
		}

		// Convert the data back into a String
		guard let data = dataTypeRef as? Data,
			  let token = String(data: data, encoding: .utf8) else {
			Log.error("Failed to convert loaded data to String for key: \(key)", logger: LoggerStore.auth)
			return nil
		}

		return token
	}

	/// Deletes a token string from the Keychain for a given key.
	func deleteToken(for key: String) {
		// Prepare the Keychain query to delete the token by key
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key
		]

		// Attempt to delete the token from Keychain
		let status = SecItemDelete(query as CFDictionary)
		if status != errSecSuccess && status != errSecItemNotFound {
			Log.error("Failed to delete token for key: \(key), status: \(status)", logger: LoggerStore.auth)
		}
	}
}
