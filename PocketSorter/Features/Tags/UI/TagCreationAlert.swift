//
//  TagCreationAlert.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
// Displays an alert allowing the user to create a new tag
//

import UIKit

/// Displays an alert allowing the user to create a new tag
struct TagCreationAlert {
	/// Presents a tag creation alert from the given view controller
	/// - Parameter controller: The view controller from which the alert is presented
	static func present(in controller: TagsTableViewController) {
		// Create and configure the alert controller
		let alertController = UIAlertController(
			title: Constants.Messages.TagsScreen.alertTitle,
			message: Constants.Messages.TagsScreen.alertMessage,
			preferredStyle: .alert
		)

		// Create the "Create" action, initially disabled
		let createAction = UIAlertAction(title: Constants.Messages.TagsScreen.alertCreateButtonName, style: .default) { _ in
			guard let tagName = alertController.textFields?.first?.text else { return }
			TagRepository.createTag(named: tagName, in: controller.context)
		}
		createAction.isEnabled = false

		// Add a text field and configure it to trigger validation on text changes
		alertController.addTextField { textField in
			textField.placeholder = Constants.Messages.TagsScreen.alertTextPlaceholder
			textField.addTarget(
				controller,
				action: #selector(controller.handleTextChange(_:)),
				for: .editingChanged
			)
		}

		// Add "Cancel" and "Create" actions to the alert
		alertController.addAction(UIAlertAction(title: Constants.Messages.TagsScreen.alertCancelButtonName, style: .cancel))
		alertController.addAction(createAction)

		// Present the alert
		controller.present(alertController, animated: true)
	}
}

// MARK: - Text Field Change Handling

private extension TagsTableViewController {
	/// Handles text changes in the alert's text field
	/// Enables or disables the "Create" action based on whether the input is valid
	@objc func handleTextChange(_ textField: UITextField) {
		guard let alertController = presentedViewController as? UIAlertController else { return }

		// Find the "Create" action among the alert's actions
		if let createAction = alertController.actions.first(where: { $0.title == Constants.Messages.TagsScreen.alertCreateButtonName }) {
			let text = textField.text ?? ""
			createAction.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
	}
}
