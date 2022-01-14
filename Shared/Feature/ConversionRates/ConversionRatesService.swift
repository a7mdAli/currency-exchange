//
//  ConversionRatesService.swift
//  currency-exchange (iOS)
//
//  Created by Ahmed Basha on 2022/01/14.
//

import Foundation
import Combine

protocol ConversionRatesService {
	func fetchConversionRates() -> AnyPublisher<ConversionRates, APIError>
}

final class ConversionRatesClient: ConversionRatesService {
	private let client: APIClient

	init(client: APIClient = .init()) {
		self.client = client
	}

	func fetchConversionRates() -> AnyPublisher<ConversionRates, APIError> {
		let request = CurrencyLayerAPIRequest(relativePath: "/live")
		return client.execute(request, responseType: CurrencyLayerAPIResponse.self)
			.tryMap {
				if $0.success {
					return $0.conversionRates!
				} else {
					throw $0.error!
				}
			}
			.mapError { error in
				if let error = error as? APIError {
					return error
				} else {
					return APIError(code: -1, info: error.localizedDescription)
				}
			}
			.eraseToAnyPublisher()
	}
}
