//
//  APIClient.swift
//  currency-exchange (iOS)
//
//  Created by Ahmed Basha on 2022/01/13.
//

import Foundation
import Combine

final class APIClient {
	private let session: URLSession
	private let cancelables: Set<AnyCancellable> = []

	init(session: URLSession = .noCachingSession) {
		self.session = session
	}

	func execute<ResponseType: Decodable>(_ apiRequest: APIRequestProtocol, responseType: ResponseType.Type) -> AnyPublisher<ResponseType, Error> {
		let urlRequest = apiRequest.createURLRequest()
		return session.dataTaskPublisher(for: urlRequest)
			.tryMap({ (data, httpsResponse) -> Data in
				data
			})
			.decode(type: ResponseType.self, decoder: JSONDecoder())
			.eraseToAnyPublisher()
	}
}

extension URLSession {
	static var noCachingSession: URLSession {
		let config = URLSessionConfiguration.default
		config.requestCachePolicy = .reloadIgnoringLocalCacheData
		config.urlCache = nil

		return URLSession(configuration: config)
	}
}
