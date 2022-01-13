//
//  HTTPMethod.swift
//  currency-exchange (iOS)
//
//  Created by Ahmed Basha on 2022/01/13.
//

import Foundation

struct HTTPMethod: Equatable {
	/// The Content-Type of the HTTP request.
	enum ContentType: Equatable {
		/// Adds a `"Content-Type": "application/json"` to the request header.
		case json
	}

	let stringValue: String
	let contentType: ContentType

	private init(stringLiteral: String, contentType: ContentType = .json) {
		self.stringValue = stringLiteral
		self.contentType = contentType
	}

	static let get: Self = .init(stringLiteral: "GET")
	static let post: Self = .post(contentType: .json)
	static let put: Self = .init(stringLiteral: "PUT")
	static let delete: Self = .init(stringLiteral: "DELETE")

	static func post(contentType: ContentType) -> Self {
		.init(stringLiteral: "POST", contentType: contentType)
	}
}
