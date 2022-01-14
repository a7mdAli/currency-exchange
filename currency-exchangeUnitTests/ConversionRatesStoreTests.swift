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

	// MARK: BandwidthControl

	private final class MockBandwidthControl: BandwidthControl {
		let scheduler: TestSchedulerOf<DispatchQueue>
		var timeIntervalToRestrainInSeconds: TimeInterval = 0.0
		var isRestricted: Bool = false

		init(scheduler: TestSchedulerOf<DispatchQueue>) {
			self.scheduler = scheduler
		}

		func didUseBandwidth() {
			isRestricted = true
			scheduler.schedule(after: .init(DispatchTime(uptimeNanoseconds: UInt64(timeIntervalToRestrainInSeconds)*1_000_000_000))) {
				self.isRestricted = false
			}
		}
	}

	// MARK: Tests

	func testConversionsRateFetchAndDataPersistence() throws {
		let scheduler = DispatchQueue.test
		let persistenceController = PersistenceController(inMemory: true)

		let environment = ConversionRatesEnvironment(
			mainQueue: scheduler.eraseToAnyScheduler(),
			conversionRatesService: MockClient(),
			bandwidthControl: MockBandwidthControl(scheduler: scheduler),
			persistenceController: persistenceController
		)

		let store = TestStore(
			initialState: ConversionRatesState(),
			reducer: conversionRatesReducer,
			environment: environment
		)

		store.send(.fetchConversionRates)

		scheduler.advance(by: 0.3)

		store.receive(.conversionRatesResponse(.success(Self.conversionRates))) {
			$0.rates = Self.conversionRates
		}

		store.receive(.dataPersistenceAction(.persistData(Self.conversionRates)))

		let snapshot = try! persistenceController.container.viewContext.fetch(ConversionRatesSnapshot.fetchRequest())[0]
		XCTAssertEqual(snapshot.timestamp, Self.conversionRates.timestamp)
		XCTAssertEqual(snapshot.source, Self.conversionRates.source)
		XCTAssertEqual(snapshot.quotes as? [String: Double], Self.conversionRates.quotes)
	}

	func testConversionsRateError() throws {
		let scheduler = DispatchQueue.test
		let mockClient = MockClient()
		let environment = ConversionRatesEnvironment(
			mainQueue: scheduler.eraseToAnyScheduler(),
			conversionRatesService: mockClient,
			bandwidthControl: MockBandwidthControl(scheduler: scheduler),
			persistenceController: PersistenceController(inMemory: true)
		)
		let store = TestStore(
			initialState: ConversionRatesState(),
			reducer: conversionRatesReducer,
			environment: environment
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

	func testBandwidthControlFetch() throws {
		// Prepare data
		let scheduler = DispatchQueue.test
		let mockBandwidthControl = MockBandwidthControl(scheduler: scheduler)
		mockBandwidthControl.timeIntervalToRestrainInSeconds = 1.0

		let environment = ConversionRatesEnvironment(
			mainQueue: scheduler.eraseToAnyScheduler(),
			conversionRatesService: MockClient(),
			bandwidthControl: mockBandwidthControl,
			persistenceController: PersistenceController(inMemory: true)
		)

		let store = TestStore(
			initialState: ConversionRatesState(),
			reducer: conversionRatesReducer,
			environment: environment
		)

		// simulate fetch
		store.send(.fetchConversionRates)

		XCTAssertTrue(store.environment.bandwidthControl.isRestricted)

		scheduler.advance(by: 0.3)

		store.receive(.conversionRatesResponse(.success(Self.conversionRates))) {
			$0.rates = Self.conversionRates
		}

		store.receive(.dataPersistenceAction(.persistData(Self.conversionRates)))

		// simulate bandwidth control restricting fetch
		store.send(.fetchConversionRates)

		scheduler.advance(by: 1.0)

		XCTAssertFalse(store.environment.bandwidthControl.isRestricted)

		// simulate fetch
		store.send(.fetchConversionRates)

		scheduler.advance(by: 0.3)

		store.receive(.conversionRatesResponse(.success(Self.conversionRates))) {
			$0.rates = Self.conversionRates
		}

		store.receive(.dataPersistenceAction(.persistData(Self.conversionRates)))
	}

}
