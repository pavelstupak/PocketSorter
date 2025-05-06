//
//  NetworkErrorHelper.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 25.04.2025.
//
// Converts URLError codes into user-friendly textual messages.
//

import Foundation

/// Utility for converting URLError codes into human-readable messages.
func getDescriptionOfNetworkError(_ error: URLError) -> String {
	var description = ""

	switch error.code {
	case .notConnectedToInternet:
		description = "No internet connection."
	case .timedOut:
		description = "Request timed out."
	case .cannotFindHost:
		description = "Server not found."
	case .networkConnectionLost:
		description = "Network connection was lost."
	default:
		description = "Other network error: \(error.localizedDescription)."
	}

	return description
}
