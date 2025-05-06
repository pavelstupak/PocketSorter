//
//  ImageDataDownloader.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 30.03.2025.
//
// Asynchronously downloads image data from a given URL.
//

import UIKit

// MARK: - ImageDataDownloaderDelegate

/// A delegate protocol for tracking the image download progress and completion.
protocol ImageDataDownloaderDelegate: AnyObject {
	/// Total number of bytes expected to be received.
	var expectedImageDataSize: Int { get set }

	/// Number of bytes downloaded so far.
	var receivedImageDataSize: Int { get set }

	/// Called when the download finishes, successfully or with error.
	func didFinishDownloading(imageData: Data?)
}

// MARK: - ImageDataDownloader

/// Handles downloading image data while reporting progress and results to its delegate.
final class ImageDataDownloader: NSObject, URLSessionDataDelegate {

	// MARK: - Properties

	private var receivedData = Data()
	private var expectedSize: Int = 0
	private let url: URL
	private var dataTask: URLSessionDataTask?
	weak var delegate: ImageDataDownloaderDelegate?

	// MARK: - Initialization

	private init(url: URL) {
		self.url = url
	}

	/// Factory method to create a downloader instance with a given URL and delegate.
	static func create(for url: URL, delegate: ImageDataDownloaderDelegate) -> ImageDataDownloader {
		let downloader = ImageDataDownloader(url: url)
		downloader.delegate = delegate
		return downloader
	}

	// MARK: - Public API

	/// Starts the image download task.
	func startDownload() {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 10
		let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		dataTask = session.dataTask(with: url)
		dataTask?.resume()
	}

	// MARK: - URLSessionDataDelegate

	/// Handles the response and extracts the expected content length.
	func urlSession(
		_ session: URLSession,
		dataTask: URLSessionDataTask,
		didReceive response: URLResponse,
		completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
	) {
		expectedSize = Int(response.expectedContentLength)
		delegate?.expectedImageDataSize = expectedSize
		Log.debug("Expected image data size: \(expectedSize)", logger: LoggerStore.networking)
		completionHandler(.allow)
	}

	/// Appends received data and updates the delegate with current progress.
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		receivedData.append(data)
		delegate?.receivedImageDataSize = receivedData.count
	}

	/// Notifies delegate of completion or failure of the download.
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error {
			Log.error("Download failed: \(error.localizedDescription)", logger: LoggerStore.networking)
			delegate?.didFinishDownloading(imageData: nil)
		} else {
			Log.debug("Download finished, total size: \(receivedData.count) bytes", logger: LoggerStore.networking)
			delegate?.didFinishDownloading(imageData: receivedData)
		}
	}
}
