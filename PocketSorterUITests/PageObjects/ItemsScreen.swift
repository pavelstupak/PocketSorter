//
//  ItemsScreen.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
// PageObject represents ItemsScreen
//

import XCTest

struct ItemsScreen {
	let app: XCUIApplication

	var settingsButton: XCUIElement {
		app.navigationBars.buttons["gearshape"]
	}

	func openSettings() {
		XCTAssertTrue(settingsButton.waitForExistence(timeout: 10), "Settings button didn't appear in time")
		settingsButton.tap()
	}
}
