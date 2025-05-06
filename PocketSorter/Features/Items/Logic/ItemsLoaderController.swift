//
//  ItemsLoaderController.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 28.04.2025.
//
//  Coordinates the loading of items from the server,
//  including pagination, task cancellation, and UI notification via delegate.
//

import Foundation

/// Handles item loading workflow including pagination and UI updates through a delegate.
final class ItemsLoaderController {

	// MARK: - Properties

	private let itemLoader: ItemLoader
	private let networkManager: NetworkManagerProtocol

	private var loadTask: Task<Void, Never>?
	private var currentState: TableLoadingState = .idle

	/// Delegate responsible for reflecting loading state changes in the UI.
	@MainActor
	weak var delegate: ItemsDownloadingDelegate?

	/// Callback triggered once the first page is saved and ready to fetch from Core Data.
	var onInitialLoadCompleted: (() -> Void)?

	// MARK: - Initialization

	init(itemLoader: ItemLoader, networkManager: NetworkManagerProtocol) {
		self.itemLoader = itemLoader
		self.networkManager = networkManager
	}

	deinit {
		loadTask?.cancel()
	}

	// MARK: - Public Methods

	/// Begins loading items from the first page and continues pagination until completion.
	/// The delegate receives state change events to reflect in the UI.
	func loadAllPages() {
		replaceTask { [weak self] in
			guard let self else { return }

			// Cancel if already cancelled before starting
			if Task.isCancelled {
				return
			}

			// Notify UI that loading is starting (disables buttons, shows spinner)
			await self.delegate?.didStartItemListDownloading()

			// Reset pagination offset
			self.networkManager.resetPaging()

			// Load the first page and check if the result is empty
			let isEmpty = await self.itemLoader.loadFirstPageAndCheckIfEmpty()

			// Decide what to show based on fetch result
			if !self.networkManager.wasLastRequestSuccessful {
				await self.delegate?.didFailItemListDownloading(with: NSError(domain: "com.pocketsorter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load items"]))
				return
			}

			// If successful and no data is returned after the first page, remove items and show empty result
			if isEmpty {
				await self.itemLoader.removeOutdatedItems()
				await self.delegate?.didFinishItemListDownloadingWithEmptyResult()
				return
			}

			// Now it's safe to call the callback, since data was successfully fetched
			self.onInitialLoadCompleted?()

			// Cancel if interrupted
			if Task.isCancelled {
				await self.delegate?.didFinishItemListDownloading()
				return
			}

			// Continue with pagination if applicable
			await self.delegate?.didStartPagingDownloading()

			while !self.networkManager.isPagingFinished {
				// Check if the current task has been cancelled
				if Task.isCancelled {
					// If the task was cancelled, notify the delegate that the loading has finished
					await self.delegate?.didFinishItemListDownloading()
					return
				}

				// Load the next page of data
				await self.itemLoader.loadNextPage()
			}

			// Remove outdated items after all pages have been loaded
			await self.itemLoader.removeOutdatedItems()

			// Once pagination is finished, notify the delegate that the loading process is complete
			await self.delegate?.didFinishItemListDownloading()
		}
	}

	// MARK: - Private Helpers

	/// Cancels any existing loading task and replaces it with a new one.
	@discardableResult
	private func replaceTask(_ operation: @escaping @Sendable () async -> Void) -> Task<Void, Never> {
		loadTask?.cancel()
		let newTask = Task {
			await operation()
		}
		loadTask = newTask
		return newTask
	}
}
