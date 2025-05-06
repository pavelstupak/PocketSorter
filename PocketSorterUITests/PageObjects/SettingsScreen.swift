//
//  SettingsScreen.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
// PageObject represents TagsScreen
//

import XCTest

struct SettingsScreen {
	private let app: XCUIApplication

	init(app: XCUIApplication) {
		self.app = app
	}

	var addTagButton: XCUIElement {
		app.navigationBars.buttons["Add"]
	}

	func tapAddTagButton() {
		addTagButton.tap()
	}

	func tagCell(named name: String) -> XCUIElement {
		app.tables.staticTexts[name]
	}

	func verifyTagExists(_ name: String, timeout: TimeInterval = 3) {
		let cell = tagCell(named: name)
		XCTAssertTrue(cell.waitForExistence(timeout: timeout), "Tag '\(name)' should appear after adding")
	}

	// Empty state message
	var emptyStateLabel: XCUIElement {
		app.tables.staticTexts["There is no tags.\nPlease create some tags"]
	}

	func verifyEmptyStateExists(timeout: TimeInterval = 5) {
		XCTAssertTrue(emptyStateLabel.waitForExistence(timeout: timeout), "Empty state message should appear when there are no tags")
	}
}
