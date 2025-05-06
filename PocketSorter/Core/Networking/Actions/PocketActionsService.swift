//
//  PocketActionsService.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
//  Provides high-level operations for tagging, and archiving items
//  using the Pocket API via the underlying network manager.
//

import Foundation

/// Service responsible for updating saved Pocket items.
final class PocketActionsService {
	
	private let networkManager: NetworkManagerProtocol

	/// Initializes the service with a network manager.
	/// - Parameter networkManager: The instance managing credentials and pagination state.
	init(networkManager: NetworkManagerProtocol) {
		self.networkManager = networkManager
	}
	
	/// Adds one or more tags to a specific item using Pocket's "send" API.
	///
	/// - Parameters:
	///   - itemId: The ID of the item to tag.
	///   - tags: Comma-separated string of tag names.
	/// - Returns: A tuple containing the status code and optional error description.
	func addTagsToItem(itemId: Int, tags: String) async -> (Int, String) {
		let encodedTags = tags.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? tags
		let actions = """
		[{"action":"tags_add","item_id":"\(itemId)","tags":"\(encodedTags)"}]
		"""

		guard let encodedActions = actions.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			Log.error("Failed to encode actions", logger: LoggerStore.networking)

			return (0, "Failed to encode actions")
		}

		let urlString = "https://getpocket.com/v3/send?actions=\(encodedActions)&access_token=\(networkManager.accessToken)&consumer_key=\(networkManager.consumerKey)"

		return await sendActionRequest(urlString: urlString)
	}

	/// Archives a specific item using Pocket's "send" API.
	///
	/// - Parameter itemId: The ID of the item to archive.
	/// - Returns: A tuple containing the status code and optional error description.
	func archiveItem(itemId: Int) async -> (Int, String) {
		let actions = """
		[{"action":"archive","item_id":"\(itemId)"}]
		"""

		guard let encodedActions = actions.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			Log.error("Failed to encode actions", logger: LoggerStore.networking)

			return (0, "Failed to encode actions")
		}

		let urlString = "https://getpocket.com/v3/send?actions=\(encodedActions)&access_token=\(networkManager.accessToken)&consumer_key=\(networkManager.consumerKey)"

		return await sendActionRequest(urlString: urlString)
	}

	/// Sends a request to the Pocket "send" API for actions like tagging or archiving.
	///
	/// - Parameter urlString: The complete URL string to perform the action.
	/// - Returns: A tuple containing the status code and optional error description.
	private func sendActionRequest(urlString: String) async -> (Int, String) {
		guard let url = URL(string: urlString) else {
			Log.error("Invalid URL for sending actions: \(urlString)", logger: LoggerStore.networking)
			return (0, "Invalid URL")
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"

		var status = 0
		var description = ""

		do {
			let (data, response) = try await URLSession.shared.data(for: request)

			if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
				description += "Status Code: \(httpResponse.statusCode)"
				Log.error("Non-200 HTTP status received: \(httpResponse.statusCode)", logger: LoggerStore.networking)
			}

			let result: JsonSendActionResponse = try PocketParser.decode(JsonSendActionResponse.self, from: data)
			status = result.status

		} catch let error as URLError {
			description = getDescriptionOfNetworkError(error)
			Log.error("Network error: \(error.localizedDescription)", logger: LoggerStore.networking)
		} catch {
			description += " Failed to parse response."
			Log.error("Unexpected error: \(error.localizedDescription)", logger: LoggerStore.networking)
		}

		return (status, description)
	}
}
