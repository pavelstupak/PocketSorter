//
//  NetworkManager.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 13.03.2025.
//
//  Implements the network layer for interacting with the Pocket API,
//  including item fetching, pagination logic, and request status tracking.
//

import Foundation

/// A central network manager that delegates authentication and item-related actions
/// to Pocket-specific services ("PocketAuthService", "PocketItemsService").
final class NetworkManager: NetworkManagerProtocol {

	// MARK: - Credentials & Pagination

	/// OAuth request token received before user authorization.
	var requestToken: String?

	/// OAuth access token used for authenticated API requests.
	private(set) var accessToken: String

	/// Pocket username associated with the authorized token.
	private(set) var username: String = ""

	/// Application's registered Pocket API key.
	let consumerKey: String

	/// Number of items to load per request.
	let itemsToDownload: Int = 30

	/// Current pagination offset.
	private(set) var offset: Int = 0

	/// Total number of items available on server (used for pagination).
	private(set) var totalCount: Int = Int.max

	/// Indicates whether the last fetch attempt succeeded (even if it returned no items).
	/// Defaults to `false` to ensure appropriate messaging before the first request.
	private(set) var wasLastRequestSuccessful = false

	/// Service responsible for securely storing and retrieving the access token.
	private let tokenStorage: TokenStoring

	/// Indicates whether all items have been fetched (pagination finished).
	var isPagingFinished: Bool {
		if totalCount == Int.max {
			Log.debug("totalCount is still Int.max, assuming no more data to fetch.", logger: LoggerStore.networking)
			return true
		}
		return offset >= totalCount
	}

	// MARK: - Services

	/// Handles authentication requests (request/access tokens).
	private lazy var authService = PocketAuthService(
		consumerKey: consumerKey,
		redirectURI: "pocketsorter:authorizationFinished"
	)

	/// Handles item-related API calls (archive, tagging).
	private lazy var actionsService = PocketActionsService(networkManager: self)

	/// Handles item-related API calls (fetch).
	private lazy var itemsFetcher = ItemsFetcher(networkManager: self)

	// MARK: - Initialization

	/// Initializes the NetworkManager, loading accessToken from Keychain or fallback config.
	init(tokenStorage: TokenStoring = TokenStorage.shared) {
		self.consumerKey = Bundle.main.pocketConsumerKey
		self.tokenStorage = tokenStorage

		if let savedAccessToken = tokenStorage.loadToken(for: "accessToken") {
			self.accessToken = savedAccessToken
		} else {
			let tokenFromConfig = Bundle.main.pocketAccessTokenFromConfig
			self.accessToken = tokenFromConfig
			tokenStorage.save(token: tokenFromConfig, for: "accessToken")
		}
	}

	// MARK: - Authentication

	/// Fetches request token from Pocket and stores it internally.
	func getRequestToken() async throws -> String {
		let token = try await authService.getRequestToken()
		self.requestToken = token
		return token
	}

	/// Retrieves access token and username from Pocket using the previously received request token.
	/// Stores both values internally for future use.
	func getAccessTokenAndUsername(using code: String) async throws {
		let (token, user) = try await authService.getAccessTokenAndUsername(using: code)
		self.accessToken = token
		self.username = user
		tokenStorage.save(token: token, for: "accessToken")
	}

	// MARK: - Working with Items

	/// Fetches the next page of items using current pagination state.
	func getSavedItems() async -> [SavedItem] {
		await itemsFetcher.fetchSavedItems()
	}

	/// Adds the given tags to the specified item using Pocket's "send" API.
	func addTagsToItem(itemId: Int, tags: String) async -> (Int, String) {
		await actionsService.addTagsToItem(itemId: itemId, tags: tags)
	}

	/// Archives the given item by ID using Pocket's "send" API.
	func archiveItem(itemId: Int) async -> (Int, String) {
		await actionsService.archiveItem(itemId: itemId)
	}

	/// Resets offset and totalCount to initial values, preparing for a fresh fetch.
	func resetPaging() {
		offset = 0
		totalCount = Int.max
	}

	/// Sets the success state of the last network request.
	func setLastRequestSuccessful(_ successful: Bool) {
		self.wasLastRequestSuccessful = successful
	}

	// MARK: - Pagination Updates

	/// Updates the current pagination offset.
	func updateOffset(_ offset: Int) {
		self.offset = offset
	}

	/// Updates the total count of available items.
	func updateTotalCount(_ totalCount: Int) {
		self.totalCount = totalCount
	}
}
