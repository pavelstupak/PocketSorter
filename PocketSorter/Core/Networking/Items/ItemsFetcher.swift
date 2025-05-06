//
//  ItemsFetcher.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 04.05.2025.
//
//  Fetches saved items from Pocket and updates pagination state using NetworkManager.
//

import Foundation

/// Service responsible for fetching saved Pocket items.
final class ItemsFetcher {

	private let networkManager: NetworkManagerProtocol

	/// Initializes the service with a network manager.
	/// - Parameter networkManager: The instance managing credentials and pagination state.
	init(networkManager: NetworkManagerProtocol) {
		self.networkManager = networkManager
	}

	/// Fetches saved items from the Pocket server.
	/// Updates pagination state ("offset", "totalCount") inside the network manager.
	///
	/// - Returns: An array of `SavedItem` objects.
	func fetchSavedItems() async -> [SavedItem] {
		var articles: [SavedItem] = []

		guard let mondayUnix = DateTimeHelper.getUnixTimeOfMonday(for: Date()) else {
			Log.error("Failed to calculate 'since' parameter", logger: LoggerStore.networking)
			networkManager.setLastRequestSuccessful(false)
			return []
		}

		let bodyJson = JsonGetSavedItems(
			consumerKey: networkManager.consumerKey,
			accessToken: networkManager.accessToken,
			state: "unread",
			tag: "_untagged_",
			sort: "newest",
			detailType: "complete",
			since: mondayUnix,
			count: networkManager.itemsToDownload,
			offset: networkManager.offset,
			total: "1"
		)

		do {
			let (fetchedArticles, total) = try await sendRequest(bodyJson)
			networkManager.setLastRequestSuccessful(true)
			articles = fetchedArticles
			networkManager.updateOffset(networkManager.offset + networkManager.itemsToDownload)
			networkManager.updateTotalCount(total)
		} catch {
			networkManager.setLastRequestSuccessful(false)
			Log.error("Failed to fetch saved items: \(error.localizedDescription)", logger: LoggerStore.networking)
		}

		return articles
	}

	/// Sends a request to fetch articles from the Pocket API.
	///
	/// - Parameter bodyJson: JSON body describing the fetch parameters.
	/// - Returns: A tuple containing an array of saved items and the total number of items.
	/// - Throws: An error if the network request or decoding fails.
	private func sendRequest(_ bodyJson: JsonGetSavedItems) async throws -> ([SavedItem], Int) {
		guard let url = URL(string: "https://getpocket.com/v3/get") else {
			Log.error("Invalid URL for fetching articles", logger: LoggerStore.networking)
			throw URLError(.badURL)
		}

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		request.httpBody = try encoder.encode(bodyJson)

		let (data, _) = try await URLSession.shared.data(for: request)
		let parsed: SavedItemsList = try PocketParser.decode(SavedItemsList.self, from: data)

		if let errorMessage = parsed.error, !errorMessage.isEmpty {
			Log.error("API error: \(errorMessage)", logger: LoggerStore.networking)
			throw NSError(
				domain: "com.pocketsorter",
				code: 1,
				userInfo: [NSLocalizedDescriptionKey: "Failed to load items"]
			)
		}

		let total = Int(parsed.total ?? "") ?? 0
		let items = parsed.list?.map { $0.value } ?? []

		return (items, total)
	}
}
