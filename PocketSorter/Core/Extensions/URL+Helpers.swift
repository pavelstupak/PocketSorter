//
//  URL+Helpers.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 21.04.2025.
//
//  Adds helpers for extracting host and query parameters from a URL.
//

import Foundation

extension URL {
	/// Returns the host component of the URL, or an empty string if the host is nil.
	func hostOrEmpty() -> String {
		self.host ?? ""
	}
	
	/// Returns the value of a query item for a given key, if present.
	func queryValue(for key: String) -> String? {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
			  let queryItems = components.queryItems else {
			return nil
		}
		return queryItems.first(where: { $0.name == key })?.value
	}
}
