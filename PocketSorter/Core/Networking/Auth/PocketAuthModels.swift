//
//  PocketAuthModels.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 04.05.2025.
//
//  Declares request and response models used for communicating with the Pocket API for Auth.
//

import Foundation

struct JsonGetRequestToken: Encodable {
	let consumerKey: String
	let redirectUri: String
}

struct JsonGetRequestTokenResponse: Decodable {
	let code: String
}

struct JsonGetAccessTokenAndUsername: Encodable {
	let consumerKey: String
	let code: String
}

struct JsonGetAccessTokenAndUsernameResponse: Decodable {
	let accessToken: String
	let username: String
}
