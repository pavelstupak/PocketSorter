//
//  PocketActionModels.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 14.03.2025.
//
//  Declares response model used for communicating with the Pocket API (send action).
//

import Foundation

struct JsonSendActionResponse: Decodable {
	let actionResults: [Bool]
	let status: Int
}
