//
//  ConversionRatesStoreTests.swift
//  Tests iOS
//
//  Created by Ahmed Basha on 2022/01/14.
//

import XCTest
import Combine
import ComposableArchitecture
@testable import currency_exchange

class ConversionRatesStoreTests: XCTestCase {
	private let scheduler = DispatchQueue.test
	private static let apiError = APIError(code: 101, info: "User did not supply an access key or supplied an invalid access key.")
	private static let conversionRates = ConversionRates(timestamp: Date(), source: "USD", quotes: ["JPY": 115.7])

	// MARK: MockClient

	private final class MockClient: ConversionRatesService {
		var shouldReturnAnError: Bool = false

		func fetchConversionRates() -> AnyPublisher<ConversionRates, APIError> {
			Result<ConversionRates, APIError>
				.Publisher(shouldReturnAnError ? .failure(apiError) : .success(conversionRates))
				.eraseToAnyPublisher()
		}
	}

	// MARK: Tests

	func testConversionsRateFetch() throws {
		let store = TestStore(
			initialState: ConversionRatesState(),
			reducer: conversionRatesReducer,
			environment: ConversionRatesEnvironment(mainQueue: scheduler.eraseToAnyScheduler(), conversionRatesService: MockClient())
		)

		store.send(.fetchConversionRates)

		scheduler.advance(by: 0.3)

		store.receive(.conversionRatesResponse(.success(Self.conversionRates))) {
			$0.rates = Self.conversionRates
		}
	}

	func testConversionsRateError() throws {
		let mockClient = MockClient()
		let store = TestStore(
			initialState: ConversionRatesState(),
			reducer: conversionRatesReducer,
			environment: ConversionRatesEnvironment(mainQueue: scheduler.eraseToAnyScheduler(), conversionRatesService: mockClient)
		)

		mockClient.shouldReturnAnError = true

		store.send(.fetchConversionRates)

		scheduler.advance(by: 0.3)

		// expected action to be received as a result of the fetch action
		store.receive(.conversionRatesResponse(.failure(Self.apiError))) {
			// expected state value as a result of handling the received action
			$0.rates = nil
		}
	}

}
