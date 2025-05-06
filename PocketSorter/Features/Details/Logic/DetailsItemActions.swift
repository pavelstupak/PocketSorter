//
//  DetailsItemActions.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
//  Handles user-initiated actions for the item displayed in the details screen,
//  such as archiving the item or saving selected tags.
//

import UIKit

/// Performs item-related actions and notifies the delegate of progress or failure.
final class DetailsItemActions {

	// MARK: - Dependencies

	private weak var delegate: ItemActionSendingDelegate?

	private let itemService: PocketActionsService
	private let currentItem: Item
	private let indexPath: IndexPath

	// MARK: - Init

	init(
		itemService: PocketActionsService,
		currentItem: Item,
		indexPath: IndexPath,
		delegate: ItemActionSendingDelegate
	) {
		self.itemService = itemService
		self.currentItem = currentItem
		self.indexPath = indexPath
		self.delegate = delegate
	}

	// MARK: - Public actions

	/// Archives the current item by sending a request to the server.
	func archiveItem() {
		delegate?.didStartItemActionSending()

		Task {
			let (status, description) = await itemService.archiveItem(itemId: Int(currentItem.itemId))
			await MainActor.run {
				self.handleActionResult(
					status: status,
					description: description,
					actionType: .archive
				)
			}
		}
	}

	/// Saves the selected tags for the current item by sending them to the server.
	/// - Parameter selectedTagNames: A set of tag names selected by the user.
	func saveTags(selectedTagNames: Set<String>) {
		delegate?.didStartItemActionSending()

		let tagsString = TagFormatter.joinedTagNames(from: selectedTagNames)

		Task {
			let (status, description) = await itemService.addTagsToItem(
				itemId: Int(currentItem.itemId),
				tags: tagsString
			)
			await MainActor.run {
				self.handleActionResult(
					status: status,
					description: description,
					actionType: .saveTags
				)
			}
		}
	}

	// MARK: - Private

	/// Handles the result of a user action and notifies the delegate of the outcome.
	private func handleActionResult(
		status: Int,
		description: String,
		actionType: DetailsItemActionType
	) {
		if status == 1 {
			delegate?.didFinishItemActionSending()
		} else {
			let message: String
			switch actionType {
			case .archive:
				message = Constants.Messages.DetailsScreen.archiveFailed
			case .saveTags:
				message = Constants.Messages.DetailsScreen.tagSaveFailed
			}
			delegate?.didFailItemActionSending(userMessage: "\(message)\n(\(description))")
		}
	}
}
