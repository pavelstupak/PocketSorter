//
//  ItemActionSendingDelegate.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 30.04.2025.
//
//  Defines a delegate for receiving updates related to tag-saving or archiving actions
//  triggered from the Details screen.
//

import Foundation

/// A delegate for receiving updates about item-related actions
/// such as saving tags or archiving an item.
protocol ItemActionSendingDelegate: AnyObject {
	/// Called when an action starts (e.g., archiving or saving tags).
	func didStartItemActionSending()

	/// Called when the action finishes successfully.
	func didFinishItemActionSending()

	/// Called when an action fails.
	/// - Parameters:
	///   - error: Optional technical error for logging purposes.
	///   - userMessage: A message to display to the user.
	func didFailItemActionSending(userMessage: String)
}
