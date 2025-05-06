//
//  TagCreationAlert.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 23.04.2025.
//
// PageObject represents TagCreationAlert
//

import XCTest

struct TagCreationAlert {
	let app: XCUIApplication

	private var alert: XCUIElement {
		app.alerts["New tag"]
	}

	var nameField: XCUIElement {
		alert.textFields["Tag name"]
	}

	var createButton: XCUIElement {
		alert.buttons["Create"]
	}

	func enterTagName(_ name: String) {
		XCTAssertTrue(nameField.waitForExistence(timeout: 2), "Tag name text field didn't appear")
		nameField.tap()
		nameField.typeText(name)
	}

	func tapCreate() {
		XCTAssertTrue(createButton.exists, "Create button not found")
		createButton.tap()
	}
}
