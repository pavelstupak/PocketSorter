//
//  AlertHelper.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 18.04.2025.
//
// Utility for showing simple alerts
//

import UIKit

/// Utility for showing simple alerts
struct AlertHelper {
	/// Presents a simple alert with an OK button
	static func showAlertWithOkButton(
		on viewController: UIViewController,
		title: String,
		message: String
	) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default)
		alert.addAction(okAction)
		viewController.present(alert, animated: true)
	}
}
