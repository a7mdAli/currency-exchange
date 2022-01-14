//
//  CurrencyLayerBandwidthControlTests.swift
//  currency-exchangeUnitTests
//
//  Created by Ahmed Basha on 2022/01/15.
//

import XCTest
@testable import currency_exchange

class CurrencyLayerBandwidthControlTests: XCTestCase {

	func testBandwidthRestriction() throws {
		let bandwidthControl = CurrencyLayerBandwidthControl(identifier: "unit_test_identifier", timeIntervalToRestrainInSeconds: 2)

		XCTAssertFalse(bandwidthControl.isRestricted)

		bandwidthControl.didUseBandwidth()

		XCTAssertTrue(bandwidthControl.isRestricted)

		sleep(1)

		XCTAssertTrue(bandwidthControl.isRestricted)

		sleep(1)

		XCTAssertFalse(bandwidthControl.isRestricted)
	}

}
