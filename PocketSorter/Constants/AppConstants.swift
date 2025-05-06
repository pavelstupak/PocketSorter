//
//  AppConstants.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Defines commonly used constant values for UI elements, section headers, cell identifiers,
//  UserDefaults keys, and user-facing messages across the application.
//

/// A collection of constant values used across the UI
enum Constants {

	/// Cell reuse identifiers for various table view cells
	enum CellIdentifier {
		/// Cell for saved items (e.g., articles or videos)
		static let savedItem = "savedItemCell"

		/// Cell for a single tag
		static let tag = "tagCell"

		/// Another type of cell for displaying tags
		static let tagsTableViewCell = "tagsTableViewCell"
	}

	/// Titles for section headers in table views
	enum SectionHeader {
		/// Section header for articles
		static let articles = "📖 Articles"

		/// Section header for videos
		static let videos = "🎥 Videos"

		/// Section header for other types
		static let other = "⁉️ Other"
	}

	/// Keys used for storing data in UserDefaults
	enum UserDefaultsKeys {
		/// Key for storing selected item sorting type
		static let itemSortingType = "itemSortingType"
	}

	/// Messages shown to the user in various empty states
	enum Messages {
		/// Messages used in the Items screen
		enum ItemsScreen {
			/// Message when no data is available
			static let noData = "There is no data.\nTry to Pull to refresh"

			/// Message when inbox is empty
			static let zeroInbox = "It looks like you have a Zero Inbox!\nTry pulling to refresh to make sure"

			/// Title for error alert when downloading fails
			static let downloadingFailedTitle = "Downloading Failed"
		}

		/// Messages used in the Details screen
		enum DetailsScreen {
			/// Title used in error alerts
			static let errorTitle = "Error"

			/// Message when archiving fails
			static let archiveFailed = "Problem while archiving the item.\nPlease try again later"

			/// Message when saving tags fails
			static let tagSaveFailed = "Problem while saving tags.\nPlease try again later"

			/// Message shown when no tags have been created in the app.
			static let noTags = "There are no tags.\nPlease create tags in Settings"
		}

		/// Messages used in the Tags screen
		enum TagsScreen {
			/// Message shown when no tags have been created in the app.
			static let noTags = "There is no tags.\nPlease create some tags"

			/// Tag Creation Alert title
			static let alertTitle = "New tag"

			/// Tag Creation Alert message
			static let alertMessage = "Enter the tag name"

			/// Tag Creation Alert text placeholder
			static let alertTextPlaceholder = "Tag name"

			/// Tag Creation Alert "create" button name
			static let alertCreateButtonName = "Create"

			/// Tag Creation Alert "cancel" button name
			static let alertCancelButtonName = "Cancel"
		}
	}
}
