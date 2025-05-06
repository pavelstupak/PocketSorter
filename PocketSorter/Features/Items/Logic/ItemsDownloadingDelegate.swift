//
//  ItemsLoaderControllerDelegate.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 30.04.2025.
//
// Defines a protocol for receiving updates about item loading progress and errors.
//

/// Receives updates about item loading progress and state changes from `ItemsLoaderController`.
@MainActor
protocol ItemsDownloadingDelegate: AnyObject {
	/// Called when the loading process begins (initial page).
	func didStartItemListDownloading()

	/// Called when pagination begins (subsequent pages are loading).
	func didStartPagingDownloading()

	/// Called when the entire loading process finishes.
	func didFinishItemListDownloading()

	/// Called if an empty result is returned after loading.
	func didFinishItemListDownloadingWithEmptyResult()

	/// Called if an error occurs during any stage of loading.
	///
	/// - Parameter error: The error that caused loading to fail.
	func didFailItemListDownloading(with error: Error)
}
