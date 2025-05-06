//
//  ActivityOverlay.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 18.04.2025.
//
// A struct that manages the display of an activity indicator overlay in the UI.
//

import UIKit

/// A struct that manages the display of an activity indicator overlay in the UI.
struct ActivityOverlay {
	
	/// The overlay view that covers the container view when loading.
	let overlayView: UIView
	
	/// The activity indicator that shows the loading progress.
	let indicator: UIActivityIndicatorView

	/// The container view to which the overlay and indicator are added. It is weak to avoid retain cycles.
	weak var containerView: UIView?
	
	/// The navigation item used to hide or show navigation elements while loading.
	weak var navigationItem: UINavigationItem?
	
	/// The navigation bar used to disable user interaction while loading.
	weak var navigationBar: UINavigationBar?

	/// The color of the activity indicator. Can be customized.
	var indicatorColor: UIColor = .white

	/// Sets up the overlay and indicator within the container view.
	/// Adds the overlay view and centers the indicator inside it.
	func setup() {
		guard let containerView = containerView else { return }
		
		// Configure the overlay view to cover the entire container view with a semi-transparent background
		overlayView.frame = containerView.bounds
		overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
		overlayView.isHidden = true
		containerView.addSubview(overlayView)

		// Center the indicator inside the overlay view and add it to the overlay
		indicator.center = overlayView.center
		indicator.color = indicatorColor
		overlayView.addSubview(indicator)
	}

	/// Shows the overlay and starts the activity indicator animation.
	/// Disables user interaction with the container view and navigation bar.
	func start() {
		guard let containerView = containerView, let navigationItem = navigationItem else { return }

		// Show the overlay with an animation
		overlayView.isHidden = false
		UIView.animate(withDuration: 0.3) {
			self.overlayView.alpha = 1
		}
		
		// Start the activity indicator animation
		indicator.startAnimating()
		containerView.isUserInteractionEnabled = false

		// Disable navigation actions while loading
		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem?.isEnabled = false
		navigationBar?.isUserInteractionEnabled = false
	}

	/// Stops the activity indicator and hides the overlay.
	/// Restores user interaction with the container view and navigation bar.
	func stop() {
		guard let containerView = containerView, let navigationItem = navigationItem else { return }

		// Stop the activity indicator animation
		indicator.stopAnimating()
		
		// Hide the overlay with an animation
		UIView.animate(withDuration: 0.3) {
			self.overlayView.alpha = 0
		} completion: { _ in
			self.overlayView.isHidden = true
		}
		
		// Restore user interaction with the container view
		containerView.isUserInteractionEnabled = true

		// Enable navigation actions again
		navigationItem.hidesBackButton = false
		navigationItem.rightBarButtonItem?.isEnabled = true
		navigationBar?.isUserInteractionEnabled = true
	}
}
