//
//  UIButton+Borders.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 17.04.2025.
//
//  Adds a standard border style to buttons for consistent UI appearance.
//

import UIKit

extension UIButton {
	/// Applies a standard border style to the button (rounded corners, border width, and link-colored border).
	func showBorders() {
		self.layer.cornerRadius = 10
		self.layer.borderWidth = 2
		self.layer.borderColor = UIColor.link.cgColor
	}
}
