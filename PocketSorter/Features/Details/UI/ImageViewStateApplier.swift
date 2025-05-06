//
//  ImageViewStateApplier.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 18.04.2025.
//
// A helper for applying image loading states to UI components.
//

import UIKit

/// Represents the different states of image loading and rendering.
enum ImageState {
	case idle                 // No image operation in progress
	case loading              // Image is currently being downloaded
	case loaded(UIImage)      // Image has been successfully loaded
	case placeholder          // Fallback placeholder image should be shown
}

/// A helper responsible for updating image and progress views based on image loading state.
final class ImageViewStateApplier {

	/// Applies the given image state to the image and progress views.
	///
	/// - Parameters:
	///   - state: The current image loading state.
	///   - imageView: The UIImageView to display the image or placeholder.
	///   - progressView: The UIProgressView to indicate download progress.
	static func apply(
		_ state: ImageState,
		to imageView: UIImageView,
		progressView: UIProgressView
	) {
		DispatchQueue.main.async {
			switch state {
			case .idle:
				imageView.image = nil
				progressView.isHidden = true

			case .loading:
				imageView.image = nil
				progressView.progress = 0
				progressView.isHidden = false

			case .loaded(let image):
				progressView.isHidden = true

				// Smooth transition to loaded image
				UIView.transition(
					with: imageView,
					duration: 0.3,
					options: .transitionCrossDissolve,
					animations: {
						imageView.image = image
					},
					completion: nil
				)

			case .placeholder:
				progressView.isHidden = true

				let config = UIImage.SymbolConfiguration(hierarchicalColor: .quaternaryLabel)
				let placeholderImage = UIImage(systemName: "photo", withConfiguration: config)

				// Smooth transition to placeholder
				UIView.transition(
					with: imageView,
					duration: 0.3,
					options: .transitionCrossDissolve,
					animations: {
						imageView.image = placeholderImage
					},
					completion: nil
				)
			}
		}
	}

	/// Updates the progress bar's value and visibility.
	///
	/// - Parameters:
	///   - value: The current progress value (0.0 to 1.0).
	///   - progressView: The progress bar to update.
	static func updateProgress(
		_ value: Float,
		in progressView: UIProgressView
	) {
		DispatchQueue.main.async {
			progressView.progress = value
			progressView.isHidden = !(value > 0 && value < 1)
		}
	}
}
