//
//  PocketSorterUITests.swift
//  PocketSorterUITests
//
//  Created by Pavel Stupak on 13.03.2025.
//

import XCTest

final class PocketSorterUITests: XCTestCase {
	// MARK: - Properties

	var app: XCUIApplication!

	// MARK: - Setup

	override func setUpWithError() throws {
		try super.setUpWithError()

		continueAfterFailure = false

		app = XCUIApplication()
		
		if name.contains("testCreateTagsInSettings") {
			app.launchArguments.append("--reset-tags")
		}
		
		app.launch()
	}

	// MARK: - Teardown

	override func tearDownWithError() throws {
		app = nil
		try super.tearDownWithError()
	}
	
	// MARK: - Tests

	@MainActor
	func testCreateTagsInSettings() throws {
		// Given: app launched and screens ready
		let itemsScreen = ItemsScreen(app: app)
		let settingsScreen = SettingsScreen(app: app)
		let tagAlert = TagCreationAlert(app: app)
		let tags = ["Urgent", "Work", "Personal"]

		// When: navigating to Settings
		itemsScreen.openSettings()
		
		// Then: verify empty state exists
		settingsScreen.verifyEmptyStateExists()
		
		for tag in tags {
			// When: adding a tag
			settingsScreen.tapAddTagButton()
			tagAlert.enterTagName(tag)
			tagAlert.tapCreate()
			
			// Then: verify the tag appears
			settingsScreen.verifyTagExists(tag)
		}
	}
}
