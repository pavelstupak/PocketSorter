//
//  NoDataLabelManagerTests.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 26.04.2025.
//
// Tests display logic for a "no data" message in table views.
//

import XCTest
@testable import PocketSorter
import UIKit

@MainActor
final class NoDataLabelManagerTests: XCTestCase {
	
	// MARK: - showMessage

	func test_showMessage_setsBackgroundViewWithCorrectText() {
		// Given
		let tableView = UITableView()
		
		// When
		NoDataViewManager.showMessage("No items available", on: tableView)
		
		// Then
		let label = tableView.backgroundView as? UILabel
		XCTAssertNotNil(label, "Background view should be UILabel.")
		XCTAssertEqual(label?.text, "No items available", "Label text should match the provided message.")
	}

	// MARK: - removeMessage

	func test_removeMessage_clearsBackgroundView() {
		// Given
		let tableView = UITableView()
		tableView.backgroundView = UILabel()
		
		// When
		NoDataViewManager.removeMessage(from: tableView)
		
		// Then
		XCTAssertNil(tableView.backgroundView, "Background view should be nil after removing message.")
	}
	
	// MARK: - updateIfNeeded
	func test_updateIfNeeded_showsMessageWhenObjectsCountIsNil() {
		// Given
		let tableView = UITableView()
		
		// When
		NoDataViewManager.updateIfNeeded(tableView: tableView, objectsCount: nil, message: "No data available")
		
		// Then
		XCTAssertTrue(tableView.backgroundView is UILabel, "Expected UILabel as background view when objectsCount is nil.")
	}
	
	func test_updateIfNeeded_showsMessageWhenObjectsCountIsZero() {
		// Given
		let tableView = UITableView()
		
		// When
		NoDataViewManager.updateIfNeeded(tableView: tableView, objectsCount: 0, message: "No data available")
		
		// Then
		XCTAssertTrue(tableView.backgroundView is UILabel, "Expected UILabel as background view when objectsCount is 0.")
	}
	
	func test_updateIfNeeded_removesMessageWhenObjectsCountGreaterThanZero() {
		// Given
		let tableView = UITableView()
		tableView.backgroundView = UILabel()
		
		// When
		NoDataViewManager.updateIfNeeded(tableView: tableView, objectsCount: 5, message: "No data available")
		
		// Then
		XCTAssertNil(tableView.backgroundView, "Expected background view to be removed when count > 0.")
	}
}
