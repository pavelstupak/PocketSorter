//
//  ItemsDiffableDataSource.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 17.04.2025.
//
//  Provides a diffable data source for displaying saved items with sectioned headers.
//  Uses ItemIdentifierType (objectID + timeUpdated) for accurate UI updates.
//

import UIKit
import CoreData

/// A diffable data source for the ItemsViewController's table view.
final class ItemsDiffableDataSource: UITableViewDiffableDataSource<SectionType, ItemIdentifierType> {

	/// Stores the number of items in each section for dynamic section header updates.
	var sectionMetadata: [SectionType: Int] = [:]

	/// The Core Data context used to fetch items.
	private let context: NSManagedObjectContext

	/// Creates a configured ItemsDiffableDataSource for the given table view and context.
	static func make(for tableView: UITableView, context: NSManagedObjectContext) -> ItemsDiffableDataSource {
		let dataSource = ItemsDiffableDataSource(
			tableView: tableView,
			context: context
		) { tableView, indexPath, identifier in
			let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.savedItem, for: indexPath)

			if let item = try? context.existingObject(with: identifier.objectID) as? Item {
				ItemCellConfigurator.configure(cell, with: item)
			}

			return cell
		}

		return dataSource
	}

	/// Initializes the data source with context and cell provider.
	private init(
		tableView: UITableView,
		context: NSManagedObjectContext,
		cellProvider: @escaping UITableViewDiffableDataSource<SectionType, ItemIdentifierType>.CellProvider
	) {
		self.context = context
		super.init(tableView: tableView, cellProvider: cellProvider)
	}

	/// Applies a new snapshot to the table view and updates section metadata.
	func applySnapshot(
		itemsBySection: [SectionType: [Item]],
		animatingDifferences: Bool = true
	) {
		var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemIdentifierType>()

		for (section, items) in itemsBySection {
			snapshot.appendSections([section])

			let identifiers = items.map {
				ItemIdentifierType(objectID: $0.objectID, timeUpdated: $0.timeUpdated)
			}

			snapshot.appendItems(identifiers, toSection: section)
			sectionMetadata[section] = identifiers.count
		}

		apply(snapshot, animatingDifferences: animatingDifferences)
	}

	/// Returns the title for the header in the specified section.
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionIdentifiers = snapshot().sectionIdentifiers
		guard section < sectionIdentifiers.count else { return nil }
		let sectionType = sectionIdentifiers[section]

		let count = sectionMetadata[sectionType] ?? 0
		return sectionType.headerTitle(count: count)
	}
}
