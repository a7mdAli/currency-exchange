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

		XCTContext.runActivity(named: "Confirm successful API fetch request & data persistence") { _ in
			store.send(.fetchConversionRates)
			scheduler.advance(by: 0.3)

			store.receive(.conversionRatesResponse(.success(Self.conversionRates))) {
				$0.rates = Self.conversionRates
			}

			store.receive(.dataPersistenceAction(.persistData(Self.conversionRates)))
			assertPersistenceController(persistenceController, contains: Self.conversionRates)
		}
	}

	func testConversionsRateAPIError() throws {
		// Prepare test data
		let scheduler = DispatchQueue.test
		let mockClient = MockClient()
		mockClient.shouldReturnAnError = true

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

		// test
		XCTContext.runActivity(named: "Confirm failed API request with error") { _ in
			store.send(.fetchConversionRates)
			scheduler.advance(by: 0.3)

			// expected action to be received as a result of the fetch action
			store.receive(.conversionRatesResponse(.failure(Self.apiError))) {
				// expected state value as a result of handling the received action
				$0.rates = nil
			}
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

		// test
		XCTContext.runActivity(named: "Confirm bandwidth restriction is applied on fetch") { _ in
			XCTAssertFalse(store.environment.bandwidthControl.isRestricted)
			store.send(.fetchConversionRates)
			XCTAssertTrue(store.environment.bandwidthControl.isRestricted)
			scheduler.advance(by: 0.3)

			store.receive(.conversionRatesResponse(.success(Self.conversionRates))) {
				$0.rates = Self.conversionRates
			}

			store.receive(.dataPersistenceAction(.persistData(Self.conversionRates)))
		}

		
		XCTContext.runActivity(named: "Confirm unsuccessful fetch when bandwidth is restricted") { _ in
			// since there is no effect to receive this ensures we didn't initiate a fetch request
			// if a `conversionRatesResponse` effect is received when we're not handling it, the test will fail
			// indicating that the bandwidth restriction didn't work as intended.
			store.send(.fetchConversionRates)
		}

		XCTContext.runActivity(named: "Confirm bandwidth restriction is lifted after the designated time interval") { _ in
			scheduler.advance(by: 1.0)
			XCTAssertFalse(store.environment.bandwidthControl.isRestricted)
			// simulate fetch non-restricted fetch
			store.send(.fetchConversionRates)
			scheduler.advance(by: 0.3)

			store.receive(.conversionRatesResponse(.success(Self.conversionRates))) {
				$0.rates = Self.conversionRates
			}

			store.receive(.dataPersistenceAction(.persistData(Self.conversionRates)))
		}
	}

	func testPersistenceWithNilConversionRates() {
		// Prepare data
		let persistedData = ConversionRates(timestamp: Date(), source: "JPY", quotes: ["JPYUSD": 0.009])
		let scheduler = DispatchQueue.test
		let mockClient = MockClient()
		mockClient.shouldReturnAnError = true

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

		// test
		XCTContext.runActivity(named: "Confirm persisted data is applied correctly to the store's state") { _ in
			store.send(.dataPersistenceAction(.setFromPersistedDataIfNil)) {
				$0.rates = nil
			}

			store.send(.dataPersistenceAction(.persistData(persistedData))) {
				$0.rates = nil
			}

			assertPersistenceController(store.environment.persistenceController, contains: persistedData)

			store.send(.dataPersistenceAction(.setFromPersistedDataIfNil)) {
				$0.rates = persistedData
			}
		}

		XCTContext.runActivity(named: "Confirm persisted data is not overwritten by a failed fetch request") { _ in
			store.send(.fetchConversionRates)

			scheduler.advance(by: 0.3)

			store.receive(.conversionRatesResponse(.failure(Self.apiError))) {
				$0.rates = persistedData
			}
		}
	}

	func testFetchedDataTakesPrecedenceToPersistedData() throws {
		// Prepare data
		let persistedData = ConversionRates(timestamp: Date(), source: "JPY", quotes: ["JPYUSD": 0.009])
		let scheduler = DispatchQueue.test
		let environment = ConversionRatesEnvironment(
			mainQueue: scheduler.eraseToAnyScheduler(),
			conversionRatesService: MockClient(),
			bandwidthControl: MockBandwidthControl(scheduler: scheduler),
			persistenceController: PersistenceController(inMemory: true)
		)

		let store = TestStore(
			initialState: ConversionRatesState(),
			reducer: conversionRatesReducer,
			environment: environment
		)

		// test
		XCTContext.runActivity(named: "Confirm successful fetch & data persistence") { _ in
			store.send(.fetchConversionRates)
			scheduler.advance(by: 0.3)

			store.receive(.conversionRatesResponse(.success(Self.conversionRates))) {
				$0.rates = Self.conversionRates
			}

			scheduler.advance(by: 0.3)

			store.receive(.dataPersistenceAction(.persistData(Self.conversionRates))) {
				$0.rates = Self.conversionRates
			}

			assertPersistenceController(store.environment.persistenceController, contains: Self.conversionRates)
		}

		XCTContext.runActivity(named: "Ensure fetched data takes precedence to persisted data") { _ in
			store.send(.dataPersistenceAction(.persistData(persistedData)))
			scheduler.advance(by: 0.3)

			assertPersistenceController(store.environment.persistenceController, contains: persistedData)

			store.send(.dataPersistenceAction(.setFromPersistedDataIfNil)) {
				$0.rates = Self.conversionRates
			}
		}
	}

	// MARK: Helper methods

	func assertPersistenceController(_ persistenceController: PersistenceController, contains data: ConversionRates) {
		let snapshot = try! persistenceController.container.viewContext.fetch(ConversionRatesSnapshot.fetchRequest())[0]
		XCTAssertEqual(snapshot.timestamp, data.timestamp)
		XCTAssertEqual(snapshot.source, data.source)
		XCTAssertEqual(snapshot.quotes as? [String: Double], data.quotes)
	}
}
