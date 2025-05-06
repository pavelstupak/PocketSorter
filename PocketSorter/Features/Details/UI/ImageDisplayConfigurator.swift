//
//  ImageDisplayConfigurator.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 30.03.2025.
//
// Configures and updates the UI to reflect the state of an item's image download.
//

import UIKit
import CoreData

// MARK: - ImageDisplayConfiguring

/// A protocol defining the behavior and data required to configure image display for an item.
protocol ImageDisplayConfiguring: AnyObject {
	/// The Core Data context used to save image data.
	var context: NSManagedObjectContext { get }

	/// The current Core Data item whose image should be handled.
	var currentItem: Item { get set }

	/// Delegate for reporting image state and progress updates.
	var delegate: ImageDisplayConfiguratorDelegate? { get set }

	/// Starts image loading and updates the image state accordingly.
	func loadImageWithState()

	/// Sends image download progress to the delegate.
	func updateProgress(_ progress: Float)
}

// MARK: - ImageDisplayConfigurator

/// Configures the display of an item's image, including loading, progress tracking, and final rendering.
final class ImageDisplayConfigurator: ImageDisplayConfiguring {

	// MARK: - Properties

	/// The current Core Data item whose image is being displayed.
	var currentItem: Item

	/// Core Data context used to persist downloaded image data.
	let context: NSManagedObjectContext

	/// The number of bytes received so far during image download.
	var receivedImageDataSize: Int = 0 {
		didSet {
			if receivedImageDataSize > 0 && expectedImageDataSize > 0 {
				let progress = Float(receivedImageDataSize) / Float(expectedImageDataSize)
				updateProgress(progress)
			}
		}
	}

	/// The total number of bytes expected during image download.
	var expectedImageDataSize: Int = 0

	/// Delegate to receive image state and progress updates.
	weak var delegate: ImageDisplayConfiguratorDelegate?

	// MARK: - Initialization

	/// Initializes the configurator with the given item and context.
	///
	/// - Parameters:
	///   - currentItem: The item whose image will be displayed.
	///   - context: The Core Data context used to save the image data.
	init(currentItem: Item, context: NSManagedObjectContext) {
		self.currentItem = currentItem
		self.context = context
	}

	// MARK: - Public API

	/// Determines the image loading state and triggers appropriate UI updates.
	/// - If the image data already exists, it is displayed immediately.
	/// - If not, a placeholder is shown and image download is started.
	func loadImageWithState() {
		guard let url = currentItem.firstImageUrl else {
			Log.warning("Image URL is nil", logger: LoggerStore.details)
			delegate?.imageDisplayConfiguratorDidUpdateImageState(.placeholder)
			return
		}

		if let imageData = currentItem.firstImageData,
		   let image = UIImage(data: imageData) {
			delegate?.imageDisplayConfiguratorDidUpdateImageState(.loaded(image))
		} else {
			delegate?.imageDisplayConfiguratorDidUpdateImageState(.loading)
			downloadImage(byUrl: url)
		}
	}

	/// Reports updated download progress to the delegate.
	///
	/// - Parameter progress: The fraction of image data downloaded (0.0 to 1.0).
	func updateProgress(_ progress: Float) {
		delegate?.imageDisplayConfiguratorDidUpdateProgress(progress)
	}
}

// MARK: - ImageDisplayConfiguratorDelegate

/// A delegate protocol for receiving updates related to image loading state and progress.
protocol ImageDisplayConfiguratorDelegate: AnyObject {

	/// Called when the image state changes (e.g., loaded, loading, failed).
	func imageDisplayConfiguratorDidUpdateImageState(_ state: ImageState)

	/// Called when image download progress updates.
	func imageDisplayConfiguratorDidUpdateProgress(_ value: Float)
}

// MARK: - ImageDataDownloaderDelegate

extension ImageDisplayConfigurator: ImageDataDownloaderDelegate {

	/// Called when the image download is finished.
	///
	/// - Parameter imageData: The downloaded image data, or `nil` if the download failed.
	func didFinishDownloading(imageData: Data?) {
		if let imageData,
		   let image = UIImage(data: imageData) {
			ItemRepository.saveImageData(imageData, to: &currentItem, in: context)

			// Reload the item from context to get a fresh managed instance
			let objectID = currentItem.objectID
			currentItem = context.object(with: objectID) as! Item

			delegate?.imageDisplayConfiguratorDidUpdateImageState(.loaded(image))
		} else {
			delegate?.imageDisplayConfiguratorDidUpdateImageState(.placeholder)
		}
	}

	/// Starts the download of image data from the given URL.
	///
	/// - Parameter url: The image URL to download data from.
	func downloadImage(byUrl url: URL?) {
		guard let url else {
			Log.error("Image URL is nil", logger: LoggerStore.details)
			delegate?.imageDisplayConfiguratorDidUpdateImageState(.placeholder)
			return
		}

		let downloader = ImageDataDownloader.create(for: url, delegate: self)
		downloader.startDownload()
	}
}
