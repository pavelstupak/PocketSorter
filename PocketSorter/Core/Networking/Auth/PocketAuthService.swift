//
//  PocketAuthService.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
// Manages OAuth tokens and authentication flow with Pocket API.
//

import Foundation

/// Handles authentication with the Pocket API, including request token retrieval and access token authorization.
final class PocketAuthService {
	private let consumerKey: String
	private let redirectURI: String

	/// Initializes the service with the given consumer key and redirect URI.
	/// - Parameters:
	///   - consumerKey: The application's registered Pocket consumer key.
	///   - redirectURI: The URI to which Pocket redirects after user authorization.
	init(consumerKey: String, redirectURI: String) {
		self.consumerKey = consumerKey
		self.redirectURI = redirectURI
	}

	/// Requests a temporary request token from Pocket that initiates the OAuth flow.
	///
	/// - Returns: A request token as a `String`.
	/// - Throws: A `URLError` if the request fails or the server responds with an error.
	func getRequestToken() async throws -> String {
		guard let url = URL(string: "https://getpocket.com/v3/oauth/request") else {
			Log.error("Invalid URL for request token endpoint", logger: LoggerStore.auth)
			throw URLError(.badURL)
		}

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "X-Accept")

		let body = JsonGetRequestToken(consumerKey: consumerKey, redirectUri: redirectURI)
		request.httpBody = try JSONEncoder().encode(body)

		let (data, response) = try await URLSession.shared.data(for: request)

		// Validate server response
		if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
			Log.error("Request token request failed with status code: \(httpResponse.statusCode)", logger: LoggerStore.auth)
			throw URLError(.badServerResponse)
		}

		let responseObject = try PocketParser.decode(JsonGetRequestTokenResponse.self, from: data)
		Log.debug("Request token received: \(responseObject.code)", logger: LoggerStore.auth)
		return responseObject.code
	}

	/// Exchanges a request token for an access token and the associated username.
	///
	/// - Parameter code: The request token obtained during the initial OAuth request phase.
	/// - Returns: A tuple containing the access token (`String`) and the username (`String`).
	/// - Throws: A `URLError` if the request fails or the response is invalid.
	func getAccessTokenAndUsername(using code: String) async throws -> (String, String) {
		guard let url = URL(string: "https://getpocket.com/v3/oauth/authorize") else {
			Log.error("Invalid URL for access token endpoint", logger: LoggerStore.auth)
			throw URLError(.badURL)
		}

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "X-Accept")

		let body = JsonGetAccessTokenAndUsername(consumerKey: consumerKey, code: code)
		request.httpBody = try JSONEncoder().encode(body)

		let (data, response) = try await URLSession.shared.data(for: request)

		// Validate server response
		if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
			Log.error("Access token request failed with status code: \(httpResponse.statusCode)", logger: LoggerStore.auth)
			throw URLError(.badServerResponse)
		}

		let responseObject = try PocketParser.decode(JsonGetAccessTokenAndUsernameResponse.self, from: data)
		Log.debug("Access token: \(responseObject.accessToken), Username: \(responseObject.username)", logger: LoggerStore.auth)
		return (responseObject.accessToken, responseObject.username)
	}
}
