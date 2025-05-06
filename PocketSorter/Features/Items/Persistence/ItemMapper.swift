//
//  ItemMapper.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 25.04.2025.
//
//  Maps a SavedItem from the network into a Core Data Item, either by creating or updating.
//

import CoreData
import UIKit

/// Utility for mapping network models ("SavedItem") to Core Data entities ("Item")
enum ItemMapper {

	/// Creates a new Item and applies data from SavedItem
	static func map(_ saved: SavedItem, in context: NSManagedObjectContext) {
		let item = Item(context: context)
		apply(saved: saved, to: item)
	}

	/// Updates an existing Item with new SavedItem data
	static func update(_ item: Item, with saved: SavedItem) {
		apply(saved: saved, to: item)
	}

	/// Common logic for mapping fields from SavedItem to Item
	private static func apply(saved: SavedItem, to item: Item) {
		item.excerpt = saved.excerpt

		if saved.isArticle == "1" {
			item.type = SectionType.article.rawValue
		} else {
			item.type = (saved.hasVideo == "2" ? SectionType.video : SectionType.other).rawValue
		}

		item.isFavorite = saved.favorite == "1"
		item.itemId = Int64(saved.itemId) ?? 0
		item.timeAdded = Int64(saved.timeAdded) ?? 0
		item.timeToRead = Int64(saved.timeToRead)
		item.title = saved.resolvedTitle
		item.url = URL(string: saved.resolvedUrl)
		item.timeUpdated = Int64(saved.timeUpdated) ?? 0

		if let imageUrl = saved.topImageUrl {
			item.firstImageUrl = URL(string: imageUrl)
		} else {
			item.firstImageUrl = nil
		}

		if let vds = saved.videos?.values {
			let videos = Array(vds)
			item.firstVideoLength = Int64(DateTimeHelper.getVideoDurationInMins(Int(videos.first?.length ?? "0") ?? 0))
		} else {
			item.firstVideoLength = 0
		}
	}
}
