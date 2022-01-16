//
//  ConvertRateStoreTests.swift
//  currency-exchangeUnitTests
//
//  Created by Ahmed Basha on 2022/01/16.
//

import XCTest
import ComposableArchitecture
@testable import currency_exchange

class ConvertRateStoreTests: XCTestCase {
	private static let conversionRates = ConversionRates(timestamp: Date(), source: "USD", quotes: ["USDJPY": 115.7, "USDEGP": 16, "KWD": 0.3])

	func testConversionsRateToConvertRateStateTransformation() throws {
		let store = TestStore(
			initialState: ConvertRateState(),
			reducer: convertRateReducer,
			environment: ConvertRateEnvironment()
		)

		XCTContext.runActivity(named: "Confirm transformation to ConvertRateState is working as intended") { _ in
			store.send(.updateWithConversionRates(Self.conversionRates)) {
				// 1. Must be in alphabetical order
				// 2. If the source's currency is attached
				//    to the conversion currencies it should be removed
				$0.rates = [
					Rate(currency: "USD", rate: 1.0),
					Rate(currency: "EGP", rate: 16.0),
					Rate(currency: "JPY", rate: 115.7),
					Rate(currency: "KWD", rate: 0.3)
				]

				$0.amountToConvert = 0.0
			}
		}
	}

	func testConversionIsWorkingCorrectly() throws {
		let viewStore = ViewStore(
			Store(
				initialState: ConvertRateState(),
				reducer: convertRateReducer,
				environment: ConvertRateEnvironment()
			)
		)

		let usd = Rate(currency: "USD", rate: 1.0)
		let egp = Rate(currency: "EGP", rate: 16.0)
		let jpy = Rate(currency: "JPY", rate: 115.7)
		let kwd = Rate(currency: "KWD", rate: 0.3)

		XCTContext.runActivity(named: "Confirm computed properties are working as expected") { _ in
			viewStore.send(.updateWithConversionRates(Self.conversionRates))
			let ratesToConvert = [egp, jpy, kwd]
			XCTAssertEqual(viewStore.ratesToConvert, ratesToConvert)
			XCTAssertEqual(viewStore.source, Rate(currency: "USD", rate: 1.0))
		}

		XCTContext.runActivity(named: "Confirm setAmount is working as expected") { _ in
			viewStore.send(.setAmount(""))
			XCTAssertEqual(viewStore.amountToConvert, 0.0)

			viewStore.send(.setAmount("1."))
			XCTAssertEqual(viewStore.amountToConvert, 1.0)

			viewStore.send(.setAmount(""))
			XCTAssertEqual(viewStore.amountToConvert, 0.0)

			viewStore.send(.setAmount("1.0"))
			XCTAssertEqual(viewStore.amountToConvert, 1.0)

			viewStore.send(.setAmount("0..0"))
			XCTAssertEqual(viewStore.amountToConvert, 1.0)
		}

		XCTContext.runActivity(named: "Confirm changing source is working as expected") { _ in
			viewStore.send(.changeSource(to: kwd))
			XCTAssertEqual(viewStore.source, kwd)
			XCTAssertEqual(viewStore.ratesToConvert, [usd, egp, jpy])

			viewStore.send(.changeSource(to: jpy))
			XCTAssertEqual(viewStore.source, jpy)
			XCTAssertEqual(viewStore.ratesToConvert, [kwd, usd, egp])

			viewStore.send(.changeSource(to: egp))
			XCTAssertEqual(viewStore.source, egp)
			XCTAssertEqual(viewStore.ratesToConvert, [jpy, kwd, usd])

			viewStore.send(.changeSource(to: usd))
			XCTAssertEqual(viewStore.source, usd)
			XCTAssertEqual(viewStore.ratesToConvert, [egp, jpy, kwd])
		}

		XCTContext.runActivity(named: "Confirm conversions are working as expected") { _ in
			let amount = 1.0
			viewStore.send(.setAmount("\(amount)"))

			// USD -> EGP
			XCTAssertEqual(viewStore.state.convertedAmount(for: egp), (amount*egp.rate)/usd.rate)
			// USD -> JPY
			XCTAssertEqual(viewStore.state.convertedAmount(for: jpy), (amount*jpy.rate)/usd.rate)
			// USD -> KWD
			XCTAssertEqual(viewStore.state.convertedAmount(for: kwd), (amount*kwd.rate)/usd.rate)

			viewStore.send(.changeSource(to: kwd))
			// KWD -> USD
			XCTAssertEqual(viewStore.state.convertedAmount(for: viewStore.ratesToConvert[0]), (amount*usd.rate)/kwd.rate)
			// KWD -> EGP
			XCTAssertEqual(viewStore.state.convertedAmount(for: viewStore.ratesToConvert[1]), (amount*egp.rate)/kwd.rate)
			// KWD -> JPY
			XCTAssertEqual(viewStore.state.convertedAmount(for: viewStore.ratesToConvert[2]), (amount*jpy.rate)/kwd.rate)
		}
	}

}
