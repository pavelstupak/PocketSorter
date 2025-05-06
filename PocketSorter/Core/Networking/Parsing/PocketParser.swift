//
//  PocketParser.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
// Decodes JSON responses from the Pocket API with snake_case support and error logging.
//

import Foundation

/// A lightweight JSON decoder utility used across networking services.
/// Handles decoding of responses using snake_case keys and consistent error logging.
enum PocketParser {

	/// Decodes a "Data" object into a concrete "Decodable" type using snake_case keys.
	///
	/// - Parameters:
	///   - type: The target type to decode.
	///   - data: The raw JSON data received from the network.
	/// - Returns: A decoded object of the specified type.
	/// - Throws: A decoding error if the operation fails.
	static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		do {
			return try decoder.decode(type, from: data)
		} catch {
			Log.error("Failed to decode \(String(describing: T.self)): \(error.localizedDescription)", logger: LoggerStore.parsing)
			throw error
		}
	}
}
