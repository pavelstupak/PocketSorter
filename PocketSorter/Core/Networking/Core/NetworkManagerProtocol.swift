//
//  NetworkManagerProtocol.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 27.04.2025.
//
//  Defines the interface for managing network-based interactions,
//  including item fetching, pagination state, and request tracking.
//

import Foundation

/// Defines the interface for working with Pocket network operations and pagination logic.
protocol NetworkManagerProtocol {

	// MARK: - Credentials

	/// Pocket API consumer key.
	var consumerKey: String { get }

	/// OAuth request token received during step 1 of authentication.
	var requestToken: String? { get set }

	/// Access token received after user grants permission.
	var accessToken: String { get }

	/// Username associated with the Pocket account.
	var username: String { get }

	// MARK: - Pagination & State

	/// Number of items to fetch per page.
	var itemsToDownload: Int { get }

	/// Offset for paginated loading.
	var offset: Int { get }

	/// Total number of items available on the server.
	var totalCount: Int { get }

	/// Indicates whether all pages have been loaded.
	var isPagingFinished: Bool { get }

	/// Indicates whether the last request was successful (true) or failed (false).
	var wasLastRequestSuccessful: Bool { get }

	// MARK: - Authentication

	/// Retrieves a request token to begin the OAuth process.
	func getRequestToken() async throws -> String

	/// Exchanges request token for access token and username.
	func getAccessTokenAndUsername(using code: String) async throws

	// MARK: - Working with Items

	/// Fetches saved items from the user's Pocket account.
	func getSavedItems() async -> [SavedItem]

	/// Adds one or more tags to a specific item.
	func addTagsToItem(itemId: Int, tags: String) async -> (Int, String)

	/// Archives a specific item.
	func archiveItem(itemId: Int) async -> (Int, String)

	/// Resets internal pagination counters.
	func resetPaging()

	/// Updates the success status of the most recent fetch request.
	///
	/// - Parameter successful: A Boolean value indicating whether the last request completed successfully.
	func setLastRequestSuccessful(_ successful: Bool)

	// MARK: - Pagination Updates

	/// Updates the current pagination offset.
	func updateOffset(_ offset: Int)

	/// Updates the total count of available items.
	func updateTotalCount(_ totalCount: Int)
}
