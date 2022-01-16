//
//  DateValueTests.swift
//  Tests iOS
//
//  Created by Ahmed Basha on 2022/01/13.
//

import XCTest
@testable import Exchange

class DateValueTests: XCTestCase {

	private struct Data: Codable {
		@DateValue<UNIXTimestampCodingStrategy>
		var timestamp: Date
	}

	private let timestamp = 1642082875
	private var json: String { "{\"timestamp\":\(timestamp)}" }

	func testDateValueDecodingOfTimestamp() throws {
		let decodedData = try! JSONDecoder().decode(Data.self, from: json.data(using: .utf8)!)
		XCTAssertEqual(decodedData.timestamp, Date(timeIntervalSince1970: Double(timestamp)))
	}
	
	func testDateValueEncodingOfTimestamp() throws {
		let dataToEncode = Data(timestamp: Date(timeIntervalSince1970: Double(timestamp)))
		let encodedJSON = try! JSONEncoder().encode(dataToEncode)
		let encodedJSONString = String(data: encodedJSON, encoding: .utf8)
		XCTAssertEqual(encodedJSONString, json)
	}

	func testDateValueDecodingForDoubleValue() throws {
		let timestamp: Double = 1642082875.0
		let json = "{\"timestamp\":\(timestamp)}"
		let decodedData = try! JSONDecoder().decode(Data.self, from: json.data(using: .utf8)!)
		XCTAssertEqual(decodedData.timestamp, Date(timeIntervalSince1970: timestamp))
	}

	func testDateValueDecodingFailure() throws {
		let json = "{\"timestamp\":\"\"}"
		let decodedData = try? JSONDecoder().decode(Data.self, from: json.data(using: .utf8)!)
		XCTAssertNil(decodedData)
	}
	
}
