//
//  APIRequestProtocol.swift
//  currency-exchange (iOS)
//
//  Created by Ahmed Basha on 2022/01/13.
//

import Foundation

protocol APIRequestProtocol {
	typealias Headers = [String: String]

	var baseURL: String { get }
	var relativePath: String { get }
	var method: HTTPMethod { get }
	var parameters: Encodable? { get }
	var headers: Headers { get }
}

extension APIRequestProtocol {

	private var fullURLString: String {
		baseURL + relativePath
	}

	func createURLRequest() -> URLRequest {
		var urlComponent = URLComponents(string: fullURLString)!

		// MARK: Set Parameters

		if method == .get, let params = try? parameters?.asDictionary() {
			urlComponent.queryItems = params.map { key, value in
				URLQueryItem(name: key, value: String(describing: value))
			}
		}

		// MARK: Headers & HTTPMethod

		var request = URLRequest(url: urlComponent.url!)
		request.allHTTPHeaderFields = createHeaders()
		request.httpMethod = method.stringValue

		// MARK: Body

		if method != .get {
			switch method.contentType {
			case .json:
				if let body = try? parameters?.toJSONData() {
					request.httpBody = body
				}
			}
		}

		return request
	}

	// MARK: - Headers

	private func createHeaders() -> Headers {
		switch method.contentType {
		case .json:
			return ["Content-Type": "application/json"]
		}
	}
}

// MARK: - Helper Methods

private extension Encodable {
	func toJSONData() throws -> Data? { try JSONEncoder().encode(self) }

	func asDictionary() throws -> [String: Any] {
		let data = try JSONEncoder().encode(self)
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
			throw NSError()
		}
		return dictionary
	}
}
