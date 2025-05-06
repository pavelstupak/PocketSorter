//
//  PocketItemModels.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 04.05.2025.
//
//  Declares request and response models used for communicating with the Pocket API (get Items).
//

import Foundation

/// Represents the request body for fetching articles from the Pocket API.
struct JsonGetSavedItems: Encodable {
	/// The consumer key used to authenticate with the Pocket API.
	let consumerKey: String

	/// The access token for authenticating the user.
	let accessToken: String

	/// The state of the items to fetch (e.g., "unread", "all").
	let state: String

	/// The tag used to filter the items (e.g., "_untagged_").
	let tag: String

	/// The sorting order for the articles (e.g., "newest", "oldest").
	let sort: String

	/// The detail type to retrieve (e.g., "complete" or "simple").
	let detailType: String

	/// The Unix timestamp representing the time since which to fetch items.
	let since: Int

	/// The number of items to fetch.
	let count: Int

	/// The offset for pagination (used to fetch the next set of items).
	let offset: Int

	/// The total number of items to fetch (can be set to "1" to request the total count).
	let total: String
}

struct SavedItemsList: Decodable {
	let status: Int?
	let error: String?
	let list: [String:SavedItem]?
	let total: String?
}

/// Represents an item fetched from the API with details such as title, time to read, etc.
struct SavedItem: Decodable {
	/// Excerpt or summary of the item.
	let excerpt: String

	/// Flag indicating if the item is marked as favorite.
	let favorite: String

	/// Unique identifier for the item.
	let itemId: String

	/// A value indicating whether the item is an article or not (1 or 0)
	let isArticle: String

	/// 0 - if the item has no videos, 1 - if the item has videos in it, 2 - if the item is a video
	let hasVideo: String

	/// Language of the item.
	let lang: String

	/// Title of the item.
	let resolvedTitle: String

	/// URL of the item.
	let resolvedUrl: String

	/// Timestamp when the item was added.
	let timeAdded: String

	/// Timestamp when the item was updated.
	let timeUpdated: String

	/// Estimated time to read the item in seconds.
	let timeToRead: Int

	/// URL of the item's top image (optional).
	let topImageUrl: String?

	/// List of videos associated with the item, if any.
	let videos: [String:VideoItem]?
}

struct VideoItem: Decodable {
	let length: String
	let src: String
}
